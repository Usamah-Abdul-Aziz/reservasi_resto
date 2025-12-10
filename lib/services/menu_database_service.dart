import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';

class MenuDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'menu_items';
  static const String _availabilityTable = 'menu_availability';

  /// Mendapatkan semua menu items
  static Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('isAvailable', true)
          .order('category')
          .order('name');

      final items = (response as List).map((item) {
        return MenuItem(
          id: item['id'] as String,
          name: item['name'] as String,
          description: item['description'] as String? ?? '',
          price: (item['price'] as num).toDouble(),
          category: _mapCategory(item['category'] as String),
          imageUrl: item['imageUrl'] as String? ?? '',
          preparationTime: item['preparationTime'] as int? ?? 15,
          isSpicy: item['isSpicy'] as bool? ?? false,
          isVegetarian: item['isVegetarian'] as bool? ?? false,
        );
      }).toList();

      print('Loaded ${items.length} menu items from Supabase');
      return items;
    } catch (e) {
      print('Error loading menu items: $e');
      return [];
    }
  }

  /// Mendapatkan menu berdasarkan kategori
  static Future<List<MenuItem>> getMenuByCategory(MenuCategory category) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('category', _categoryToString(category))
          .eq('isAvailable', true)
          .order('name');

      return (response as List).map((item) {
        return MenuItem(
          id: item['id'] as String,
          name: item['name'] as String,
          description: item['description'] as String? ?? '',
          price: (item['price'] as num).toDouble(),
          category: _mapCategory(item['category'] as String),
          imageUrl: item['imageUrl'] as String? ?? '',
          preparationTime: item['preparationTime'] as int? ?? 15,
          isSpicy: item['isSpicy'] as bool? ?? false,
          isVegetarian: item['isVegetarian'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error loading menu by category: $e');
      return [];
    }
  }

  /// Mendapatkan availability menu untuk tanggal tertentu
  static Future<Map<String, MenuAvailability>> getAvailabilityForDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from(_availabilityTable)
          .select()
          .eq('date', dateStr);

      final Map<String, MenuAvailability> availabilityMap = {};
      for (final item in response as List) {
        final menuItemId = item['menuItemId'] as String;
        availabilityMap[menuItemId] = MenuAvailability(
          menuItemId: menuItemId,
          date: DateTime.parse(item['date'] as String),
          isAvailable: item['isAvailable'] as bool? ?? true,
          isSoldOut: item['isSoldOut'] as bool? ?? false,
          quantityAvailable: item['quantityAvailable'] as int? ?? -1,
        );
      }
      return availabilityMap;
    } catch (e) {
      print('Error loading availability: $e');
      return {};
    }
  }

  /// Update availability menu
  static Future<bool> updateAvailability(MenuAvailability availability) async {
    try {
      final dateStr = availability.date.toIso8601String().split('T')[0];
      
      await _supabase.from(_availabilityTable).upsert({
        'menuItemId': availability.menuItemId,
        'date': dateStr,
        'isAvailable': availability.isAvailable,
        'isSoldOut': availability.isSoldOut,
        'quantityAvailable': availability.quantityAvailable,
      }, onConflict: 'menuItemId,date');

      return true;
    } catch (e) {
      print('Error updating availability: $e');
      return false;
    }
  }

  /// Tambah menu item baru
  static Future<bool> createMenuItem(MenuItem item) async {
    try {
      await _supabase.from(_tableName).insert({
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': _categoryToString(item.category),
        'imageUrl': item.imageUrl,
        'isAvailable': true,
        'preparationTime': item.preparationTime,
        'isSpicy': item.isSpicy,
        'isVegetarian': item.isVegetarian,
      });
      return true;
    } catch (e) {
      print('Error creating menu item: $e');
      return false;
    }
  }

  /// Update menu item
  static Future<bool> updateMenuItem(MenuItem item) async {
    try {
      await _supabase.from(_tableName).update({
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': _categoryToString(item.category),
        'imageUrl': item.imageUrl,
        'preparationTime': item.preparationTime,
        'isSpicy': item.isSpicy,
        'isVegetarian': item.isVegetarian,
      }).eq('id', item.id);
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  /// Delete menu item
  static Future<bool> deleteMenuItem(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  /// Helper: Map string to MenuCategory
  static MenuCategory _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'appetizer':
        return MenuCategory.appetizer;
      case 'main_course':
        return MenuCategory.mainCourse;
      case 'side_dish':
        return MenuCategory.sideDish;
      case 'dessert':
        return MenuCategory.dessert;
      case 'beverage':
        return MenuCategory.beverage;
      case 'sauce':
        return MenuCategory.sauce;
      default:
        return MenuCategory.mainCourse;
    }
  }

  /// Helper: Map MenuCategory to string
  static String _categoryToString(MenuCategory category) {
    switch (category) {
      case MenuCategory.appetizer:
        return 'appetizer';
      case MenuCategory.mainCourse:
        return 'main_course';
      case MenuCategory.sideDish:
        return 'side_dish';
      case MenuCategory.dessert:
        return 'dessert';
      case MenuCategory.beverage:
        return 'beverage';
      case MenuCategory.sauce:
        return 'sauce';
    }
  }
}

/// Model untuk availability per hari
class MenuAvailability {
  final String menuItemId;
  final DateTime date;
  final bool isAvailable;
  final bool isSoldOut;
  final int quantityAvailable;

  MenuAvailability({
    required this.menuItemId,
    required this.date,
    this.isAvailable = true,
    this.isSoldOut = false,
    this.quantityAvailable = -1,
  });
}
