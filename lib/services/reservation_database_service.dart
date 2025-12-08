import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation.dart';

class ReservationDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'reservations';

  /// Menyimpan reservasi baru ke database
  static Future<bool> createReservation(Reservation reservation) async {
    try {
      await _supabase.from(_tableName).insert(
        reservation.toMap(),
      );
      print('Reservasi berhasil disimpan: ${reservation.id}');
      return true;
    } catch (e) {
      print('Error menyimpan reservasi: $e');
      return false;
    }
  }

  /// Mendapatkan semua reservasi
  static Future<List<Reservation>> getAllReservations() async {
    try {
      final response =
          await _supabase.from(_tableName).select().order('reservationDate');

      final reservations = (response as List)
          .map((item) => Reservation.fromMap(item as Map<String, dynamic>))
          .toList();

      return reservations;
    } catch (e) {
      print('Error mengambil reservasi: $e');
      return [];
    }
  }

  /// Mendapatkan reservasi berdasarkan tanggal
  static Future<List<Reservation>> getReservationsByDate(DateTime date) async {
    try {
      final dateStr = date.toString().split(' ')[0]; // Format: YYYY-MM-DD

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('reservationDate', dateStr)
          .order('reservationTime');

      final reservations = (response as List)
          .map((item) => Reservation.fromMap(item as Map<String, dynamic>))
          .toList();

      return reservations;
    } catch (e) {
      print('Error mengambil reservasi berdasarkan tanggal: $e');
      return [];
    }
  }

  /// Mendapatkan reservasi berdasarkan ID
  static Future<Reservation?> getReservationById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Reservation.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error mengambil reservasi berdasarkan ID: $e');
      return null;
    }
  }

  /// Update reservasi
  static Future<bool> updateReservation(Reservation reservation) async {
    try {
      await _supabase
          .from(_tableName)
          .update(reservation.toMap())
          .eq('id', reservation.id);

      print('Reservasi berhasil diupdate: ${reservation.id}');
      return true;
    } catch (e) {
      print('Error mengupdate reservasi: $e');
      return false;
    }
  }

  /// Menghapus reservasi
  static Future<bool> deleteReservation(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      print('Reservasi berhasil dihapus: $id');
      return true;
    } catch (e) {
      print('Error menghapus reservasi: $e');
      return false;
    }
  }

  /// Mendapatkan reservasi untuk periode tertentu
  static Future<List<Reservation>> getReservationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = startDate.toString().split(' ')[0];
      final endStr = endDate.toString().split(' ')[0];

      final response = await _supabase
          .from(_tableName)
          .select()
          .gte('reservationDate', startStr)
          .lte('reservationDate', endStr)
          .order('reservationDate');

      final reservations = (response as List)
          .map((item) => Reservation.fromMap(item as Map<String, dynamic>))
          .toList();

      return reservations;
    } catch (e) {
      print('Error mengambil reservasi berdasarkan range: $e');
      return [];
    }
  }

  /// Real-time listener untuk reservasi (opsional - untuk future use)
  /// Implementasi real-time dapat dikembangkan lebih lanjut
  static Stream<List<Reservation>> watchReservations() {
    // Note: Supabase Flutter SDK memiliki API real-time yang berbeda
    // Untuk sekarang, gunakan polling atau listen pada stream data
    // Contoh implementasi dapat dilihat di dokumentasi Supabase Flutter
    throw UnimplementedError(
        'Real-time listening belum diimplementasikan. Gunakan refresh() untuk update manual.');
  }
}
