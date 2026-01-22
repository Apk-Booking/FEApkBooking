import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feapkbooking/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
 

}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _idPegawaiController = TextEditingController();
  final _unitController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noTelpController = TextEditingController();

  String _role = 'User';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _idPegawaiController.dispose();
    _unitController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      nama: _namaController.text.trim(),
      idPegawai: _idPegawaiController.text.trim(),
      unit: _unitController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      noTelephone: _noTelpController.text.trim(),
      role: _role, // "Admin" or "User"
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi gagal. Cek data atau email mungkin sudah terdaftar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan isi data diri Anda',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 28),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => _requiredValidator(v, 'Nama tidak boleh kosong'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _idPegawaiController,
                          decoration: const InputDecoration(
                            labelText: 'ID Pegawai',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) => _requiredValidator(v, 'ID Pegawai tidak boleh kosong'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            prefixIcon: Icon(Icons.apartment_outlined),
                          ),
                          validator: (v) => _requiredValidator(v, 'Unit tidak boleh kosong'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => _requiredValidator(v, 'Email tidak boleh kosong'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _noTelpController,
                          decoration: const InputDecoration(
                            labelText: 'No Telephone',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => _requiredValidator(v, 'No Telephone tidak boleh kosong'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // disini password bisa disembunyikan atau ditampilkan
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
                         validator: (v) => _requiredValidator(v, 'Password tidak boleh kosong'),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _role,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'User', child: Text('User')),
                            DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _role = value);
                          },
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text('Registrasi'),
                          ),
                        ),

                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Sudah punya akun? Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}