// lib/models/user_model.dart

/// Model untuk data pengguna aplikasi.
/// Setiap field sesuai dengan kolom di tabel 'users' pada database.
class UserModel {
  final int? id;
  final String nama;
  final String username;
  final String password;

  UserModel({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
  });

  /// Mengubah objek UserModel menjadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama, 'username': username, 'password': password};
  }

  /// Membuat objek UserModel dari Map (hasil query database)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama'],
      username: map['username'],
      password: map['password'],
    );
  }

  /// Membuat salinan objek dengan nilai yang diubah
  UserModel copyWith({
    int? id,
    String? nama,
    String? username,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
