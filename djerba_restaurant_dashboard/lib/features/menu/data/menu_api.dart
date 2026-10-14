import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<Map<String, dynamic>> variants;
  final bool isAvailable;
  final String imageUrl;

  ProductModel({
    required this.id,
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
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? 'Général',
      variants: json['variants'] != null ? List<Map<String, dynamic>>.from(json['variants']) : [],
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}

class MenuApi {
  final Dio _dio = DioClient().dio;

  Future<List<ProductModel>> getProducts(String restaurantId) async {
    try {
      final response = await _dio.get('/restaurants/$restaurantId/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching menu products: $e');
      return [];
    }
  }

  Future<ProductModel?> addProduct(String restaurantId, Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/restaurants/$restaurantId/products', data: productData);
      if (response.statusCode == 201) {
        return ProductModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  Future<bool> toggleAvailability(String restaurantId, String productId, bool isAvailable) async {
    try {
      final response = await _dio.patch('/restaurants/$restaurantId/products/$productId/availability', data: {
        'isAvailable': isAvailable,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling availability: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String restaurantId, String productId) async {
    try {
      final response = await _dio.delete('/restaurants/$restaurantId/products/$productId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<String?> getMyRestaurantId() async {
    try {
      final response = await _dio.get('/restaurants/my-restaurant');
      if (response.statusCode == 200) {
        return response.data['id'] as String;
      }
      return null;
    } catch (e) {
      print('Error fetching my restaurant: $e');
      return null;
    }
  }

  Future<String?> getMyRestaurantName() async {
    try {
      final response = await _dio.get('/restaurants/my-restaurant');
      if (response.statusCode == 200) {
        return response.data['name'] as String;
      }
      return null;
    } catch (e) {
      print('Error fetching my restaurant name: $e');
      return null;
    }
  }

  Future<String?> getMyRestaurantImage() async {
    try {
      final response = await _dio.get('/restaurants/my-restaurant');
      if (response.statusCode == 200) {
        return response.data['imageUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching my restaurant image: $e');
      return null;
    }
  }

  Future<bool> updateRestaurantImage(String id, String imageUrl) async {
    try {
      final response = await _dio.patch('/restaurants/$id', data: {'imageUrl': imageUrl});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updating restaurant image: $e');
      return false;
    }
  }

  Future<String?> generateProductImage(String prompt) async {
    try {
      final response = await _dio.post('/ai/generate-image', data: { 'prompt': prompt });
      if (response.statusCode == 200) {
        return response.data['imageUrl'] as String;
      }
      return null;
    } catch (e) {
      print('Error generating image: $e');
      return null;
    }
  }

  Future<String?> uploadImage(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post('/upload', data: formData);
      if (response.statusCode == 200) {
        return response.data['imageUrl'] as String;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
