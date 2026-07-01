// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';

/// Halaman Login.
/// User memasukkan username dan password untuk masuk ke aplikasi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil nilai dari TextField
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Service untuk operasi login
  final _authService = AuthService();

  // State loading saat proses login berlangsung
  bool _isLoading = false;

  @override
  void dispose() {
    // Selalu dispose controller agar tidak memory leak
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi yang dipanggil saat tombol Login ditekan
  Future<void> _handleLogin() async {
    // Validasi semua field terlebih dahulu
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await _authService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      // Simpan data user ke sesi
      SessionManager.setUser(user);

      // Navigasi ke Dashboard, hapus semua halaman sebelumnya
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header hijau di bagian atas ──
              _buildHeader(),

              // ── Form login ──
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masuk untuk mengatur jadwal gym kamu',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Field username
                      CustomTextField(
                        label: 'Username',
                        hint: 'Masukkan username',
                        prefixIcon: Icons.person_outline,
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field password
                      CustomTextField(
                        label: 'Password',
                        hint: 'Masukkan password',
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Tombol Login
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('Login'),
                            ),
                      const SizedBox(height: 16),

                      // Tombol ke halaman Registrasi
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Belum punya akun? Daftar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget header dengan background hijau dan ikon gym
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon gym dalam lingkaran putih
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 48,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola jadwal latihan gym kamu',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
