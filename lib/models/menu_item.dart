import 'package:uuid/uuid.dart';

/// Kategori menu yang tersedia
enum MenuCategory {
  appetizer,    // Pembuka
  mainCourse,   // Hidangan Utama
  sideDish,     // Lauk Pendamping
  dessert,      // Penutup
  beverage,     // Minuman
  sauce,        // Saus/Sambal
}

extension MenuCategoryExtension on MenuCategory {
  String get displayName {
    switch (this) {
      case MenuCategory.appetizer:
        return 'Pembuka';
      case MenuCategory.mainCourse:
        return 'Hidangan Utama';
      case MenuCategory.sideDish:
        return 'Lauk Pendamping';
      case MenuCategory.dessert:
        return 'Penutup';
      case MenuCategory.beverage:
        return 'Minuman';
      case MenuCategory.sauce:
        return 'Saus & Sambal';
    }
  }

  String get emoji {
    switch (this) {
      case MenuCategory.appetizer:
        return '🍤';
      case MenuCategory.mainCourse:
        return '🍗';
      case MenuCategory.sideDish:
        return '🍜';
      case MenuCategory.dessert:
        return '🍰';
      case MenuCategory.beverage:
        return '🥤';
      case MenuCategory.sauce:
        return '🌶️';
    }
  }

  int get sortOrder {
    switch (this) {
      case MenuCategory.appetizer:
        return 1;
      case MenuCategory.mainCourse:
        return 2;
      case MenuCategory.sideDish:
        return 3;
      case MenuCategory.sauce:
        return 4;
      case MenuCategory.dessert:
        return 5;
      case MenuCategory.beverage:
        return 6;
    }
  }
}

/// Model untuk setiap item menu
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String imageUrl;
  final bool isSpicy;
  final bool isVegetarian;
  final int preparationTime; // dalam menit
  final DateTime createdAt;

  MenuItem({
    String? id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.isSpicy = false,
    this.isVegetarian = false,
    this.preparationTime = 20,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category.index,
      'imageUrl': imageUrl,
      'isSpicy': isSpicy,
      'isVegetarian': isVegetarian,
      'preparationTime': preparationTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String? ?? 'Unknown Item',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: MenuCategory.values[(map['category'] as int?) ?? 1],
      imageUrl: map['imageUrl'] as String? ?? '',
      isSpicy: map['isSpicy'] as bool? ?? false,
      isVegetarian: map['isVegetarian'] as bool? ?? false,
      preparationTime: map['preparationTime'] as int? ?? 20,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    String? imageUrl,
    bool? isSpicy,
    bool? isVegetarian,
    int? preparationTime,
    DateTime? createdAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isSpicy: isSpicy ?? this.isSpicy,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      preparationTime: preparationTime ?? this.preparationTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'MenuItem(id: $id, name: $name, price: $price)';
}

/// Model untuk tracking availability menu per malam/tanggal
class MenuItemAvailability {
  final String id;
  final String menuItemId;
  final DateTime date;
  final int totalStock;
  final int soldCount;
  final bool isAvailable;
  final DateTime updatedAt;

  MenuItemAvailability({
    String? id,
    required this.menuItemId,
    required this.date,
    this.totalStock = 50,
    this.soldCount = 0,
    this.isAvailable = true,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        updatedAt = updatedAt ?? DateTime.now();

  int get remainingStock => totalStock - soldCount;

  bool get isSoldOut => remainingStock <= 0;

  double get soldPercentage => totalStock > 0 ? (soldCount / totalStock) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'date': date.toIso8601String(),
      'totalStock': totalStock,
      'soldCount': soldCount,
      'isAvailable': isAvailable,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MenuItemAvailability.fromMap(Map<String, dynamic> map) {
    return MenuItemAvailability(
      id: map['id'] as String? ?? const Uuid().v4(),
      menuItemId: map['menuItemId'] as String? ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      totalStock: map['totalStock'] as int? ?? 50,
      soldCount: map['soldCount'] as int? ?? 0,
      isAvailable: map['isAvailable'] as bool? ?? true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  MenuItemAvailability copyWith({
    String? id,
    String? menuItemId,
    DateTime? date,
    int? totalStock,
    int? soldCount,
    bool? isAvailable,
    DateTime? updatedAt,
  }) {
    return MenuItemAvailability(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      date: date ?? this.date,
      totalStock: totalStock ?? this.totalStock,
      soldCount: soldCount ?? this.soldCount,
      isAvailable: isAvailable ?? this.isAvailable,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
