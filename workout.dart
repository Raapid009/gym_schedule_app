// lib/screens/workout/add_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_text_field.dart';

/// Halaman Tambah Jadwal Latihan Baru.
class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutService = WorkoutService();

  // Controllers
  final _exerciseNameController = TextEditingController();
  final _durationController = TextEditingController();

  // Nilai dropdown & picker
  String _selectedCategory = AppConstants.categories.first;
  String _selectedDifficulty = AppConstants.difficulties.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Membuka DatePicker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Membuka TimePicker
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Menyimpan workout baru ke database
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Format tanggal dan jam
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    final workout = WorkoutModel(
      exerciseName: _exerciseNameController.text.trim(),
      category: _selectedCategory,
      date: dateStr,
      time: timeStr,
      duration: _durationController.text.trim(),
      difficulty: _selectedDifficulty,
      status: AppConstants.statusPending,
    );

    final success = await _workoutService.addWorkout(workout);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal latihan berhasil ditambahkan! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan jadwal, coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Jadwal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Nama Latihan ──
              _buildSectionLabel('Nama Latihan'),
              CustomTextField(
                label: 'Nama Latihan',
                hint: 'Contoh: Bench Press, Squat',
                prefixIcon: Icons.fitness_center,
                controller: _exerciseNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama latihan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Kategori ──
              _buildSectionLabel('Kategori Latihan'),
              _buildDropdown(
                value: _selectedCategory,
                items: AppConstants.categories,
                icon: Icons.category_outlined,
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              // ── Tanggal & Jam ──
              _buildSectionLabel('Tanggal & Jam'),
              Row(
                children: [
                  // Tombol pilih tanggal
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.calendar_today,
                      label: DateFormat('dd MMM yyyy').format(_selectedDate),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol pilih jam
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.access_time,
                      label: _selectedTime.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Durasi ──
              _buildSectionLabel('Durasi (menit)'),
              CustomTextField(
                label: 'Durasi',
                hint: 'Contoh: 45',
                prefixIcon: Icons.timer_outlined,
                controller: _durationController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Durasi tidak boleh kosong';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Durasi harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Tingkat Kesulitan ──
              _buildSectionLabel('Tingkat Kesulitan'),
              _buildDropdown(
                value: _selectedDifficulty,
                items: AppConstants.difficulties,
                icon: Icons.signal_cellular_alt,
                onChanged: (val) => setState(() => _selectedDifficulty = val!),
              ),
              const SizedBox(height: 32),

              // ── Tombol Simpan ──
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan Jadwal'),
                    ),

              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Label section form
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  /// Dropdown kustom dengan border radius
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Tombol picker (tanggal / jam)
  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
