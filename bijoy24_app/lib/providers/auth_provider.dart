import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(const AuthState()) {
    _checkSavedAuth();
  }

  Future<void> _checkSavedAuth() async {
    try {
      final user = await StorageService.getUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> loginStudent(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _api.studentLogin(username, password);
      final user = AuthUser.fromJson(response.data);
      await StorageService.saveToken(user.token);
      await StorageService.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> loginAdmin(String username, String password, String role) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _api.adminLogin(username, password, role);
      final user = AuthUser.fromJson(response.data);
      await StorageService.saveToken(user.token);
      await StorageService.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<bool> registerStudent(Map<String, dynamic> data) async {
    try {
      await _api.registerStudent(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> registerHallAdmin(Map<String, dynamic> data) async {
    try {
      await _api.registerHallAdmin(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _getErrorMessage(dynamic e) {
    if (e is Exception) {
      return 'Invalid credentials. Please try again.';
    }
    return 'An error occurred. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
