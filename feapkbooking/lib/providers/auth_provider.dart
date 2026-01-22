// lib/providers/auth_provider.dart
import 'package:feapkbooking/auth/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:feapkbooking/auth/auth_session.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }
enum UserRole { unknown, admin, user }

// ✅ RESULT LOGIN UNTUK UI
enum LoginResult {
  success,
  invalidCredential,
  adminNotAllowed,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _authStatus = AuthStatus.unauthenticated;
  UserRole _userRole = UserRole.unknown;

  String _namaUser = '';
  String _divisiUser = '';

  AuthStatus get authStatus => _authStatus;
  UserRole get userRole => _userRole;
  String get namaUser => _namaUser;
  String get divisiUser => _divisiUser;

  // ================= LOGIN =================
  Future<LoginResult> login(String email, String password) async {
    try {
      final Map<String, dynamic>? data =
          await _authService.login(email, password);

      if (data == null || data['user'] == null || data['token'] == null) {
        _resetAuth();
        return LoginResult.invalidCredential;
      }

      final user = data['user'];
      final role = user['role']?.toString().toLowerCase();

      // ❌ ADMIN TIDAK BOLEH LOGIN
      if (role == 'admin') {
        await AuthSession.clear();
        _resetAuth();
        return LoginResult.adminNotAllowed;
      }

      // ✅ HANYA USER YANG BOLEH
      await AuthSession.saveToken(data['token']);

      _authStatus = AuthStatus.authenticated;
      _userRole = UserRole.user;

      _namaUser = user['nama'] ?? 'User';
      _divisiUser = user['unit'] ?? '';

      notifyListeners();
      return LoginResult.success;
    } catch (e) {
      debugPrint('Login error: $e');
      _resetAuth();
      return LoginResult.error;
    }
  }

  // ================= REGISTER =================
  Future<bool> register({
    required String nama,
    required String idPegawai,
    required String unit,
    required String email,
    required String password,
    required String noTelephone,
    required String role,
  }) async {
    try {
      return await _authService.register(
        nama: nama,
        idPegawai: idPegawai,
        unit: unit,
        email: email,
        password: password,
        noTelephone: noTelephone,
        role: role,
      );
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _authService.logout();
    await AuthSession.clear();
    _resetAuth();
  }

  void _resetAuth() {
    _authStatus = AuthStatus.unauthenticated;
    _userRole = UserRole.unknown;
    _namaUser = '';
    _divisiUser = '';
    notifyListeners();
  }
}