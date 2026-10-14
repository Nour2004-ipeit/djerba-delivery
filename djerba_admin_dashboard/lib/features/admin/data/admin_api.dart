import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AdminApi {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final response = await _dio.get('/admin/stats');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to load stats: ${e.message}');
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await _dio.get('/users');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to load users: ${e.message}');
    }
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      final response = await _dio.get('/orders');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to load orders: ${e.message}');
    }
  }
}
