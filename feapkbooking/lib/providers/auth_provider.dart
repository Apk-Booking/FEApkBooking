// lib/providers/auth_provider.dart

import 'package:feapkbooking/auth/auth_services.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }
enum UserRole { unknown, admin, user }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _authStatus = AuthStatus.unauthenticated;
  UserRole _userRole = UserRole.unknown;
  
  AuthStatus get authStatus => _authStatus;
  UserRole get userRole => _userRole;

  Future<bool> login(String email, String password) async {
    final role = await _authService.login(email, password);

    if (role != null) {
      _authStatus = AuthStatus.authenticated;
      _userRole = (role == 'admin') ? UserRole.admin : UserRole.user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    return await _authService.register(name, email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    _authStatus = AuthStatus.unauthenticated;
    _userRole = UserRole.unknown;
    notifyListeners();
  }
}