import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/reservation.dart';
import '../models/restaurant_table.dart';
import '../providers/reservation_provider.dart';
import '../providers/table_provider.dart';
import 'new_reservation_screen.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Reservation reservation;
  final bool isAdminView;

  const ReservationDetailScreen({
    super.key,
    required this.reservation,
    this.isAdminView = false,
  });

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.isAdminView;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerified && !widget.isAdminView) {
      return _buildVerificationScreen();
    }
    return _buildDetailScreen();
  }

  // ========== VERIFICATION SCREEN ==========
  Widget _buildVerificationScreen() {
    final verificationCodeCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Reservasi')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Verifikasi Reservasi Anda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Masukkan kode verifikasi yang dikirim ke email:\n${widget.reservation.guestEmail}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: verificationCodeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Kode Verifikasi (6 digit)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    prefixIcon: const Icon(Icons.vpn_key),
                    hintText: '000000',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    final code = verificationCodeCtrl.text.trim();
                    if (code == widget.reservation.verificationCode) {
                      setState(() {
                        _isVerified = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verifikasi berhasil!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kode verifikasi salah'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('Verifikasi')),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== DETAIL SCREEN ==========
  Widget _buildDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Detail Reservasi',
          style: TextStyle(color: Colors.white),
        ),
        actions: widget.isAdminView
            ? [
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewReservationScreen(
                            reservationToEdit: widget.reservation,
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deleteReservation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.deepPurple),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card info utama
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Tamu: ${widget.reservation.guestName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.isAdminView) ...[
                        Text(
                          'Email: ${widget.reservation.guestEmail}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Telepon: ${widget.reservation.guestPhone}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        'Jumlah Tamu: ${widget.reservation.numberOfGuests} orang',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Tanggal & Waktu'),
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.calendar_today,
                label: 'Tanggal Reservasi',
                value: DateFormat('dd MMMM yyyy', 'id_ID')
                    .format(widget.reservation.reservationDate),
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                icon: Icons.access_time,
                label: 'Waktu Reservasi',
                value:
                    '${widget.reservation.reservationTime.hour.toString().padLeft(2, '0')}:${widget.reservation.reservationTime.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Status'),
              const SizedBox(height: 12),
              Chip(
                label: Text(widget.reservation.status.displayName),
                backgroundColor: widget.reservation.status.color,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              if (widget.reservation.tableId != null)
                Consumer<TableProvider>(
                  builder: (context, tableProvider, _) {
                    final table = tableProvider.tables.firstWhere(
                      (t) => t.id == widget.reservation.tableId,
                      orElse: () => RestaurantTable(
                        tableNumber: '-',
                        capacity: 0,
                      ),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Meja'),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          icon: Icons.table_restaurant,
                          label: 'Nomor Meja',
                          value: 'Meja ${table.tableNumber}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          icon: Icons.event_seat,
                          label: 'Kapasitas',
                          value: '${table.capacity} kursi',
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              if (widget.reservation.orderedItems != null &&
                  widget.reservation.orderedItems!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Menu Pesanan'),
                    const SizedBox(height: 12),
                    ...widget.reservation.orderedItems!.map((item) {
                      final itemName = item['name'] as String? ?? 'Unknown';
                      final price = item['price'] as num? ?? 0;
                      final quantity = item['quantity'] as num? ?? 1;
                      final total = (price * quantity);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(itemName)),
                            Text('$quantity x Rp ${price.toInt()}'),
                            const SizedBox(width: 8),
                            Text('Rp ${total.toInt()}'),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp ${(widget.reservation.orderedItems!.fold<num>(0, (sum, item) => sum + ((item['price'] as num? ?? 0) * (item['quantity'] as num? ?? 1)))).toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              if (widget.reservation.specialRequests.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Catatan Khusus'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(widget.reservation.specialRequests),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              _buildDetailSection('Waktu Pemesanan'),
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.schedule,
                label: 'Dibuat Pada',
                value: DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                    .format(widget.reservation.createdAt),
              ),
              const SizedBox(height: 32),
              if (widget.isAdminView) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ubah Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => _deleteReservation(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'Hapus Reservasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _buildRatingSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ========== RATING SECTION ==========
  Widget _buildRatingSection() {
    double currentRating = widget.reservation.rating ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Berikan Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= 5; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentRating = i.toDouble();
                  });
                  _updateRating(i.toDouble());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    i <= currentRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (currentRating > 0)
          Center(
            child: Text(
              '$currentRating / 5 Bintang',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  void _updateRating(double rating) {
    final provider = context.read<ReservationProvider>();
    final updatedReservation = widget.reservation.copyWith(rating: rating);
    provider.updateReservation(updatedReservation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rating $rating bintang berhasil disimpan'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ========== DIALOGS & HELPERS ==========
  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status'),
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
    return ListTile(
      title: Text(status.displayName),
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: status.color,
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {
        final provider = context.read<ReservationProvider>();
        final updatedReservation =
            widget.reservation.copyWith(status: status);
        provider.updateReservation(updatedReservation);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status reservasi berhasil diubah')),
        );
      },
    );
  }

  void _deleteReservation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Reservasi'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus reservasi ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final tableProvider = context.read<TableProvider>();
              if (widget.reservation.tableId != null) {
                tableProvider.releaseTable(widget.reservation.tableId!);
              }
              context.read<ReservationProvider>().deleteReservation(
                    widget.reservation.id,
                  );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reservasi berhasil dihapus')),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
