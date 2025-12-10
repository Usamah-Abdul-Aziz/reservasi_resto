import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';

class EmailService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Email admin untuk notifikasi - ganti sesuai kebutuhan
  static const String adminEmail = 'ikmal.usamah@gmail.com';

  /// Mengirim email verifikasi untuk reservasi
  static Future<bool> sendVerificationEmail({
    required Reservation reservation,
  }) async {
    try {
      final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      
      final response = await _supabase.functions.invoke(
        'send_verification_email',
        body: {
          'guestEmail': reservation.guestEmail,
          'guestName': reservation.guestName,
          'verificationCode': reservation.verificationCode,
          'reservationId': reservation.id,
          'reservationDate': dateFormat.format(reservation.reservationDate),
          'reservationTime': reservation.reservationTime.to24hourFormat(),
        },
      );

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

  /// Mengirim email notifikasi ketika status reservasi berubah
  static Future<bool> sendStatusChangeEmail({
    required Reservation reservation,
    required String previousStatus,
  }) async {
    try {
      final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      
      final response = await _supabase.functions.invoke(
        'send_status_change_email',
        body: {
          'guestEmail': reservation.guestEmail,
          'guestName': reservation.guestName,
          'newStatus': reservation.status.displayName,
          'previousStatus': previousStatus,
          'reservationDate': dateFormat.format(reservation.reservationDate),
          'reservationTime': reservation.reservationTime.to24hourFormat(),
          'tableNumber': reservation.tableId,
        },
      );

      if (response.status == 200) {
        print('Email status change berhasil dikirim');
        return true;
      } else {
        print('Gagal mengirim email status: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error mengirim email status change: $e');
      return false;
    }
  }

  /// Mengirim email notifikasi ke admin untuk reservasi baru
  static Future<bool> sendAdminNotification({
    required Reservation reservation,
    String? customAdminEmail,
  }) async {
    try {
      final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      
      final response = await _supabase.functions.invoke(
        'send_admin_notification',
        body: {
          'guestName': reservation.guestName,
          'guestEmail': reservation.guestEmail,
          'guestPhone': reservation.guestPhone,
          'reservationDate': dateFormat.format(reservation.reservationDate),
          'reservationTime': reservation.reservationTime.to24hourFormat(),
          'numberOfGuests': reservation.numberOfGuests,
          'tableNumber': reservation.tableId,
          'specialRequests': reservation.specialRequests,
          'adminEmail': customAdminEmail ?? adminEmail,
        },
      );

      if (response.status == 200) {
        print('Notifikasi admin berhasil dikirim');
        return true;
      } else {
        print('Gagal mengirim notifikasi admin: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error mengirim notifikasi admin: $e');
      return false;
    }
  }

  /// Mengirim email reminder H-3 jam sebelum reservasi
  static Future<bool> sendReminderEmail({
    required Reservation reservation,
  }) async {
    try {
      final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      
      final response = await _supabase.functions.invoke(
        'send_reminder_email',
        body: {
          'guestEmail': reservation.guestEmail,
          'guestName': reservation.guestName,
          'reservationDate': dateFormat.format(reservation.reservationDate),
          'reservationTime': reservation.reservationTime.to24hourFormat(),
          'numberOfGuests': reservation.numberOfGuests,
          'tableNumber': reservation.tableId,
          'verificationCode': reservation.verificationCode,
        },
      );

      if (response.status == 200) {
        print('Email reminder berhasil dikirim');
        return true;
      } else {
        print('Gagal mengirim reminder: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error mengirim reminder: $e');
      return false;
    }
  }
}
