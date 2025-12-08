import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation.dart';

class EmailService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengirim email verifikasi untuk reservasi
  static Future<bool> sendVerificationEmail({
    required Reservation reservation,
  }) async {
    try {
      // Panggil Supabase Edge Function untuk mengirim email
      final response = await _supabase.functions.invoke(
        'send_verification_email',
        body: {
          'guestEmail': reservation.guestEmail,
          'guestName': reservation.guestName,
          'verificationCode': reservation.verificationCode,
          'reservationId': reservation.id,
          'reservationDate': reservation.reservationDate.toIso8601String(),
          'reservationTime':
              '${reservation.reservationTime.hour.toString().padLeft(2, '0')}:${reservation.reservationTime.minute.toString().padLeft(2, '0')}',
        },
      );

      // Cek apakah response berhasil
      if (response.status == 200) {
        print('Email verifikasi berhasil dikirim ke ${reservation.guestEmail}');
        return true;
      } else {
        print('Gagal mengirim email: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error mengirim email: $e');
      return false;
    }
  }

  /// Mengirim email konfirmasi ketika reservasi diubah
  static Future<bool> sendStatusChangeEmail({
    required Reservation reservation,
    required String previousStatus,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send_status_change_email',
        body: {
          'guestEmail': reservation.guestEmail,
          'guestName': reservation.guestName,
          'newStatus': reservation.status.displayName,
          'previousStatus': previousStatus,
          'reservationId': reservation.id,
        },
      );

      if (response.status == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error mengirim email status change: $e');
      return false;
    }
  }

  /// Mengirim email notification untuk admin
  static Future<bool> sendAdminNotification({
    required String adminEmail,
    required Reservation reservation,
    required String eventType, // 'new_reservation', 'status_changed', 'cancelled'
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send_admin_notification',
        body: {
          'adminEmail': adminEmail,
          'guestName': reservation.guestName,
          'guestEmail': reservation.guestEmail,
          'eventType': eventType,
          'reservationId': reservation.id,
          'reservationDate': reservation.reservationDate.toIso8601String(),
        },
      );

      if (response.status == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error mengirim notifikasi admin: $e');
      return false;
    }
  }
}
