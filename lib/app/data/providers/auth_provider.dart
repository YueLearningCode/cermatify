import 'dart:io';
import 'package:cermatify/app/data/models/user_model.dart';
import 'package:cermatify/app/data/services/http_service.dart';

class AuthProvider {
  final HttpService _httpService;
  AuthProvider(this._httpService);

  Future<Map<String, dynamic>> login(String email, String password, {String? fcmToken}) async {
    try {
      Map<String, dynamic> loginData = {'email': email, 'password': password};

      // Add FCM token if provided
      if (fcmToken != null) {
        loginData['fcm_token'] = fcmToken;
        loginData['platform'] = 'android'; // Default to android, can be made dynamic
      }

      final response = await _httpService.post('/login', data: loginData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to login: ${response.statusMessage}');
      }
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
      final response = await _httpService.postFormData(
        '/register',
        data: {
          'nama_lengkap': namaLengkap,
          'email': email,
          'no_telepon': noTelepon,
          'password': password,
          'no_ktp': noKtp,
          'role': role,
          'alamat': alamat,
          'tanggal_lahir': tanggalLahir,
          'usia_kehamilan': usiaKehamilan,
          'tanggal_hpht': tanggalHpht,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to register: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> uploadProfileImage(File image) async {
    try {
      final response = await _httpService.uploadFile('/profile/image', image);

      if (response.statusCode == 200) {
        // Extract the image URL from the response
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic> &&
            responseData['data']['foto'] is String) {
          return responseData['data']['foto'];
        } else {
          throw Exception('Invalid response format: foto URL not found');
        }
      } else {
        throw Exception('Failed to upload foto: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await _httpService.get('/verify-token');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to verify token: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _httpService.post(
        '/password/change',
        data: {"current_password": currentPassword, "new_password": newPassword},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to change password: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _httpService.get('/profile');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get profile: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _httpService.post('/logout');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to logout: ${response.statusMessage}');
      }
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
      // Build the data map, only including non-null values
      final Map<String, dynamic> data = {"nama_lengkap": nama, "no_telepon": noHp, "alamat": alamat};

      // Add optional fields only if they are not null and not empty
      if (noKtp != null && noKtp.isNotEmpty) {
        data["no_ktp"] = noKtp;
      }
      if (tanggalLahir != null && tanggalLahir.isNotEmpty) {
        data["tanggal_lahir"] = tanggalLahir;
      }
      if (usiaKehamilan != null) {
        data["usia_kehamilan"] = usiaKehamilan;
      }
      if (tanggalHpht != null && tanggalHpht.isNotEmpty) {
        data["tanggal_hpht"] = tanggalHpht;
      }

      final response = await _httpService.put('/profile', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to edit profile: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Method to update FCM token after successful login
  Future<Map<String, dynamic>> updateFcmToken(String fcmToken, String platform) async {
    try {
      final response = await _httpService.post('/fcm-token', data: {'fcm_token': fcmToken, 'platform': platform});

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update FCM token: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
