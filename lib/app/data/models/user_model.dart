class UserModel {
  int? id;
  String? namaLengkap;
  String? foto;
  String? email;
  String? noTelepon;
  String? alamat;
  String? noKtp;
  String? tanggalLahir;
  int? usiaKehamilan;
  String? tanggalHpht;
  String? role;

  UserModel({
    this.id,
    this.namaLengkap,
    this.foto,
    this.email,
    this.noTelepon,
    this.alamat,
    this.noKtp,
    this.tanggalLahir,
    this.usiaKehamilan,
    this.tanggalHpht,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      namaLengkap: json['nama_lengkap'] as String,
      foto: json['foto'] as String?,
      email: json['email'] as String,
      noTelepon: json['no_telepon'] as String,
      alamat: json['alamat'] as String?,
      noKtp: json['no_ktp'] as String?,
      tanggalLahir: json['tanggal_lahir'] as String?,
      usiaKehamilan: json['usia_kehamilan'] as int?,
      tanggalHpht: json['tanggal_hpht'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'foto': foto,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'no_ktp': noKtp,
      'tanggal_lahir': tanggalLahir,
      'usia_kehamilan': usiaKehamilan,
      'tanggal_hpht': tanggalHpht,
      'role': role,
    };
  }
}
