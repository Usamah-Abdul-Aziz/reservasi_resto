import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DateTimeUtils {
  /// Format tanggal ke format Indonesia
  static String formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal singkat
  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format waktu 24 jam
  static String formatTime24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format tanggal dan waktu lengkap
  static String formatDateTime(DateTime date, TimeOfDay time) {
    return '${formatDate(date)} - ${formatTime24Hour(time)}';
  }

  /// Cek apakah tanggal sudah berlalu
  static bool isDatePassed(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Hitung selisih hari dari hari ini
  static int getDaysFromNow(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// Format selisih waktu (e.g., "Dalam 3 hari", "Hari ini")
  static String formatTimeUntil(DateTime date) {
    final days = getDaysFromNow(date);
    if (days < 0) {
      return 'Sudah berlalu';
    } else if (days == 0) {
      return 'Hari ini';
    } else if (days == 1) {
      return 'Besok';
    } else if (days < 7) {
      return 'Dalam $days hari';
    } else if (days < 30) {
      final weeks = (days / 7).ceil();
      return 'Dalam $weeks minggu';
    } else {
      final months = (days / 30).ceil();
      return 'Dalam $months bulan';
    }
  }
}

class ValidationUtils {
  /// Validasi email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validasi nomor telepon (Indonesia)
  static bool isValidPhoneNumber(String phone) {
    // Format: +62, 62, atau 0 diikuti 9-12 digit
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    return phoneRegex.hasMatch(phone.replaceAll('-', '').replaceAll(' ', ''));
  }

  /// Validasi nama (minimal 3 karakter, hanya huruf dan spasi)
  static bool isValidName(String name) {
    final nameRegex = RegExp(r'^[a-zA-Z\s]{3,}$');
    return nameRegex.hasMatch(name.trim());
  }

  /// Validasi teks tidak kosong
  static bool isNotEmpty(String text) {
    return text.trim().isNotEmpty;
  }

  /// Validasi jumlah tamu (1-20)
  static bool isValidGuestCount(int count) {
    return count >= 1 && count <= 20;
  }
}

class StringUtils {
  /// Capitalize kata pertama
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize setiap kata
  static String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }

  /// Truncate teks dengan ellipsis
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Format nomor dengan separator ribuan
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => '.',
    );
  }
}

class PhoneUtils {
  /// Format nomor telepon Indonesia
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('0')) {
      return '+62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('62')) {
      return '+$cleaned';
    }
    return cleaned;
  }

  /// Dapatkan nomor telepon dalam format lokal
  static String toLocalFormat(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+62')) {
      return '0${cleaned.substring(3)}';
    } else if (cleaned.startsWith('62')) {
      return '0${cleaned.substring(2)}';
    }
    return cleaned;
  }
}
