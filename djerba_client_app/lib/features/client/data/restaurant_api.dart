import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'models.dart';

class RestaurantApi {
  final Dio _dio = DioClient().dio;

  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await _dio.get('/restaurants');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RestaurantModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      final response = await _dio.get('/restaurants/$id');
      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching restaurant $id: $e');
      return null;
    }
  }

  Future<List<ProductModel>> getRestaurantProducts(String id) async {
    try {
      final response = await _dio.get('/restaurants/$id/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching products for restaurant $id: $e');
      return [];
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/restaurants/search/products', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          final product = ProductModel.fromJson(json);
          // Assuming the backend injects the restaurant name in the description or we add a new field.
          // In the ProductModel we can store the restaurant name or just keep it as is.
          // Since ProductModel doesn't have a restaurantName field, we can attach it to the description temporarily.
          final restaurant = json['restaurant'];
          final enrichedDescription = restaurant != null 
            ? '${product.description} | Chez ${restaurant['name']}' 
            : product.description;
          
          return ProductModel(
            id: product.id,
            restaurantId: product.restaurantId,
            name: product.name,
            description: enrichedDescription,
            price: product.price,
            category: product.category,
            variants: product.variants,
            isAvailable: product.isAvailable,
            imageUrl: product.imageUrl,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
