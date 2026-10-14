import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/sign-in/email',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error');
    }
  }

  Future<bool> sendOtp(String email) async {
    try {
      final response = await _dio.post('/auth/email-otp/send-verification-otp', data: {
        'email': email,
        'type': 'email-verification',
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> signUp(String name, String email, String password, String phone) async {
    try {
      final response = await _dio.post(
        '/auth/sign-up/email',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phone,
          'role': 'admin',
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Signup failed');
      }
      throw Exception('Network error');
    }
  }

  Future<void> createRestaurant(String name, {String? imageUrl}) async {
    try {
      await _dio.post(
        '/restaurants',
        data: {
          'name': name,
          'description': 'Description du restaurant $name',
          'address': 'Djerba, Tunisie',
          'lat': 33.876,
          'lng': 10.957,
          if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        },
      );
    } catch (e) {
      print('Error creating restaurant: $e');
      // For MVP, we ignore failure here
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    try {
      final response = await _dio.post('/auth/email-otp/verify-email', data: {
        'email': email,
        'otp': code,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Verification failed');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String identifier) async {
    try {
      final response = await _dio.post(
        '/password-reset/request-reset',
        data: { 'identifier': identifier },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Erreur réseau');
      }
      throw Exception('Network error');
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp(String identifier, String otp, String newPassword) async {
    try {
      final response = await _dio.post(
        '/password-reset/verify-reset-otp',
        data: { 'identifier': identifier, 'otp': otp, 'newPassword': newPassword },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Erreur réseau');
      }
      throw Exception('Network error');
    }
  }
}
