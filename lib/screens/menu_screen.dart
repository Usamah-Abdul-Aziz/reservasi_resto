import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import 'new_reservation_screen.dart';

/// Menu Screen - untuk customer lihat menu
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  MenuCategory? _selectedCategory;
  bool _showSoldOut = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, _) {
          final categories = menuProvider.getAvailableCategories();
          final allItems = _selectedCategory != null
              ? menuProvider.getMenuByCategory(_selectedCategory!)
              : menuProvider.menuItems;

          final filteredItems = _showSoldOut
              ? allItems
              : allItems
                  .where((item) {
                    final av =
                        menuProvider.getAvailabilityForToday(item.id);
                    return av != null && !av.isSoldOut && av.isAvailable;
                  })
                  .toList();

          return Column(
            children: [
              // Header dengan filter
              Container(
                color: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chips
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              child: FilterChip(
                                label: const Text('Semua'),
                                selected: _selectedCategory == null,
                                onSelected: (selected) {
                                  setState(
                                      () => _selectedCategory = null);
                                },
                              ),
                            );
                          }

                          final category = categories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: FilterChip(
                              avatar: Text(
                                category.emoji,
                                style:
                                    const TextStyle(fontSize: 14),
                              ),
                              label: Text(category.displayName),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() => _selectedCategory =
                                    selected ? category : null);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Show sold out toggle
                    Row(
                      children: [
                        Checkbox(
                          value: _showSoldOut,
                          onChanged: (value) {
                            setState(
                                () => _showSoldOut = value ?? true);
                          },
                        ),
                        const Text(
                          'Tampilkan semua menu',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu list
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const Text(
                              'Tidak ada menu',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _MenuItemGridCard(
                            item: filteredItems[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewReservationScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Reservasi Baru'),
      ),
    );
  }
}

class _MenuItemGridCard extends StatelessWidget {
  final MenuItem item;

  const _MenuItemGridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        final availability = menuProvider.getAvailabilityForToday(item.id);
        final isSoldOut = availability?.isSoldOut ?? false;
        final isAvailable = availability?.isAvailable ?? true;

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => _MenuItemDetailSheet(item: item),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                color: AppColors.white,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with category
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.category.displayName,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),

                              // Badges
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  if (item.isSpicy)
                                    const _BadgeChip(
                                      icon: '🌶️',
                                      label: 'Pedas',
                                      color: AppColors.spicy,
                                    ),
                                  if (item.isVegetarian)
                                    const _BadgeChip(
                                      icon: '🌱',
                                      label: 'Veg',
                                      color: AppColors.vegetarian,
                                    ),
                                ],
                              ),

                              // Price
                              const Spacer(),
                              Text(
                                'Rp ${item.price.toInt()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Sold out overlay
                  if (isSoldOut || !isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.4),
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Center(
                          child: Text(
                            'HABIS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemDetailSheet extends StatelessWidget {
  final MenuItem item;

  const _MenuItemDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        final availability = menuProvider.getAvailabilityForToday(item.id);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          item.category.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style:
                                  AppTextStyles.headingMedium,
                            ),
                            const SizedBox(
                                height: AppSpacing.xs),
                            Text(
                              item.category.displayName,
                              style:
                                  AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.description,
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Info
                  Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.schedule,
                          label: 'Persiapan',
                          value:
                              '${item.preparationTime} menit',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.local_fire_department,
                          label: 'Tingkat Pedas',
                          value: item.isSpicy ? 'Ya' : 'Tidak',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Price and availability
                  Container(
                    padding: const EdgeInsets.all(
                        AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight
                          .withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Harga',
                              style:
                                  AppTextStyles.bodySmall,
                            ),
                            const SizedBox(
                                height: AppSpacing.xs),
                            Text(
                              'Rp ${item.price.toInt()}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (availability != null)
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Status',
                                style:
                                    AppTextStyles.bodySmall,
                              ),
                              const SizedBox(
                                  height: AppSpacing.xs),
                              Chip(
                                label: Text(
                                  availability
                                      .isSoldOut
                                      ? 'HABIS'
                                      : 'TERSEDIA',
                                ),
                                backgroundColor:
                                    availability
                                            .isSoldOut
                                        ? AppColors
                                            .error
                                        : AppColors
                                            .success,
                                labelStyle: const TextStyle(
                                  color: AppColors
                                      .white,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
