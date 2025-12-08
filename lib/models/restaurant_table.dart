import 'package:uuid/uuid.dart';

enum TableStatus {
  available,    // Meja kosong siap digunakan
  occupied,     // Meja sedang terisi
  reserved,     // Meja sudah direservasi
  maintenance,  // Meja sedang diperbaiki
}

extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Tersedia';
      case TableStatus.occupied:
        return 'Terisi';
      case TableStatus.reserved:
        return 'Direservasi';
      case TableStatus.maintenance:
        return 'Pemeliharaan';
    }
  }

  String get emoji {
    switch (this) {
      case TableStatus.available:
        return '✅';
      case TableStatus.occupied:
        return '🔴';
      case TableStatus.reserved:
        return '🟡';
      case TableStatus.maintenance:
        return '🔧';
    }
  }
}

class RestaurantTable {
  final String id;
  final int tableNumber;      // Nomor meja (1, 2, 3, dst)
  final int capacity;         // Jumlah kursi (2, 4, 6, dst)
  final TableStatus status;
  final String? reservationId; // ID reservasi jika sedang direservasi
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantTable({
    String? id,
    required this.tableNumber,
    required this.capacity,
    this.status = TableStatus.available,
    this.reservationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cek apakah meja bisa digunakan untuk reservasi
  bool canBeReserved() {
    return status == TableStatus.available || status == TableStatus.occupied;
  }

  /// Cek apakah meja cocok untuk jumlah tamu
  bool isSuitableFor(int numberOfGuests) {
    return capacity >= numberOfGuests;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': status.index,
      'reservationId': reservationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    try {
      return RestaurantTable(
        id: map['id'] as String? ?? Uuid().v4(),
        tableNumber: map['tableNumber'] as int? ?? 1,
        capacity: map['capacity'] as int? ?? 2,
        status: TableStatus.values[(map['status'] as int?) ?? 0],
        reservationId: map['reservationId'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing RestaurantTable: $e');
      return RestaurantTable(
        tableNumber: 1,
        capacity: 2,
      );
    }
  }

  RestaurantTable copyWith({
    String? id,
    int? tableNumber,
    int? capacity,
    TableStatus? status,
    String? reservationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      reservationId: reservationId ?? this.reservationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantTable &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
