// lib/models/workout_model.dart

/// Model untuk data jadwal latihan gym.
/// Setiap field sesuai dengan kolom di tabel 'workouts' pada database.
class WorkoutModel {
  final int? id;
  final String exerciseName; // Nama latihan
  final String category;     // Kategori (Chest, Back, dll)
  final String date;         // Tanggal latihan (format: yyyy-MM-dd)
  final String time;         // Jam latihan (format: HH:mm)
  final String duration;     // Durasi dalam menit
  final String difficulty;   // Tingkat kesulitan
  final String status;       // Status: Belum Dilakukan / Selesai

  WorkoutModel({
    this.id,
    required this.exerciseName,
    required this.category,
    required this.date,
    required this.time,
    required this.duration,
    required this.difficulty,
    required this.status,
  });

  /// Mengubah objek WorkoutModel menjadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'category': category,
      'date': date,
      'time': time,
      'duration': duration,
      'difficulty': difficulty,
      'status': status,
    };
  }

  /// Membuat objek WorkoutModel dari Map (hasil query database)
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      exerciseName: map['exerciseName'],
      category: map['category'],
      date: map['date'],
      time: map['time'],
      duration: map['duration'],
      difficulty: map['difficulty'],
      status: map['status'],
    );
  }

  /// Membuat salinan objek dengan nilai yang diubah (berguna saat update)
  WorkoutModel copyWith({
    int? id,
    String? exerciseName,
    String? category,
    String? date,
    String? time,
    String? duration,
    String? difficulty,
    String? status,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
    );
  }
}
