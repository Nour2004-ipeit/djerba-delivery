import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class DriverApi {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId/status',
        data: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
  Future<bool> updateLocation(double lat, double lng) async {
    try {
      final response = await _dio.post(
        '/drivers/location',
        data: {'lat': lat, 'lng': lng},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _dio.get('/drivers/stats');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting driver stats: $e');
      return null;
    }
  }
}
