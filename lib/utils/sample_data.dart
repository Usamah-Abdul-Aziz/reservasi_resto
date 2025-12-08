import 'package:flutter/material.dart';
import '../models/reservation.dart';

class SampleData {
  /// Generate sample reservasi untuk testing
  static List<Reservation> generateSampleReservations() {
    final now = DateTime.now();
    return [
      Reservation(
        guestName: 'Ahmad Rahman',
        guestEmail: 'ahmad@email.com',
        guestPhone: '081234567890',
        reservationDate: now.add(const Duration(days: 3)),
        reservationTime: const TimeOfDay(hour: 19, minute: 0),
        numberOfGuests: 4,
        specialRequests: 'Meja dekat jendela',
        status: ReservationStatus.confirmed,
      ),
      Reservation(
        guestName: 'Siti Nurhaliza',
        guestEmail: 'siti@email.com',
        guestPhone: '082345678901',
        reservationDate: now.add(const Duration(days: 7)),
        reservationTime: const TimeOfDay(hour: 12, minute: 30),
        numberOfGuests: 2,
        specialRequests: '',
        status: ReservationStatus.pending,
      ),
      Reservation(
        guestName: 'Budi Santoso',
        guestEmail: 'budi@email.com',
        guestPhone: '083456789012',
        reservationDate: now.subtract(const Duration(days: 2)),
        reservationTime: const TimeOfDay(hour: 20, minute: 0),
        numberOfGuests: 6,
        specialRequests: 'Pesan kue ulang tahun',
        status: ReservationStatus.completed,
      ),
      Reservation(
        guestName: 'Dewi Lestari',
        guestEmail: 'dewi@email.com',
        guestPhone: '084567890123',
        reservationDate: now.subtract(const Duration(days: 5)),
        reservationTime: const TimeOfDay(hour: 18, minute: 45),
        numberOfGuests: 3,
        specialRequests: 'Tidak makan pedas',
        status: ReservationStatus.cancelled,
      ),
      Reservation(
        guestName: 'Eko Wibowo',
        guestEmail: 'eko@email.com',
        guestPhone: '085678901234',
        reservationDate: now.add(const Duration(days: 1)),
        reservationTime: const TimeOfDay(hour: 15, minute: 0),
        numberOfGuests: 2,
        specialRequests: '',
        status: ReservationStatus.confirmed,
      ),
    ];
  }
}
