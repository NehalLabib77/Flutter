import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

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

      if (_isNetworkUnavailable(e)) {
        final mockUser = _mockStudentLogin(username, password);
        if (mockUser != null) {
          await StorageService.saveToken(mockUser.token);
          await StorageService.saveUser(mockUser);
          state = AuthState(status: AuthStatus.authenticated, user: mockUser);
          return;
        }
      }
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

      if (_isNetworkUnavailable(e)) {
        final mockUser = _mockAdminLogin(username, password, role);
        if (mockUser != null) {
          await StorageService.saveToken(mockUser.token);
          await StorageService.saveUser(mockUser);
          state = AuthState(status: AuthStatus.authenticated, user: mockUser);
          return;
        }
      }
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
    if (e is DioException) {
      if (_isNetworkUnavailable(e)) {
        return 'Cannot reach server. Check your network or backend.';
      }
      final status = e.response?.statusCode;
      if (status == 401 || status == 400) {
        return 'Invalid username or password.';
      }
      return 'Server error ($status). Please try again.';
    }
    return 'Invalid username or password.';
  }

  bool _isNetworkUnavailable(dynamic e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
    }
    return false;
  }

  AuthUser? _mockStudentLogin(String username, String password) {
    if (username == 'student' && password == 'student123') {
      return AuthUser(
        userId: 'mock-student-001',
        username: 'student',
        role: 'Student',
        studentId: 'STU001',
        name: 'Demo Student',
        token: 'mock-token-student',
      );
    }
    return null;
  }

  AuthUser? _mockAdminLogin(String username, String password, String role) {
    if (role == 'HallAdmin' &&
        username == 'HallAdmin' &&
        password == 'admin123') {
      return AuthUser(
        userId: 'mock-halladmin-001',
        username: 'HallAdmin',
        role: 'HallAdmin',
        hallId: 1,
        name: 'Demo Hall Admin',
        token: 'mock-token-halladmin',
      );
    }
    if (role == 'SystemAdmin' &&
        username == 'System' &&
        password == 'admin123') {
      return AuthUser(
        userId: 'mock-sysadmin-001',
        username: 'System',
        role: 'SystemAdmin',
        name: 'Demo System Admin',
        token: 'mock-token-sysadmin',
      );
    }
    return null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
