import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AuthApi {
  final DioClient _dioClient;

  AuthApi(this._dioClient);

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/sign-in/email',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'];
        if (errorMessage != null) {
          throw Exception(errorMessage);
        }
      }
      throw Exception('Erreur réseau ou serveur (Code: ${e.response?.statusCode})');
    }
  }

  Future<Map<String, dynamic>> signUp(String name, String email, String password, String phone) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/sign-up/email',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'];
        if (errorMessage != null) {
          throw Exception(errorMessage);
        }
      }
      throw Exception('Erreur réseau ou serveur (Code: ${e.response?.statusCode})');
    }
  }

  Future<void> sendOTP(String email) async {
    try {
      await _dioClient.dio.post(
        '/auth/email-otp/send-verification-otp',
        data: { 'email': email, 'type': 'email-verification' },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'];
        if (errorMessage != null) throw Exception(errorMessage);
      }
      throw Exception('Erreur lors de l\'envoi du code (Code: ${e.response?.statusCode})');
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String code) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/email-otp/verify-email',
        data: { 'email': email, 'otp': code },
      );
      return response.data ?? {};
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'];
        if (errorMessage != null) throw Exception(errorMessage);
      }
      throw Exception('Erreur de vérification (Code: ${e.response?.statusCode})');
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String identifier) async {
    try {
      final response = await _dioClient.dio.post(
        '/password-reset/request-reset',
        data: { 'identifier': identifier },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'];
        if (errorMessage != null) throw Exception(errorMessage);
      }
      throw Exception('Erreur réseau ou serveur (Code: ${e.response?.statusCode})');
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp(String identifier, String otp, String newPassword) async {
    try {
      final response = await _dioClient.dio.post(
        '/password-reset/verify-reset-otp',
        data: { 'identifier': identifier, 'otp': otp, 'newPassword': newPassword },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? data['error'];
        if (errorMessage != null) throw Exception(errorMessage);
      }
      throw Exception('Erreur réseau ou serveur (Code: ${e.response?.statusCode})');
    }
  }
}
