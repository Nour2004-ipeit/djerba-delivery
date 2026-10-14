import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'models.dart';

class OrdersApi {
  final Dio _dio = DioClient().dio;

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.put('/orders/$id/status', data: {'status': status});
      if (response.statusCode != 200) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
