import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../cart/data/cart_item_model.dart';

class OrderApi {
  final DioClient _dioClient;

  OrderApi(this._dioClient);

  Future<Map<String, dynamic>> submitOrder({
    required String restaurantId,
    required List<CartItem> items,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLng,
  }) async {
    try {
      final payload = {
        'restaurantId': restaurantId,
        'items': items.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
        }).toList(),
        'deliveryAddress': deliveryAddress,
        'deliveryLat': deliveryLat,
        'deliveryLng': deliveryLng,
      };

      // Appelle le endpoint Hono (Next.js Edge)
      final response = await _dioClient.dio.post(
        '/orders',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to submit order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Order Submit Error: ${e.response?.data}');
      throw Exception(e.response?.data['error'] ?? 'Network error');
    }
  }
}
