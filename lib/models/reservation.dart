import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Reservation {
  final String id;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final DateTime reservationDate;
  final TimeOfDay reservationTime;
  final int numberOfGuests;
  final String specialRequests;
  final ReservationStatus status;
  final DateTime createdAt;
  final bool hasArrived; // Untuk tracking apakah tamu sudah datang
  final String? tableId; // ID meja yang direservasi
  final List<Map<String, dynamic>>? orderedItems; // Menu items yang dipesan
  final String verificationCode; // Kode verifikasi 6 digit untuk akses detail
  final double? rating; // Rating dari tamu (1-5 bintang)

  Reservation({
    String? id,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfGuests,
    this.specialRequests = '',
    this.status = ReservationStatus.pending,
    this.hasArrived = false,
    this.tableId,
    this.orderedItems,
    String? verificationCode,
    this.rating,
    DateTime? createdAt,
  })  : id = id ?? Uuid().v4(),
        verificationCode = verificationCode ?? _generateVerificationCode(),
        createdAt = createdAt ?? DateTime.now();

  // Generate 6-digit verification code
  static String _generateVerificationCode() {
    return List<String>.generate(6, (i) => 
      (DateTime.now().millisecondsSinceEpoch + i).remainder(10).toString()
    ).join();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'reservationDate': reservationDate.toIso8601String(),
      'reservationTime': '${reservationTime.hour}:${reservationTime.minute}',
      'numberOfGuests': numberOfGuests,
      'specialRequests': specialRequests,
      'status': status.index,
      'hasArrived': hasArrived,
      'tableId': tableId,
      'orderedItems': orderedItems ?? [],
      'verificationCode': verificationCode,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    try {
      final timeStr = map['reservationTime'] as String? ?? '12:00';
      final timeParts = timeStr.split(':');
      return Reservation(
        id: map['id'] as String? ?? Uuid().v4(),
        guestName: map['guestName'] as String? ?? 'Unknown',
        guestEmail: map['guestEmail'] as String? ?? '',
        guestPhone: map['guestPhone'] as String? ?? '',
        reservationDate: map['reservationDate'] != null
            ? DateTime.parse(map['reservationDate'] as String)
            : DateTime.now(),
        reservationTime: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
        numberOfGuests: map['numberOfGuests'] as int? ?? 1,
        specialRequests: map['specialRequests'] as String? ?? '',
        status: ReservationStatus.values[(map['status'] as int?) ?? 0],
        hasArrived: map['hasArrived'] as bool? ?? false,
        tableId: map['tableId'] as String?,
        orderedItems: List<Map<String, dynamic>>.from(
          (map['orderedItems'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        ),
        verificationCode: map['verificationCode'] as String? ?? Reservation._generateVerificationCode(),
        rating: map['rating'] as double?,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Reservation: $e');
      return Reservation(
        guestName: 'Unknown',
        guestEmail: '',
        guestPhone: '',
        reservationDate: DateTime.now(),
        reservationTime: const TimeOfDay(hour: 12, minute: 0),
        numberOfGuests: 1,
      );
    }
  }

  factory Reservation.empty() {
    return Reservation(
      id: '',
      guestName: '',
      guestEmail: '',
      guestPhone: '',
      reservationDate: DateTime.now(),
      reservationTime: const TimeOfDay(hour: 0, minute: 0),
      numberOfGuests: 0,
    );
  }

  Reservation copyWith({
    String? id,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    DateTime? reservationDate,
    TimeOfDay? reservationTime,
    int? numberOfGuests,
    String? specialRequests,
    ReservationStatus? status,
    bool? hasArrived,
    String? tableId,
    List<Map<String, dynamic>>? orderedItems,
    String? verificationCode,
    double? rating,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      reservationDate: reservationDate ?? this.reservationDate,
      reservationTime: reservationTime ?? this.reservationTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      hasArrived: hasArrived ?? this.hasArrived,
      tableId: tableId ?? this.tableId,
      orderedItems: orderedItems ?? this.orderedItems,
      verificationCode: verificationCode ?? this.verificationCode,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

extension ReservationStatusExtension on ReservationStatus {
  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'Tertunda';
      case ReservationStatus.confirmed:
        return 'Terkonfirmasi';
      case ReservationStatus.completed:
        return 'Selesai';
      case ReservationStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatus.pending:
        return const Color(0xFFFFA500); // Orange
      case ReservationStatus.confirmed:
        return const Color(0xFF4CAF50); // Green
      case ReservationStatus.completed:
        return const Color(0xFF2196F3); // Blue
      case ReservationStatus.cancelled:
        return const Color(0xFFF44336); // Red
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String to24hourFormat() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
