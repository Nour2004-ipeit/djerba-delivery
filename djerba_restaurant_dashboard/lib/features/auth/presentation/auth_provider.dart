import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_api.dart';
import '../../../core/network/dio_client.dart';

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
  final _storage = const FlutterSecureStorage();
  String? _lastRestaurantName;
  String? _lastRestaurantImageUrl;

  @override
  AuthState build() {
    _api = AuthApi();
    _checkAuthStatus();
    return AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.signIn(email, password);
      if (response['token'] != null) {
        await _storage.write(key: 'auth_token', value: response['token']);
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      }
      throw Exception('Token manquant dans la réponse');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendEmailOTP(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.sendOtp(email);
      state = state.copyWith(isLoading: false, otpSent: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password, String phone, {String? restaurantName, String? restaurantImageUrl}) async {
    state = state.copyWith(isLoading: true, error: null);
    _lastRestaurantName = restaurantName;
    _lastRestaurantImageUrl = restaurantImageUrl;
    try {
      final response = await _api.signUp(name, email, password, phone); 
      if (response['token'] != null) {
        await _storage.write(key: 'auth_token', value: response['token']);
        await _api.sendOtp(email);
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
      final response = await _api.verifyOtp(email, code);
      if (response['token'] != null) {
        await _storage.write(key: 'auth_token', value: response['token']);
      }
      if (_lastRestaurantName != null) {
        await _api.createRestaurant(_lastRestaurantName!, imageUrl: _lastRestaurantImageUrl);
        _lastRestaurantName = null;
        _lastRestaurantImageUrl = null;
      }
      state = state.copyWith(isLoading: false, isAuthenticated: true, otpSent: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _storage.delete(key: 'auth_token');
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
