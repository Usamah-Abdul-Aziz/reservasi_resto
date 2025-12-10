import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/restaurant_table.dart';
import '../services/table_database_service.dart';

class TableProvider extends ChangeNotifier {
  List<RestaurantTable> _tables = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _useSupabase = true; // Flag untuk menggunakan Supabase

  List<RestaurantTable> get tables => _tables;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    if (_isInitialized) return; // Prevent multiple initializations
    _prefs = await SharedPreferences.getInstance();
    
    _isLoading = true;
    notifyListeners();
    
    // Coba load dari Supabase dulu
    if (_useSupabase) {
      try {
        final supabaseTables = await TableDatabaseService.getAllTables();
        if (supabaseTables.isNotEmpty) {
          _tables = supabaseTables;
          _tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
          print('Loaded ${_tables.length} tables from Supabase');
        } else {
          // Jika kosong, load dari local atau buat default
          _loadTablesFromLocal();
        }
      } catch (e) {
        print('Error loading from Supabase, falling back to local: $e');
        _loadTablesFromLocal();
      }
    } else {
      _loadTablesFromLocal();
    }
    
    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  void _loadTablesFromLocal() {
    final savedTables = _prefs.getStringList('tables') ?? [];
    if (savedTables.isEmpty) {
      // Buat tabel default jika belum ada
      _createDefaultTables();
    } else {
      _tables = savedTables
          .map((json) => RestaurantTable.fromMap(jsonDecode(json)))
          .toList();
      _tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    }
  }

  void _createDefaultTables() {
    // Indoor Tables (2 kursi)
    for (int i = 1; i <= 2; i++) {
      _tables.add(
        RestaurantTable(
          tableNumber: 'A$i',
          capacity: 2,
          location: TableLocation.indoor,
          status: TableStatus.available,
          description: 'Meja indoor untuk 2 orang',
        ),
      );
    }
    // Indoor Tables (4 kursi)
    for (int i = 3; i <= 5; i++) {
      _tables.add(
        RestaurantTable(
          tableNumber: 'A$i',
          capacity: 4,
          location: TableLocation.indoor,
          status: TableStatus.available,
          description: 'Meja indoor untuk 4 orang',
        ),
      );
    }
    // Outdoor Tables
    for (int i = 1; i <= 4; i++) {
      _tables.add(
        RestaurantTable(
          tableNumber: 'B$i',
          capacity: i <= 2 ? 2 : 4,
          location: TableLocation.outdoor,
          status: TableStatus.available,
          description: 'Meja outdoor dengan pemandangan',
        ),
      );
    }
    // VIP Tables
    for (int i = 1; i <= 3; i++) {
      _tables.add(
        RestaurantTable(
          tableNumber: 'VIP$i',
          capacity: 4 + (i * 2),
          location: TableLocation.vip,
          status: TableStatus.available,
          description: 'Ruang VIP eksklusif',
        ),
      );
    }
    _saveTables();
  }

  Future<void> _saveTables() async {
    final jsonList = _tables
        .map((table) => jsonEncode(table.toMap()))
        .toList();
    await _prefs.setStringList('tables', jsonList);
  }

  // CRUD Operations
  Future<void> addTable(RestaurantTable table) async {
    _tables.add(table);
    _tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    await _saveTables();
    notifyListeners();
  }

  Future<void> updateTable(RestaurantTable table) async {
    final index = _tables.indexWhere((t) => t.id == table.id);
    if (index != -1) {
      _tables[index] = table;
      _tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
      await _saveTables();
      notifyListeners();
    }
  }

  Future<void> deleteTable(String id) async {
    _tables.removeWhere((t) => t.id == id);
    await _saveTables();
    notifyListeners();
  }

  // Cari meja kosong yang cocok untuk jumlah tamu
  // Jika tidak ada meja kosong yang cocok, kembalikan meja yang sudah reserved tapi masih bisa di-share
  RestaurantTable? findAvailableTable(int numberOfGuests) {
    // Pertama cari meja available dengan kapasitas sesuai
    final availableTables = _tables
        .where((t) =>
            t.status == TableStatus.available &&
            t.isSuitableFor(numberOfGuests))
        .toList();

    if (availableTables.isNotEmpty) {
      // Prioritas: cari meja dengan kapasitas terdekat
      availableTables.sort((a, b) => a.capacity.compareTo(b.capacity));
      return availableTables.first;
    }

    // Jika tidak ada meja kosong yang cocok, cari semua meja yang cocok (termasuk reserved/occupied)
    // karena beberapa meja bisa berbagi banyak tamu
    final suitableTables = _tables
        .where((t) =>
            t.status != TableStatus.maintenance &&
            t.isSuitableFor(numberOfGuests))
        .toList();

    if (suitableTables.isNotEmpty) {
      // Prioritas: cari meja dengan kapasitas terdekat
      suitableTables.sort((a, b) => a.capacity.compareTo(b.capacity));
      return suitableTables.first;
    }

    return null;
  }

  // Cari semua meja yang cocok untuk jumlah tamu
  List<RestaurantTable> findSuitableTables(int numberOfGuests) {
    return _tables
        .where((t) => t.isSuitableFor(numberOfGuests))
        .toList()
        ..sort((a, b) => a.capacity.compareTo(b.capacity));
  }

  // Reserve meja untuk reservasi
  Future<bool> reserveTable(String tableId, String reservationId) async {
    final table = _tables.firstWhere((t) => t.id == tableId);
    await updateTable(
      table.copyWith(
        status: TableStatus.reserved,
        reservationId: reservationId,
      ),
    );
    return true;
  }

  // Kosongkan meja (setelah reservasi dibatalkan atau selesai)
  Future<void> releaseTable(String tableId) async {
    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index != -1) {
      final table = _tables[index];
      await updateTable(
        table.copyWith(
          status: TableStatus.available,
          reservationId: null,
        ),
      );
    }
  }

  // Ubah status meja menjadi terisi (ketika tamu tiba)
  Future<void> markTableAsOccupied(String tableId) async {
    final table = _tables.firstWhere((t) => t.id == tableId);
    await updateTable(
      table.copyWith(status: TableStatus.occupied),
    );
  }

  // Ubah status meja menjadi tersedia (ketika tamu pergi)
  Future<void> markTableAsAvailable(String tableId) async {
    final table = _tables.firstWhere((t) => t.id == tableId);
    await updateTable(
      table.copyWith(status: TableStatus.available, reservationId: null),
    );
  }

  // Dapatkan meja berdasarkan ID
  RestaurantTable? getTableById(String id) {
    try {
      return _tables.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Dapatkan tabel berdasarkan reservation ID
  RestaurantTable? getTableByReservationId(String reservationId) {
    try {
      return _tables.firstWhere((t) => t.reservationId == reservationId);
    } catch (e) {
      return null;
    }
  }

  // Statistik meja
  int get totalTables => _tables.length;
  int get availableTables => _tables.where((t) => t.status == TableStatus.available).length;
  int get occupiedTables => _tables.where((t) => t.status == TableStatus.occupied).length;
  int get reservedTables => _tables.where((t) => t.status == TableStatus.reserved).length;

  int get totalCapacity => _tables.fold<int>(0, (sum, t) => sum + t.capacity);

  // Get tables by location
  List<RestaurantTable> getTablesByLocation(TableLocation location) {
    return _tables.where((t) => t.location == location).toList();
  }

  // Get all available locations
  List<TableLocation> get availableLocations {
    return _tables.map((t) => t.location).toSet().toList();
  }

  // Refresh dari Supabase
  Future<void> refresh() async {
    if (!_useSupabase) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final supabaseTables = await TableDatabaseService.getAllTables();
      if (supabaseTables.isNotEmpty) {
        _tables = supabaseTables;
        _tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
        print('Refreshed ${_tables.length} tables from Supabase');
      }
    } catch (e) {
      print('Error refreshing tables: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
