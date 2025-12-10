import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_table.dart';

class TableDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'restaurant_tables';
  static const String _tableReservationsTable = 'table_reservations';

  /// Mendapatkan semua meja
  static Future<List<RestaurantTable>> getAllTables() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('isActive', true)
          .order('tableNumber');

      final tables = (response as List).map((item) {
        return RestaurantTable(
          id: item['id'] as String,
          tableNumber: item['tableNumber'] as String,
          capacity: item['capacity'] as int,
          location: _mapLocation(item['location'] as String),
          status: _mapStatus(item['status'] as String),
          description: item['description'] as String? ?? '',
          isActive: item['isActive'] as bool? ?? true,
        );
      }).toList();

      print('Loaded ${tables.length} tables from Supabase');
      return tables;
    } catch (e) {
      print('Error loading tables: $e');
      return [];
    }
  }

  /// Mendapatkan meja yang tersedia untuk kapasitas tertentu
  static Future<List<RestaurantTable>> getAvailableTables({
    required int minCapacity,
    DateTime? date,
    String? timeSlot,
  }) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .eq('isActive', true)
          .eq('status', 'available')
          .gte('capacity', minCapacity);

      final response = await query.order('capacity').order('tableNumber');

      // Jika ada date dan time, filter meja yang sudah direservasi
      List<RestaurantTable> tables = (response as List).map((item) {
        return RestaurantTable(
          id: item['id'] as String,
          tableNumber: item['tableNumber'] as String,
          capacity: item['capacity'] as int,
          location: _mapLocation(item['location'] as String),
          status: _mapStatus(item['status'] as String),
          description: item['description'] as String? ?? '',
          isActive: item['isActive'] as bool? ?? true,
        );
      }).toList();

      if (date != null && timeSlot != null) {
        // Filter meja yang sudah direservasi pada waktu tersebut
        final reservedTableIds = await _getReservedTableIds(date, timeSlot);
        tables = tables.where((t) => !reservedTableIds.contains(t.id)).toList();
      }

      return tables;
    } catch (e) {
      print('Error getting available tables: $e');
      return [];
    }
  }

  /// Mendapatkan meja berdasarkan lokasi
  static Future<List<RestaurantTable>> getTablesByLocation(TableLocation location) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('isActive', true)
          .eq('location', _locationToString(location))
          .order('tableNumber');

      return (response as List).map((item) {
        return RestaurantTable(
          id: item['id'] as String,
          tableNumber: item['tableNumber'] as String,
          capacity: item['capacity'] as int,
          location: _mapLocation(item['location'] as String),
          status: _mapStatus(item['status'] as String),
          description: item['description'] as String? ?? '',
          isActive: item['isActive'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error getting tables by location: $e');
      return [];
    }
  }

  /// Update status meja
  static Future<bool> updateTableStatus(String tableId, TableStatus status) async {
    try {
      await _supabase.from(_tableName).update({
        'status': _statusToString(status),
      }).eq('id', tableId);
      return true;
    } catch (e) {
      print('Error updating table status: $e');
      return false;
    }
  }

  /// Reservasi meja untuk reservasi tertentu
  static Future<bool> reserveTable({
    required String tableId,
    required String reservationId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      await _supabase.from(_tableReservationsTable).insert({
        'tableId': tableId,
        'reservationId': reservationId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error reserving table: $e');
      return false;
    }
  }

  /// Batalkan reservasi meja
  static Future<bool> cancelTableReservation(String reservationId) async {
    try {
      await _supabase
          .from(_tableReservationsTable)
          .delete()
          .eq('reservationId', reservationId);
      return true;
    } catch (e) {
      print('Error canceling table reservation: $e');
      return false;
    }
  }

  /// Tambah meja baru
  static Future<bool> createTable(RestaurantTable table) async {
    try {
      await _supabase.from(_tableName).insert({
        'id': table.id,
        'tableNumber': table.tableNumber,
        'capacity': table.capacity,
        'location': _locationToString(table.location),
        'status': _statusToString(table.status),
        'description': table.description,
        'isActive': table.isActive,
      });
      return true;
    } catch (e) {
      print('Error creating table: $e');
      return false;
    }
  }

  /// Update meja
  static Future<bool> updateTable(RestaurantTable table) async {
    try {
      await _supabase.from(_tableName).update({
        'tableNumber': table.tableNumber,
        'capacity': table.capacity,
        'location': _locationToString(table.location),
        'status': _statusToString(table.status),
        'description': table.description,
        'isActive': table.isActive,
      }).eq('id', table.id);
      return true;
    } catch (e) {
      print('Error updating table: $e');
      return false;
    }
  }

  /// Delete meja (soft delete - set isActive = false)
  static Future<bool> deleteTable(String id) async {
    try {
      await _supabase.from(_tableName).update({
        'isActive': false,
      }).eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting table: $e');
      return false;
    }
  }

  /// Helper: Mendapatkan ID meja yang sudah direservasi pada waktu tertentu
  static Future<Set<String>> _getReservedTableIds(DateTime date, String timeSlot) async {
    try {
      final timeParts = timeSlot.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final startTime = DateTime(date.year, date.month, date.day, hour, minute);
      final endTime = startTime.add(const Duration(hours: 2)); // Asumsi durasi 2 jam

      final response = await _supabase
          .from(_tableReservationsTable)
          .select('tableId')
          .lte('startTime', endTime.toIso8601String())
          .gte('endTime', startTime.toIso8601String());

      return (response as List)
          .map((item) => item['tableId'] as String)
          .toSet();
    } catch (e) {
      print('Error getting reserved table IDs: $e');
      return {};
    }
  }

  /// Helper: Map string to TableLocation
  static TableLocation _mapLocation(String location) {
    switch (location.toLowerCase()) {
      case 'indoor':
        return TableLocation.indoor;
      case 'outdoor':
        return TableLocation.outdoor;
      case 'vip':
        return TableLocation.vip;
      case 'private':
        return TableLocation.privateRoom;
      default:
        return TableLocation.indoor;
    }
  }

  /// Helper: Map TableLocation to string
  static String _locationToString(TableLocation location) {
    switch (location) {
      case TableLocation.indoor:
        return 'indoor';
      case TableLocation.outdoor:
        return 'outdoor';
      case TableLocation.vip:
        return 'vip';
      case TableLocation.privateRoom:
        return 'private';
    }
  }

  /// Helper: Map string to TableStatus
  static TableStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'maintenance':
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }

  /// Helper: Map TableStatus to string
  static String _statusToString(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.reserved:
        return 'reserved';
      case TableStatus.maintenance:
        return 'maintenance';
    }
  }
}
