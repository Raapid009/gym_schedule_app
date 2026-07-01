// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../services/workout_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/session_manager.dart';
import '../auth/login_screen.dart';

/// Halaman Profil pengguna.
/// Menampilkan data diri, statistik workout, dan tombol logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final WorkoutService _workoutService = WorkoutService();

  // Data statistik
  int _totalWorkout = 0;
  int _doneWorkout = 0;
  int _pendingWorkout = 0;
  bool _isLoading = true;

  // Data user dari sesi
  String get _nama => SessionManager.getUser()?.nama ?? '-';
  String get _username => SessionManager.getUser()?.username ?? '-';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Memuat statistik workout dari database
  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _workoutService.getWorkoutStats();
    setState(() {
      _totalWorkout = stats['total'] ?? 0;
      _doneWorkout = stats['done'] ?? 0;
      _pendingWorkout = stats['pending'] ?? 0;
      _isLoading = false;
    });
  }

  /// Dialog konfirmasi logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              // Hapus sesi dan kembali ke login
              SessionManager.clearSession();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan avatar ──
          _buildSliverAppBar(),

          // ── Konten profil ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card informasi akun ──
                  _buildSectionTitle('Informasi Akun'),
                  const SizedBox(height: 12),
                  _buildInfoCard(),

                  const SizedBox(height: 24),

                  // ── Card statistik ──
                  _buildSectionTitle('Statistik Latihan'),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : _buildStatsCard(),

                  const SizedBox(height: 24),

                  // ── Card pencapaian ──
                  _buildSectionTitle('Pencapaian'),
                  const SizedBox(height: 12),
                  _buildAchievementCard(),

                  const SizedBox(height: 24),

                  // ── Tombol logout ──
                  _buildSectionTitle('Akun'),
                  const SizedBox(height: 12),
                  _buildLogoutButton(),

                  const SizedBox(height: 30),

                  // Versi aplikasi
                  Center(
                    child: Text(
                      '${AppConstants.appName} v1.0.0',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Final Project Mobile Programming',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SliverAppBar dengan header hijau dan avatar user
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Avatar lingkaran besar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      // Inisial nama user (huruf pertama)
                      _nama.isNotEmpty ? _nama[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nama user
                Text(
                  _nama,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Username dengan ikon @
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.alternate_email,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  /// Judul section dengan garis vertikal hijau
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  /// Card informasi akun (nama & username)
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris nama
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Nama Lengkap',
            value: _nama,
            color: AppColors.primary,
          ),
          const Divider(height: 1, indent: 66, color: AppColors.divider),

          // Baris username
          _buildInfoRow(
            icon: Icons.alternate_email,
            label: 'Username',
            value: _username,
            color: AppColors.primaryLighter,
          ),
          const Divider(height: 1, indent: 66, color: AppColors.divider),

          // Baris status akun
          _buildInfoRow(
            icon: Icons.verified_outlined,
            label: 'Status Akun',
            value: 'Aktif',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  /// Card statistik 3 kolom
  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // Total
          Expanded(
            child: _buildStatItem(
              value: _totalWorkout.toString(),
              label: 'Total\nLatihan',
              color: AppColors.primary,
              icon: Icons.fitness_center,
            ),
          ),

          // Divider vertikal
          Container(width: 1, height: 60, color: AppColors.divider),

          // Selesai
          Expanded(
            child: _buildStatItem(
              value: _doneWorkout.toString(),
              label: 'Sudah\nSelesai',
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
          ),

          // Divider vertikal
          Container(width: 1, height: 60, color: AppColors.divider),

          // Pending
          Expanded(
            child: _buildStatItem(
              value: _pendingWorkout.toString(),
              label: 'Belum\nDilakukan',
              color: AppColors.warning,
              icon: Icons.pending_outlined,
            ),
          ),
        ],
      ),
    );
  }

  /// Satu item statistik di dalam card stats
  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        // Ikon
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),

        // Angka
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),

        // Label
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        ),
      ],
    );
  }

  /// Card pencapaian berdasarkan jumlah workout selesai
  Widget _buildAchievementCard() {
    // Tentukan pencapaian berdasarkan jumlah workout selesai
    final achievement = _getAchievement(_doneWorkout);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement['color'] as Color,
            (achievement['color'] as Color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (achievement['color'] as Color).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Ikon trofi/medal
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),

          // Teks pencapaian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['desc'] as String,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(_doneWorkout),
                    backgroundColor: AppColors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.white,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['next'] as String,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Menentukan data pencapaian berdasarkan jumlah workout selesai
  Map<String, dynamic> _getAchievement(int done) {
    if (done == 0) {
      return {
        'title': 'Pemula 🌱',
        'desc': 'Mulai perjalanan fitness kamu!',
        'next': 'Selesaikan 1 latihan untuk naik level',
        'color': AppColors.textGrey,
        'icon': Icons.emoji_events_outlined,
      };
    } else if (done < 5) {
      return {
        'title': 'Rookie 🥉',
        'desc': 'Kamu sudah menyelesaikan $done latihan!',
        'next': '${5 - done} lagi untuk Bronze Athlete',
        'color': const Color(0xFF8D6E63),
        'icon': Icons.emoji_events,
      };
    } else if (done < 15) {
      return {
        'title': 'Bronze Athlete 🥈',
        'desc': 'Konsisten berlatih, keren!',
        'next': '${15 - done} lagi untuk Silver Athlete',
        'color': const Color(0xFF78909C),
        'icon': Icons.military_tech,
      };
    } else if (done < 30) {
      return {
        'title': 'Silver Athlete 🥇',
        'desc': 'Kamu luar biasa! Terus semangat!',
        'next': '${30 - done} lagi untuk Gold Athlete',
        'color': const Color(0xFFFFB300),
        'icon': Icons.military_tech,
      };
    } else {
      return {
        'title': 'Gold Athlete 🏆',
        'desc': 'Pencapaian tertinggi! Kamu hebat!',
        'next': 'Pertahankan konsistensimu!',
        'color': AppColors.primary,
        'icon': Icons.workspace_premium,
      };
    }
  }

  /// Nilai progress bar (0.0 - 1.0)
  double _getProgressValue(int done) {
    if (done == 0) return 0.0;
    if (done < 5) return done / 5;
    if (done < 15) return done / 15;
    if (done < 30) return done / 30;
    return 1.0;
  }

  /// Satu baris informasi di dalam card
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Ikon dengan background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),

          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ),

          // Nilai
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol logout dengan desain merah
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Ikon logout
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),

              // Label
              const Expanded(
                child: Text(
                  'Keluar dari Aplikasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.error,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
