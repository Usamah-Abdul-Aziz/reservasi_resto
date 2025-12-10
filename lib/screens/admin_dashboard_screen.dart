import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/menu_item.dart';
import '../models/reservation.dart';
import '../models/restaurant_table.dart';
import '../providers/menu_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/supabase_reservation_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/table_provider.dart';
import '../services/email_service.dart';
import '../widgets/notification_bell.dart';
import 'role_selection_screen.dart';
import 'reservation_detail_screen.dart';

/// Admin Dashboard - untuk mengelola menu, stock, dan reservasi
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          const NotificationBell(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: const [
          _MenuManagementTab(),
          _TableManagementTab(),
          _StockManagementTab(),
          _ReservationManagementTab(),
          _StatisticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Meja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Reservasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: MENU MANAGEMENT
// ============================================================================

class _MenuManagementTab extends StatefulWidget {
  const _MenuManagementTab();

  @override
  State<_MenuManagementTab> createState() => __MenuManagementTabState();
}

class __MenuManagementTabState extends State<_MenuManagementTab> {
  MenuCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        final categories = menuProvider.getAvailableCategories();
        final filteredItems = _selectedCategory != null
            ? menuProvider.getMenuByCategory(_selectedCategory!)
            : menuProvider.menuItems;

        return Column(
          children: [
            // Header dengan tambah menu
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kelola Menu',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMenuDialog(context, menuProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
            ),

            // Category filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AppSpacing.sm),
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
                          setState(() => _selectedCategory = null);
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
                      label: Text(category.displayName),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() =>
                            _selectedCategory =
                                selected ? category : null);
                      },
                    ),
                  );
                },
              ),
            ),

            // Menu list
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text('Tidak ada menu'),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _MenuItemCard(item: item);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddMenuDialog(BuildContext context, MenuProvider menuProvider) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    var selectedCategory = MenuCategory.mainCourse;
    var isSpicy = false;
    var isVegetarian = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Menu Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Menu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: MenuCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  title: const Text('Pedas'),
                  value: isSpicy,
                  onChanged: (value) {
                    setState(() => isSpicy = value!);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Vegetarian'),
                  value: isVegetarian,
                  onChanged: (value) {
                    setState(() => isVegetarian = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final item = MenuItem(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  category: selectedCategory,
                  isSpicy: isSpicy,
                  isVegetarian: isVegetarian,
                );
                menuProvider.addMenuItem(item);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu berhasil ditambahkan')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('${item.category.displayName} • Rp ${item.price.toInt()}'),
        leading: Text(item.category.emoji, style: const TextStyle(fontSize: 24)),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _showEditMenuDialog(context, item),
            ),
            PopupMenuItem(
              child: const Text('Hapus'),
              onTap: () {
                context.read<MenuProvider>().deleteMenuItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMenuDialog(BuildContext context, MenuItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description);
    final priceCtrl = TextEditingController(text: '${item.price.toInt()}');
    var selectedCategory = item.category;
    var isSpicy = item.isSpicy;
    var isVegetarian = item.isVegetarian;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Menu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Menu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: MenuCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  title: const Text('Pedas'),
                  value: isSpicy,
                  onChanged: (value) {
                    setState(() => isSpicy = value!);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Vegetarian'),
                  value: isVegetarian,
                  onChanged: (value) {
                    setState(() => isVegetarian = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedItem = item.copyWith(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? item.price,
                  category: selectedCategory,
                  isSpicy: isSpicy,
                  isVegetarian: isVegetarian,
                );
                context.read<MenuProvider>().updateMenuItem(updatedItem);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu berhasil diperbarui')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: STOCK MANAGEMENT
// ============================================================================

class _StockManagementTab extends StatelessWidget {
  const _StockManagementTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Text(
                'Update stock dan ketersediaan menu untuk hari ini',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...menuProvider.menuItems.map((item) {
              final availability = menuProvider.getAvailabilityForToday(item.id);
              return _StockCard(item: item, availability: availability);
            }),
          ],
        );
      },
    );
  }
}

class _StockCard extends StatefulWidget {
  final MenuItem item;
  final MenuItemAvailability? availability;

  const _StockCard({
    required this.item,
    required this.availability,
  });

  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard> {
  late int soldCount;

  @override
  void initState() {
    super.initState();
    soldCount = widget.availability?.soldCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availability == null) return const SizedBox();

    final av = widget.availability!;
    final remaining = av.remainingStock;
    final percentage = av.soldPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.item.category.emoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: AppTextStyles.bodyLarge,
                      ),
                      Text(
                        'Stok: $remaining / ${av.totalStock}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${percentage.toStringAsFixed(0)}%'),
                  backgroundColor: percentage > 80
                      ? AppColors.error
                      : percentage > 50
                          ? AppColors.warning
                          : AppColors.success,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: percentage / 100,
                backgroundColor: AppColors.outline,
                valueColor: AlwaysStoppedAnimation(
                  percentage > 80
                      ? AppColors.error
                      : percentage > 50
                          ? AppColors.warning
                          : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Controls
            Row(
              children: [
                IconButton(
                  onPressed: soldCount > 0
                      ? () => setState(() => soldCount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Terjual: $soldCount',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: soldCount < av.totalStock
                      ? () => setState(() => soldCount++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<MenuProvider>()
                        .updateSoldCount(widget.item.id, soldCount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Stock berhasil diupdate')),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
            // Availability toggle
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              title: const Text('Tersedia hari ini'),
              value: av.isAvailable,
              onChanged: (value) {
                context
                    .read<MenuProvider>()
                    .toggleAvailability(widget.item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 3: RESERVATION MANAGEMENT
// ============================================================================

class _ReservationManagementTab extends StatefulWidget {
  const _ReservationManagementTab();

  @override
  State<_ReservationManagementTab> createState() =>
      _ReservationManagementTabState();
}

class _ReservationManagementTabState extends State<_ReservationManagementTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, _) {
        final today = DateTime.now();
        final todayReservations = reservationProvider.getReservationsByDate(today);

        if (todayReservations.isEmpty) {
          return const Center(
            child: Text('Tidak ada reservasi untuk hari ini'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  '${todayReservations.length} Reservasi Hari Ini',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...todayReservations.map((reservation) {
                return _ReservationManagementCard(
                  reservation: reservation,
                  onUpdated: () => setState(() {}),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ReservationManagementCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onUpdated;

  const _ReservationManagementCard({
    required this.reservation,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.guestName,
                        style: AppTextStyles.headingSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Jam: ${reservation.reservationTime.hour.toString().padLeft(2, '0')}:${reservation.reservationTime.minute.toString().padLeft(2, '0')} • ${reservation.numberOfGuests} Orang',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(reservation.status.displayName),
                  backgroundColor: reservation.status.color,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Catatan: ${reservation.specialRequests.isEmpty ? '-' : reservation.specialRequests}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _sendReminder(context),
                  icon: const Icon(Icons.notifications_active, size: 16),
                  label: const Text('Reminder'),
                ),
                OutlinedButton(
                  onPressed: () => _markAsArrived(context),
                  child: const Text('Tandai Datang'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _showStatusUpdateDialog(context),
                  child: const Text('Update Status'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationDetailScreen(
                          reservation: reservation,
                          isAdminView: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markAsArrived(BuildContext context) {
    final reservationProvider = context.read<ReservationProvider>();
    final supabaseProvider = context.read<SupabaseReservationProvider>();
    final updatedReservation = reservation.copyWith(hasArrived: true);
    
    reservationProvider.updateReservation(updatedReservation);
    supabaseProvider.updateReservation(updatedReservation);
    onUpdated?.call();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reservasi ditandai sebagai datang'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendReminder(BuildContext context) async {
    // Tampilkan loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Mengirim reminder...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Kirim reminder email
    final success = await EmailService.sendReminderEmail(reservation: reservation);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? '✅ Reminder berhasil dikirim ke ${reservation.guestEmail}'
              : '❌ Gagal mengirim reminder',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status Reservasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(context, ReservationStatus.pending),
              _buildStatusOption(context, ReservationStatus.confirmed),
              _buildStatusOption(context, ReservationStatus.completed),
              _buildStatusOption(context, ReservationStatus.cancelled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, ReservationStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final reservationProvider = context.read<ReservationProvider>();
            final supabaseProvider = context.read<SupabaseReservationProvider>();
            final previousStatus = reservation.status.displayName;
            final updatedReservation = reservation.copyWith(status: status);
            
            // Update di local provider
            reservationProvider.updateReservation(updatedReservation);
            
            // Update di Supabase (ini akan otomatis kirim email status change)
            supabaseProvider.updateReservation(updatedReservation);
            
            onUpdated?.call();
            
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status diubah menjadi ${status.displayName}. Email notifikasi terkirim.'),
                duration: const Duration(seconds: 3),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    status.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: TABLE MANAGEMENT
// ============================================================================

class _TableManagementTab extends StatefulWidget {
  const _TableManagementTab();

  @override
  State<_TableManagementTab> createState() => _TableManagementTabState();
}

class _TableManagementTabState extends State<_TableManagementTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TableProvider>(
      builder: (context, tableProvider, _) {
        final tables = tableProvider.tables;

        return Column(
          children: [
            // Header dengan statistik
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kelola Meja',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTableDialog(context, tableProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
            ),

            // Statistik meja
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Meja',
                      value: '${tableProvider.totalTables}',
                      color: AppColors.primary,
                      icon: Icons.table_restaurant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      title: 'Tersedia',
                      value: '${tableProvider.availableTables}',
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      title: 'Terisi',
                      value: '${tableProvider.occupiedTables}',
                      color: Colors.orange,
                      icon: Icons.people,
                    ),
                  ),
                ],
              ),
            ),

            // Table grid view
            Expanded(
              child: tables.isEmpty
                  ? const Center(
                      child: Text('Tidak ada meja'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Reload tables and reservations
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              crossAxisSpacing: AppSpacing.sm,
                              mainAxisSpacing: AppSpacing.sm,
                            ),
                        itemCount: tables.length,
                        itemBuilder: (context, index) {
                          final table = tables[index];
                          return _TableCard(
                            table: table,
                            onEdit: () =>
                                _showEditTableDialog(context, tableProvider, table),
                            onDelete: () => _showDeleteTableDialog(
                              context,
                              tableProvider,
                              table,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddTableDialog(BuildContext context, TableProvider tableProvider) {
    final numberCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Meja Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nomor Meja',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: capacityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Kursi',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final tableNumber = numberCtrl.text.trim();
              final capacity = int.tryParse(capacityCtrl.text) ?? 0;

              if (tableNumber.isNotEmpty && capacity > 0) {
                tableProvider.addTable(
                  RestaurantTable(
                    tableNumber: tableNumber,
                    capacity: capacity,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meja berhasil ditambahkan')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Input tidak valid')),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditTableDialog(
    BuildContext context,
    TableProvider tableProvider,
    RestaurantTable table,
  ) {
    final numberCtrl = TextEditingController(text: '${table.tableNumber}');
    final capacityCtrl = TextEditingController(text: '${table.capacity}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meja'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nomor Meja',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: capacityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Kursi',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final tableNumber = numberCtrl.text.trim();
              final capacity = int.tryParse(capacityCtrl.text) ?? 0;

              if (tableNumber.isNotEmpty && capacity > 0) {
                tableProvider.updateTable(
                  table.copyWith(
                    tableNumber: tableNumber,
                    capacity: capacity,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meja berhasil diperbarui')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTableDialog(
    BuildContext context,
    TableProvider tableProvider,
    RestaurantTable table,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Meja'),
        content: Text('Hapus meja nomor ${table.tableNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              tableProvider.deleteTable(table.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meja berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TableCard({
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(table.status);
    final statusEmoji = table.status.emoji;

    return GestureDetector(
      onLongPress: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          border: Border.all(color: statusColor, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Meja ${table.tableNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${table.capacity} 🪑',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              table.status.displayName,
              style: TextStyle(
                fontSize: 10,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Tampilkan detail reservasi jika meja direservasi
            if (table.status == TableStatus.reserved && table.reservationId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                child: Consumer<ReservationProvider>(
                  builder: (context, reservationProvider, _) {
                    final reservation = reservationProvider.reservations
                        .firstWhere(
                          (r) => r.id == table.reservationId,
                          orElse: () => Reservation.empty(),
                        );
                    
                    if (reservation.id.isEmpty) {
                      return Text(
                        'Direservasi',
                        style: TextStyle(
                          fontSize: 9,
                          color: statusColor,
                        ),
                      );
                    }
                    
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reservation.guestName,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${reservation.reservationTime.hour.toString().padLeft(2, '0')}:${reservation.reservationTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 8,
                            color: statusColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.maintenance:
        return Colors.grey;
    }
  }
}

// ============================================================================
// TAB 5: STATISTICS
// ============================================================================

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<MenuProvider, ReservationProvider>(
      builder: (context, menuProvider, reservationProvider, _) {
        final soldOutItems = menuProvider.getSoldOutItems();
        final allReservations = reservationProvider.reservations;
        final todayReservations = reservationProvider.getReservationsByDate(DateTime.now());
        final confirmedCount = allReservations
            .where((r) => r.status == ReservationStatus.confirmed)
            .length;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _StatCard(
              title: 'Total Menu',
              value: menuProvider.menuItems.length.toString(),
              color: AppColors.primary,
              icon: Icons.restaurant_menu,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatCard(
              title: 'Habis Hari Ini',
              value: soldOutItems.length.toString(),
              color: AppColors.error,
              icon: Icons.inventory_2,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatCard(
              title: 'Reservasi Hari Ini',
              value: todayReservations.length.toString(),
              color: AppColors.warning,
              icon: Icons.event_note,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatCard(
              title: 'Terkonfirmasi',
              value: confirmedCount.toString(),
              color: AppColors.success,
              icon: Icons.check_circle,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
