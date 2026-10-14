import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../presentation/cart_service.dart';

class OrdersApi {
  final Dio _dio = DioClient().dio;

  Future<String?> createOrder(List<CartItem> items, String address, double lat, double lng) async {
    if (items.isEmpty) return null;
    
    // Get the first restaurant ID. In a real app, validation should prevent mixed restaurants in one cart.
    final restaurantId = items.first.restaurantId;

    final orderPayload = {
      "restaurantId": restaurantId,
      "items": items.map((item) => {
        "productId": item.productId,
        "quantity": item.quantity,
        "options": item.options,
      }).toList(),
      "deliveryAddress": address,
      "deliveryLat": lat,
      "deliveryLng": lng,
    };

    try {
      final response = await _dio.post('/orders', data: orderPayload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['orderId'] as String;
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
