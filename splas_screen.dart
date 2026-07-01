// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/session_manager.dart';

/// Halaman Splash Screen.
/// Tampil selama 2 detik, lalu redirect ke Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Controller untuk animasi
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Setup animasi fade + scale
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    // Jalankan animasi
    _animController.forward();

    // Pindah halaman setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _navigateNext();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Arahkan ke halaman berikutnya
  void _navigateNext() {
    Navigator.pushReplacementNamed(
      context,
      SessionManager.isLoggedIn() ? '/dashboard' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(scale: _scaleAnim, child: child),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ──
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Nama Aplikasi ──
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Tagline ──
                  const Text(
                    'Kelola Jadwal Gym Kamu',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 60),

                  // ── Loading indicator ──
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Memuat aplikasi...',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
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
