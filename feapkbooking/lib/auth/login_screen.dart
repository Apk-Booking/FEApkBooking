import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController(text: 'wafid.adzka@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _isLoading = false;
  bool _obscurePassword = true;
  

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showInfoDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    debugPrint('LOGIN BUTTON CLICKED');

    if (!_formKey.currentState!.validate()) {
      debugPrint('FORM NOT VALID');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      debugPrint('CALLING PROVIDER LOGIN');

      // ✅ login() sekarang return LoginResult, BUKAN bool
      final LoginResult result = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      debugPrint('LOGIN RESULT: $result');

      if (!mounted) return;

      switch (result) {
        case LoginResult.success:
          Navigator.pushReplacementNamed(context, '/user_dashboard');
          break;

        case LoginResult.adminNotAllowed:
          _showInfoDialog(
            title: 'Akses Ditolak',
            message: 'Maaf, akun tidak bisa akses.',
          );
          break;

        case LoginResult.invalidCredential:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email atau password salah'),
              backgroundColor: Colors.red,
            ),
          );
          break;

        case LoginResult.error:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terjadi kesalahan saat login'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat login'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistem Booking Ruang Rapat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Email tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                   controller: _passwordController,
                   obscureText: _obscurePassword, // pakai variabel
                   decoration: InputDecoration(
                   labelText: 'Password',
                   prefixIcon: const Icon(Icons.lock_outline),
                   suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; // toggle visibilitas
                    });
                    },
                    ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password tidak boleh kosong'
                        : null,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text('Belum punya akun?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Registrasi di sini'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}