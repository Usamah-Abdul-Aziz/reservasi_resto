import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/reservation_provider.dart';
import '../models/reservation.dart';
import 'new_reservation_screen.dart';
import 'reservation_detail_screen.dart';
import 'menu_screen.dart';
import 'role_selection_screen.dart';
import '../widgets/reservation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          RESTAURANT_NAME,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_selectedTabIndex == 0) {
            return _buildMenu();
          } else if (_selectedTabIndex == 1) {
            return _buildUpcomingReservations(provider);
          } else if (_selectedTabIndex == 2) {
            return _buildAllReservations(provider);
          } else {
            return _buildStatistics(provider);
          }
        },
      ),
      floatingActionButton: _selectedTabIndex > 0
          ? FloatingActionButton.extended(
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
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Mendatang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Semua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return const MenuScreen();
  }

  Widget _buildUpcomingReservations(ReservationProvider provider) {
    final upcomingReservations = provider.getUpcomingReservations();

    if (upcomingReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada reservasi mendatang',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewReservationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Reservasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingReservations.length,
      itemBuilder: (context, index) {
        final reservation = upcomingReservations[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReservationDetailScreen(reservation: reservation, isAdminView: false),
              ),
            );
          },
          child: ReservationCard(reservation: reservation),
        );
      },
    );
  }

  Widget _buildAllReservations(ReservationProvider provider) {
    final allReservations = provider.reservations;

    if (allReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada reservasi',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allReservations.length,
      itemBuilder: (context, index) {
        final reservation = allReservations[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReservationDetailScreen(reservation: reservation, isAdminView: false),
              ),
            );
          },
          child: ReservationCard(reservation: reservation),
        );
      },
    );
  }

  Widget _buildStatistics(ReservationProvider provider) {
    final allReservations = provider.reservations;
    final pending = allReservations
        .where((r) => r.status == ReservationStatus.pending)
        .length;
    final confirmed = allReservations
        .where((r) => r.status == ReservationStatus.confirmed)
        .length;
    final completed = allReservations
        .where((r) => r.status == ReservationStatus.completed)
        .length;
    final cancelled = allReservations
        .where((r) => r.status == ReservationStatus.cancelled)
        .length;
    final totalGuests = allReservations.fold(0, (sum, r) => sum + r.numberOfGuests);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Reservasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _StatisticCard(
            title: 'Total Reservasi',
            value: allReservations.length.toString(),
            icon: Icons.calendar_today,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          _StatisticCard(
            title: 'Tertunda',
            value: pending.toString(),
            icon: Icons.schedule,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _StatisticCard(
            title: 'Terkonfirmasi',
            value: confirmed.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _StatisticCard(
            title: 'Selesai',
            value: completed.toString(),
            icon: Icons.done_all,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _StatisticCard(
            title: 'Dibatalkan',
            value: cancelled.toString(),
            icon: Icons.cancel,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _StatisticCard(
            title: 'Total Tamu',
            value: totalGuests.toString(),
            icon: Icons.people,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
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
