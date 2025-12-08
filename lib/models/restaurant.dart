class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String address;
  final String phone;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String description;
  final List<String> amenities;
  final int capacity;
  final String openTime;
  final String closeTime;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.description,
    required this.amenities,
    required this.capacity,
    required this.openTime,
    required this.closeTime,
  });
}
