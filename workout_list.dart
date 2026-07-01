// lib/screens/workout/workout_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_utils.dart';
import '../../widgets/workout_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'add_workout_screen.dart';
import 'detail_workout_screen.dart';

/// Halaman daftar semua jadwal latihan.
class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen>
    with SingleTickerProviderStateMixin {
  final WorkoutService _workoutService = WorkoutService();

  List<WorkoutModel> _allWorkouts = [];
  bool _isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkouts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    final data = await _workoutService.getAllWorkouts();
    setState(() {
      _allWorkouts = data;
      _isLoading = false;
    });
  }

  List<WorkoutModel> _getFilteredWorkouts(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return _allWorkouts
            .where((w) => w.status == AppConstants.statusPending)
            .toList();
      case 2:
        return _allWorkouts
            .where((w) => w.status == AppConstants.statusDone)
            .toList();
      default:
        return _allWorkouts;
    }
  }

  Future<void> _showDeleteDialog(WorkoutModel workout) async {
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Hapus Latihan?',
      content: 'Apakah kamu yakin ingin menghapus "${workout.exerciseName}"?',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.error,
    );

    if (confirm && mounted) {
      final success = await _workoutService.deleteWorkout(workout.id!);
      if (success && mounted) {
        AppUtils.showErrorSnackBar(context, 'Latihan berhasil dihapus');
        _loadWorkouts();
      }
    }
  }

  Future<void> _markAsDone(WorkoutModel workout) async {
    final success = await _workoutService.markAsDone(workout);
    if (success && mounted) {
      AppUtils.showSuccessSnackBar(context, 'Latihan ditandai selesai ✅');
      _loadWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal Latihan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Belum'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
          );
          _loadWorkouts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat jadwal latihan...')
          : TabBarView(
              controller: _tabController,
              children: List.generate(3, (index) {
                final filtered = _getFilteredWorkouts(index);
                return _buildWorkoutList(filtered, index);
              }),
            ),
    );
  }

  Widget _buildWorkoutList(List<WorkoutModel> workouts, int tabIndex) {
    if (workouts.isEmpty) {
      // Pesan berbeda untuk setiap tab
      final messages = [
        {
          'title': 'Belum Ada Jadwal Latihan',
          'subtitle':
              'Tap tombol Tambah untuk membuat\njadwal latihan pertamamu!',
        },
        {
          'title': 'Semua Sudah Selesai!',
          'subtitle':
              'Tidak ada latihan yang belum dilakukan.\nTambah jadwal baru yuk!',
        },
        {
          'title': 'Belum Ada yang Selesai',
          'subtitle':
              'Selesaikan jadwal latihanmu dan\ntandai sebagai selesai.',
        },
      ];

      return EmptyState(
        icon: Icons.fitness_center,
        title: messages[tabIndex]['title']!,
        subtitle: messages[tabIndex]['subtitle']!,
        buttonLabel: tabIndex != 2 ? 'Tambah Jadwal' : null,
        onButtonTap: tabIndex != 2
            ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
                );
                _loadWorkouts();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkouts,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return WorkoutCard(
            workout: workout,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailWorkoutScreen(workoutId: workout.id!),
                ),
              );
              _loadWorkouts();
            },
            onDelete: () => _showDeleteDialog(workout),
            onMarkDone: () => _markAsDone(workout),
          );
        },
      ),
    );
  }
}
