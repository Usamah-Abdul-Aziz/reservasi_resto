import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/reservation_database_service.dart';
import '../services/email_service.dart';

class SupabaseReservationProvider extends ChangeNotifier {
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize dan load reservasi dari Supabase
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await ReservationDatabaseService.getAllReservations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat reservasi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah reservasi baru
  Future<bool> addReservation(Reservation reservation) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simpan ke database (trigger otomatis buat notifikasi admin)
      final dbSuccess =
          await ReservationDatabaseService.createReservation(reservation);

      if (dbSuccess) {
        // Kirim email verifikasi ke user
        await EmailService.sendVerificationEmail(
          reservation: reservation,
        );
        
        // Notifikasi admin sekarang otomatis via database trigger
        // Tidak perlu kirim email lagi

        // Update local list
        _reservations.add(reservation);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal menyimpan reservasi';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update reservasi
  Future<bool> updateReservation(Reservation reservation) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Dapatkan status sebelumnya
      final oldReservation =
          _reservations.firstWhere((r) => r.id == reservation.id);
      final statusChanged = oldReservation.status != reservation.status;

      // Update ke database
      final dbSuccess =
          await ReservationDatabaseService.updateReservation(reservation);

      if (dbSuccess) {
        // Jika status berubah, kirim email notifikasi
        if (statusChanged) {
          await EmailService.sendStatusChangeEmail(
            reservation: reservation,
            previousStatus: oldReservation.status.displayName,
          );
        }

        // Update local list
        final index = _reservations.indexWhere((r) => r.id == reservation.id);
        if (index != -1) {
          _reservations[index] = reservation;
        }

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mengupdate reservasi';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hapus reservasi
  Future<bool> deleteReservation(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final dbSuccess = await ReservationDatabaseService.deleteReservation(id);

      if (dbSuccess) {
        _reservations.removeWhere((r) => r.id == id);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal menghapus reservasi';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Dapatkan reservasi berdasarkan ID
  Reservation? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Dapatkan reservasi berdasarkan status
  List<Reservation> getReservationsByStatus(ReservationStatus status) {
    return _reservations.where((r) => r.status == status).toList();
  }

  /// Dapatkan reservasi yang akan datang
  List<Reservation> getUpcomingReservations() {
    final now = DateTime.now();
    return _reservations
        .where((r) =>
            r.reservationDate.isAfter(now) &&
            r.status != ReservationStatus.cancelled)
        .toList()
      ..sort((a, b) => a.reservationDate.compareTo(b.reservationDate));
  }

  /// Dapatkan reservasi berdasarkan tanggal
  List<Reservation> getReservationsByDate(DateTime date) {
    return _reservations
        .where((r) =>
            r.reservationDate.year == date.year &&
            r.reservationDate.month == date.month &&
            r.reservationDate.day == date.day)
        .toList();
  }

  /// Refresh data dari server
  Future<void> refresh() async {
    await init();
  }
}
