import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawModel {
  final String id;
  final String mentorId;
  final String mentorName;
  final int nominal;
  final String namaRekening; // Nama rekening atau nama e-wallet
  final String nomorRekening; // Nomor rekening atau nomor e-wallet
  final String status; // pending, approved, rejected, completed
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminId; // Admin yang approve/reject
  final String? notes; // Catatan dari admin

  WithdrawModel({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.nominal,
    required this.namaRekening,
    required this.nomorRekening,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminId,
    this.notes,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json, String id) {
    return WithdrawModel(
      id: id,
      mentorId: json['mentorId'] as String? ?? '',
      mentorName: json['mentorName'] as String? ?? '',
      nominal: (json['nominal'] as int?) ?? 0,
      namaRekening: json['namaRekening'] as String? ?? '',
      nomorRekening: json['nomorRekening'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      adminId: json['adminId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mentorId': mentorId,
      'mentorName': mentorName,
      'nominal': nominal,
      'namaRekening': namaRekening,
      'nomorRekening': nomorRekening,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'adminId': adminId,
      'notes': notes,
    };
  }
}
