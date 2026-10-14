class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final bool isActive;
  final bool isOpen;
  final String imageUrl;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.isActive,
    required this.isOpen,
    required this.imageUrl,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 5.0).toDouble(),
      isActive: json['isActive'] ?? true,
      isOpen: json['isOpen'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class ProductModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<Map<String, dynamic>> variants;
  final bool isAvailable;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.variants,
    required this.isAvailable,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? 'Général',
      variants: json['variants'] != null ? List<Map<String, dynamic>>.from(json['variants']) : [],
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
