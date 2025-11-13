import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cermatify/app/data/repositories/auth_repository.dart';

class AuthService {
  static const String _loginCountKey = 'login_count';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _tokenKey = 'token';
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AuthService() : _authRepository = AuthRepository();

  Future<void> saveAuthData(Map<String, dynamic> loginResponse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = loginResponse['data']['token'];
    final userId = loginResponse['data']['user']['id'].toString();
    final userRole = loginResponse['data']['user']['role'];

    await _storage.write(key: _tokenKey, value: token);

    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userRoleKey, userRole);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<Map<String, dynamic>> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final userRole = prefs.getString(_userRoleKey);
    return {'id': userId, 'role': userRole ?? 'customer'};
  }

  Future<void> clearAuthData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await _storage.delete(key: _tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_loginCountKey);
    await prefs.remove(_userRoleKey);
  }

  Future<Map<String, dynamic>> login(String username, String password, {String? fcmToken}) async {
    try {
      final response = await _authRepository.login(username, password, fcmToken: fcmToken);
      if (response['success'] == true) {
        await saveAuthData(response);
      }
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await _authRepository.verifyToken();
      if (response['success'] == true) {
        return true;
      } else {
        await clearAuthData();
        return false;
      }
    } catch (e) {
      await clearAuthData();
      return false;
    }
  }
}
