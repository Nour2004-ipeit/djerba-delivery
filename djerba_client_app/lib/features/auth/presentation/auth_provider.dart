import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_api.dart';
import '../../../core/network/dio_client.dart';
import '../../client/presentation/user_service.dart';

// State pour gÃ©rer le chargement, les erreurs et le succÃ¨s
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool otpSent;

  AuthState({this.isLoading = false, this.error, this.isAuthenticated = false, this.otpSent = false});

  AuthState copyWith({bool? isLoading, String? error, bool? isAuthenticated, bool? otpSent}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthApi _api;


  @override
  AuthState build() {
    _api = AuthApi(DioClient());
    _checkAuthStatus();
    return AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.signIn(email, password);
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      }
      throw Exception('Token manquant dans la rÃ©ponse');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendEmailOTP(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.sendOTP(email);
      state = state.copyWith(isLoading: false, otpSent: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password, String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.signUp(name, email, password, phone);
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        if (response['user'] != null && response['user']['name'] != null) {
          UserService().updateProfile(name: response['user']['name'], email: response['user']['email'] ?? '', phone: phone);
        }
        // Instead of authenticating immediately, we send OTP
        await _api.sendOTP(email);
        state = state.copyWith(isLoading: false, otpSent: true);
        return true;
      }
      throw Exception('Token manquant dans la réponse');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.verifyOTP(email, code);
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        if (response['user'] != null && response['user']['name'] != null) {
          UserService().updateProfile(name: response['user']['name'], email: response['user']['email'] ?? email, phone: '');
        }
      }
      state = state.copyWith(isLoading: false, isAuthenticated: true, otpSent: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
