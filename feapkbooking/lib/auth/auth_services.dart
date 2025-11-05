// lib/services/auth_service.dart

class AuthService {
  // Method dummy untuk login
  // Mengembalikan 'admin' atau 'user' berdasarkan email
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API call

    if (email == 'admin@pln.com' && password == 'admin123') {
      return 'admin';
    } else if (email == 'user@pln.com' && password == 'user123') {
      return 'user';
    } else {
      return null;
    }
  }

  // Method dummy untuk register
  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API call
    print('User baru terdaftar: $name ($email)');
    return true; // Anggap selalu berhasil
  }

  // Method dummy untuk logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi
    print('User logged out');
  }
}