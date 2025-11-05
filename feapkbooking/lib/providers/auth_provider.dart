// lib/providers/auth_provider.dart

import 'package:feapkbooking/auth/auth_services.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }
enum UserRole { unknown, admin, user }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _authStatus = AuthStatus.unauthenticated;
  UserRole _userRole = UserRole.unknown;
  String _namaUser = ""; // <-- TAMBAHKAN INI (Untuk simpan nama)
  
  AuthStatus get authStatus => _authStatus;
  UserRole get userRole => _userRole;
  String get namaUser => _namaUser; // <-- TAMBAHKAN INI

  Future<bool> login(String email, String password) async {
    final userInfo = await _authService.login(email, password); // Ini sekarang Map

    if (userInfo != null) {
      _authStatus = AuthStatus.authenticated;
      _userRole = (userInfo['role'] == 'admin') ? UserRole.admin : UserRole.user;
      _namaUser = userInfo['nama'] ?? 'User'; // <-- SIMPAN NAMA
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    // AuthService akan return true/false
    // UI (RegisterScreen) akan menangani pesan errornya
    return await _authService.register(name, email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    _authStatus = AuthStatus.unauthenticated;
    _userRole = UserRole.unknown;
    _namaUser = ""; // <-- RESET NAMA
    notifyListeners();
  }
}