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

enum TableLocation {
  indoor,
  outdoor,
  vip,
  privateRoom,
}

extension TableLocationExtension on TableLocation {
  String get displayName {
    switch (this) {
      case TableLocation.indoor:
        return 'Indoor';
      case TableLocation.outdoor:
        return 'Outdoor';
      case TableLocation.vip:
        return 'VIP';
      case TableLocation.privateRoom:
        return 'Private Room';
    }
  }

  String get emoji {
    switch (this) {
      case TableLocation.indoor:
        return '🏠';
      case TableLocation.outdoor:
        return '🌳';
      case TableLocation.vip:
        return '⭐';
      case TableLocation.privateRoom:
        return '🚪';
    }
  }
}

class RestaurantTable {
  final String id;
  final String tableNumber;   // Nomor meja (A1, B2, VIP1, dst)
  final int capacity;         // Jumlah kursi (2, 4, 6, dst)
  final TableLocation location;
  final TableStatus status;
  final String description;
  final bool isActive;
  final String? reservationId; // ID reservasi jika sedang direservasi
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantTable({
    String? id,
    required this.tableNumber,
    required this.capacity,
    this.location = TableLocation.indoor,
    this.status = TableStatus.available,
    this.description = '',
    this.isActive = true,
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
      'location': location.index,
      'status': status.index,
      'description': description,
      'isActive': isActive,
      'reservationId': reservationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    try {
      return RestaurantTable(
        id: map['id'] as String? ?? Uuid().v4(),
        tableNumber: map['tableNumber']?.toString() ?? '1',
        capacity: map['capacity'] as int? ?? 2,
        location: TableLocation.values[(map['location'] as int?) ?? 0],
        status: TableStatus.values[(map['status'] as int?) ?? 0],
        description: map['description'] as String? ?? '',
        isActive: map['isActive'] as bool? ?? true,
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
        tableNumber: '1',
        capacity: 2,
      );
    }
  }

  RestaurantTable copyWith({
    String? id,
    String? tableNumber,
    int? capacity,
    TableLocation? location,
    TableStatus? status,
    String? description,
    bool? isActive,
    String? reservationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      location: location ?? this.location,
      status: status ?? this.status,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
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
