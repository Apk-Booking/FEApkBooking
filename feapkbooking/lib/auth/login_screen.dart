// lib/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// Import untuk Splash Screen
import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Pre-fill untuk tes lebih cepat
  final _emailController = TextEditingController(text: 'user@pln.com');
  final _passwordController = TextEditingController(text: 'user123');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _removeSplashScreen();
  }

  Future<void> _removeSplashScreen() async {
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() { _isLoading = false; });

    if (mounted) {
      if (success) {
        if (authProvider.userRole == UserRole.admin) {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/user_dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau Password salah!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Agar card pas di konten
              children: [
                Image.asset(
                  'assets/images/Logo_PLN.png',
                  height: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'PT PLN (Persero)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005EA0), // Biru PLN
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem Booking Ruang Rapat',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Email tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Password tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('Login', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // --- PERBAIKAN: GANTI Row MENJADI Wrap ---
                      Wrap(
                        alignment: WrapAlignment.center, // Tetap di tengah
                        crossAxisAlignment: WrapCrossAlignment.center, // Sejajar
                        children: [
                          const Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            // Kurangi padding bawaan TextButton agar lebih rapat
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Registrasi di sini'),
                          ),
                        ],
                      )
                      // --- BATAS PERBAIKAN ---
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}