// lib/auth/auth_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'meetyuk-d4d37074a638.herokuapp.com/api/user';

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data']; // token + user
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
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
    final url = Uri.parse('$baseUrl/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama": nama,
          "idpegawai": idPegawai,
          "unit": unit,
          "email": email,
          "password": password,
          "notelphone": noTelephone,
          "role": role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}