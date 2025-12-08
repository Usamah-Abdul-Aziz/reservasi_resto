import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/menu_item.dart';

/// Provider untuk mengelola Menu Items dan Availability
class MenuProvider extends ChangeNotifier {
  List<MenuItem> _menuItems = [];
  List<MenuItemAvailability> _availability = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<MenuItem> get menuItems => _menuItems;
  List<MenuItemAvailability> get availability => _availability;
  bool get isInitialized => _isInitialized;

  /// Initialize provider dan load data dari SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await _loadMenuItems();
    await _loadAvailability();
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Load menu items dari storage
  Future<void> _loadMenuItems() async {
    try {
      final jsonStr = _prefs.getString('menu_items');
      if (jsonStr != null) {
        final jsonList = jsonDecode(jsonStr) as List;
        _menuItems = jsonList
            .map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        // Tambah sample menu jika kosong
        _addSampleMenu();
        await _saveMenuItems();
      }
    } catch (e) {
      print('Error loading menu items: $e');
      _addSampleMenu();
    }
  }

  /// Load availability dari storage
  Future<void> _loadAvailability() async {
    try {
      final jsonStr = _prefs.getString('menu_availability');
      if (jsonStr != null) {
        final jsonList = jsonDecode(jsonStr) as List;
        _availability = jsonList
            .map((item) =>
                MenuItemAvailability.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        // Initialize availability untuk semua menu
        await _initializeAvailabilityForToday();
      }
    } catch (e) {
      print('Error loading availability: $e');
    }
  }

  /// Save menu items ke storage
  Future<void> _saveMenuItems() async {
    try {
      final jsonList = _menuItems.map((item) => item.toMap()).toList();
      await _prefs.setString('menu_items', jsonEncode(jsonList));
    } catch (e) {
      print('Error saving menu items: $e');
    }
  }

  /// Save availability ke storage
  Future<void> _saveAvailability() async {
    try {
      final jsonList = _availability.map((item) => item.toMap()).toList();
      await _prefs.setString('menu_availability', jsonEncode(jsonList));
    } catch (e) {
      print('Error saving availability: $e');
    }
  }

  /// Tambah sample menu
  void _addSampleMenu() {
    _menuItems = [
      MenuItem(
        name: 'Nasi Goreng Spesial',
        description: 'Nasi goreng dengan telur, udang, dan daging ayam pilihan',
        price: 35000,
        category: MenuCategory.mainCourse,
        isSpicy: true,
        preparationTime: 15,
      ),
      MenuItem(
        name: 'Gado-Gado',
        description: 'Sayuran segar dengan saus kacang kental dan telur rebus',
        price: 22000,
        category: MenuCategory.mainCourse,
        isVegetarian: true,
        preparationTime: 10,
      ),
      MenuItem(
        name: 'Lumpia Goreng',
        description: 'Lumpia isi daging dan sayuran dengan saus asam manis',
        price: 15000,
        category: MenuCategory.appetizer,
        preparationTime: 8,
      ),
      MenuItem(
        name: 'Es Cendol',
        description: 'Minuman dingin tradisional dengan santan dan gula merah',
        price: 12000,
        category: MenuCategory.beverage,
        isVegetarian: true,
        preparationTime: 3,
      ),
      MenuItem(
        name: 'Tahu Goreng Krispi',
        description: 'Tahu goreng dengan kulit renyah dan saus spesial',
        price: 18000,
        category: MenuCategory.sideDish,
        isVegetarian: true,
        preparationTime: 7,
      ),
      MenuItem(
        name: 'Sambal Matah',
        description: 'Sambal segar dengan bahan-bahan pilihan',
        price: 8000,
        category: MenuCategory.sauce,
        isVegetarian: true,
        preparationTime: 5,
      ),
      MenuItem(
        name: 'Pudding Cokelat',
        description: 'Pudding cokelat lembut dengan topping whipped cream',
        price: 20000,
        category: MenuCategory.dessert,
        isVegetarian: true,
        preparationTime: 5,
      ),
      MenuItem(
        name: 'Soto Ayam',
        description: 'Sup ayam dengan bumbu kuning tradisional',
        price: 28000,
        category: MenuCategory.mainCourse,
        preparationTime: 20,
      ),
    ];
  }

  /// Initialize availability untuk hari ini dengan stock awal
  Future<void> _initializeAvailabilityForToday() async {
    final today = DateTime.now();
    _availability = _menuItems
        .map((item) => MenuItemAvailability(
              menuItemId: item.id,
              date: today,
              totalStock: 50,
              soldCount: 0,
              isAvailable: true,
            ))
        .toList();
    await _saveAvailability();
  }

  /// Tambah menu item baru
  Future<void> addMenuItem(MenuItem item) async {
    _menuItems.add(item);
    
    // Tambah availability untuk hari ini
    final today = DateTime.now();
    _availability.add(MenuItemAvailability(
      menuItemId: item.id,
      date: today,
      totalStock: 50,
    ));
    
    await _saveMenuItems();
    await _saveAvailability();
    notifyListeners();
  }

  /// Update menu item
  Future<void> updateMenuItem(MenuItem item) async {
    final index = _menuItems.indexWhere((m) => m.id == item.id);
    if (index >= 0) {
      _menuItems[index] = item;
      await _saveMenuItems();
      notifyListeners();
    }
  }

  /// Delete menu item
  Future<void> deleteMenuItem(String menuItemId) async {
    _menuItems.removeWhere((m) => m.id == menuItemId);
    _availability.removeWhere((a) => a.menuItemId == menuItemId);
    await _saveMenuItems();
    await _saveAvailability();
    notifyListeners();
  }

  /// Get menu items by category
  List<MenuItem> getMenuByCategory(MenuCategory category) {
    return _menuItems.where((m) => m.category == category).toList();
  }

  /// Get all categories yang memiliki items
  List<MenuCategory> getAvailableCategories() {
    final categories = <MenuCategory>{};
    for (final item in _menuItems) {
      categories.add(item.category);
    }
    return categories.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get menu item by name
  MenuItem? getMenuItemByName(String name) {
    try {
      return _menuItems.firstWhere((m) => m.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get menu item by ID
  MenuItem? getMenuItemById(String id) {
    try {
      return _menuItems.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update sold count untuk item pada tanggal tertentu
  Future<void> updateSoldCount(String menuItemId, int newSoldCount) async {
    final index = _availability.indexWhere(
      (a) =>
          a.menuItemId == menuItemId &&
          _isSameDay(a.date, DateTime.now()),
    );
    
    if (index >= 0) {
      _availability[index] = _availability[index].copyWith(
        soldCount: newSoldCount.clamp(0, _availability[index].totalStock),
      );
      await _saveAvailability();
      notifyListeners();
    }
  }

  /// Toggle availability status
  Future<void> toggleAvailability(String menuItemId) async {
    final index = _availability.indexWhere(
      (a) =>
          a.menuItemId == menuItemId &&
          _isSameDay(a.date, DateTime.now()),
    );
    
    if (index >= 0) {
      _availability[index] = _availability[index].copyWith(
        isAvailable: !_availability[index].isAvailable,
      );
      await _saveAvailability();
      notifyListeners();
    }
  }

  /// Get availability untuk item di hari ini
  MenuItemAvailability? getAvailabilityForToday(String menuItemId) {
    final today = DateTime.now();
    try {
      return _availability.firstWhere(
        (a) => a.menuItemId == menuItemId && _isSameDay(a.date, today),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get sold out items untuk hari ini
  List<MenuItem> getSoldOutItems() {
    final today = DateTime.now();
    final soldOutIds = _availability
        .where((a) => _isSameDay(a.date, today) && a.isSoldOut)
        .map((a) => a.menuItemId)
        .toSet();
    
    return _menuItems
        .where((item) => soldOutIds.contains(item.id))
        .toList();
  }

  /// Helper untuk check apakah dua DateTime sama hari
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Reset stock untuk hari baru
  Future<void> resetStockForNewDay() async {
    final today = DateTime.now();
    final newAvailability = <MenuItemAvailability>[];
    
    for (final item in _menuItems) {
      newAvailability.add(MenuItemAvailability(
        menuItemId: item.id,
        date: today,
        totalStock: 50,
        soldCount: 0,
        isAvailable: true,
      ));
    }
    
    _availability = newAvailability;
    await _saveAvailability();
    notifyListeners();
  }
}
