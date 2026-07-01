// lib/screens/workout/edit_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_text_field.dart';

/// Halaman Edit Jadwal Latihan.
/// Menerima objek WorkoutModel yang akan diedit.
class EditWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;

  const EditWorkoutScreen({super.key, required this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutService = WorkoutService();

  late TextEditingController _exerciseNameController;
  late TextEditingController _durationController;

  late String _selectedCategory;
  late String _selectedDifficulty;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Isi form dengan data workout yang ada
    _exerciseNameController = TextEditingController(
      text: widget.workout.exerciseName,
    );
    _durationController = TextEditingController(text: widget.workout.duration);
    _selectedCategory = widget.workout.category;
    _selectedDifficulty = widget.workout.difficulty;

    // Parse tanggal dari string
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.workout.date);

    // Parse jam dari string (format: HH:mm atau h:mm AM/PM)
    final timeParts = widget.workout.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1].split(' ')[0]),
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  /// Menyimpan perubahan ke database
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    // Buat objek baru dengan id yang sama (update)
    final updatedWorkout = widget.workout.copyWith(
      exerciseName: _exerciseNameController.text.trim(),
      category: _selectedCategory,
      date: dateStr,
      time: timeStr,
      duration: _durationController.text.trim(),
      difficulty: _selectedDifficulty,
    );

    final success = await _workoutService.updateWorkout(updatedWorkout);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil diperbarui! ✅'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Kirim sinyal refresh ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui jadwal.'),
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
        title: const Text('Edit Jadwal'),
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
              _buildSectionLabel('Nama Latihan'),
              CustomTextField(
                label: 'Nama Latihan',
                hint: 'Contoh: Bench Press',
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

              _buildSectionLabel('Kategori Latihan'),
              _buildDropdown(
                value: _selectedCategory,
                items: AppConstants.categories,
                icon: Icons.category_outlined,
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              _buildSectionLabel('Tanggal & Jam'),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.calendar_today,
                      label: DateFormat('dd MMM yyyy').format(_selectedDate),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
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

              _buildSectionLabel('Tingkat Kesulitan'),
              _buildDropdown(
                value: _selectedDifficulty,
                items: AppConstants.difficulties,
                icon: Icons.signal_cellular_alt,
                onChanged: (val) => setState(() => _selectedDifficulty = val!),
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _handleUpdate,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan Perubahan'),
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
