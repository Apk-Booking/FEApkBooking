// lib/auth/auth_service.dart

class AuthService {
  // Database dummy, 'static' agar datanya bertahan
  // selama aplikasi berjalan
  static final List<Map<String, String>> _mockDatabase = [
    {
      "email": "admin@pln.com",
      "password": "admin123",
      "nama": "Admin PLN",
      "role": "admin"
    },
    {
      "email": "user@pln.com",
      "password": "user123",
      "nama": "Budi Santoso", // Kita pakai Budi sebagai user default
      "role": "user"
    }
  ];

  // Method login diubah untuk mengembalikan Map (info user)
  Future<Map<String, String>?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API call

    final user = _mockDatabase.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {}, // Return map kosong jika tidak ketemu
    );

    if (user.isNotEmpty) {
      return user; // Kembalikan semua info user
    } else {
      return null; // Gagal login
    }
  }

  // Method register diubah untuk menyimpan ke database
  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API call

    // Cek apakah email sudah ada
    final emailExists = _mockDatabase.any((user) => user['email'] == email);

    if (emailExists) {
      print('Registrasi Gagal: Email $email sudah terdaftar.');
      return false; // Gagal, email sudah ada
    } else {
      // Tambahkan user baru
      _mockDatabase.add({
        "email": email,
        "password": password,
        "nama": name,
        "role": "user" // User baru selalu 'user'
      });
      print('User baru terdaftar: $name ($email)');
      return true; // Sukses
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('User logged out');
  }
}