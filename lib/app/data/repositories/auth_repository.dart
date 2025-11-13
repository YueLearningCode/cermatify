import 'dart:io';

import 'package:cermatify/app/data/models/user_model.dart';
import 'package:cermatify/app/data/providers/auth_provider.dart';
import 'package:cermatify/app/data/services/http_service.dart';

class AuthRepository {
  late final AuthProvider _authProvider;

  AuthRepository() {
    final httpService = HttpService();
    _authProvider = AuthProvider(httpService);
  }

  Future<Map<String, dynamic>> login(String email, String password, {String? fcmToken}) async {
    try {
      return await _authProvider.login(email, password, fcmToken: fcmToken);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<UserModel> getProfile() async {
    try {
      return await _authProvider.getProfile();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String namaLengkap,
    required String noTelepon,
    required String password,
    required String noKtp,
    required String role,
    String? alamat,
    String? tanggalLahir,
    int? usiaKehamilan,
    String? tanggalHpht,
  }) async {
    try {
      return await _authProvider.register(
        email: email,
        namaLengkap: namaLengkap,
        noTelepon: noTelepon,
        password: password,
        noKtp: noKtp,
        role: role,
        alamat: alamat,
        tanggalLahir: tanggalLahir,
        usiaKehamilan: usiaKehamilan,
        tanggalHpht: tanggalHpht,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      return await _authProvider.logout();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> uploadProfileImage(File image) async {
    try {
      return await _authProvider.uploadProfileImage(image);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      return await _authProvider.verifyToken();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      return await _authProvider.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> editProfile({
    required String nama,
    required String noHp,
    required String alamat,
    String? noKtp,
    String? tanggalLahir,
    int? usiaKehamilan,
    String? tanggalHpht,
  }) async {
    try {
      return await _authProvider.editProfile(
        nama: nama,
        noHp: noHp,
        alamat: alamat,
        noKtp: noKtp,
        tanggalLahir: tanggalLahir,
        usiaKehamilan: usiaKehamilan,
        tanggalHpht: tanggalHpht,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
