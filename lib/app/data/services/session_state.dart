import 'package:shared_preferences/shared_preferences.dart';

/// Cached UI session used by synchronous GetX route middleware.
///
/// Firestore Security Rules remain the authority for data access. This cache
/// only prevents accidental navigation to screens that do not match the role.
class SessionState {
  SessionState._();

  static const _loggedInKey = 'isLoggedIn';
  static const _roleKey = 'userRole';

  static bool _isLoggedIn = false;
  static String? _role;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get role => _role;

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _isLoggedIn = preferences.getBool(_loggedInKey) ?? false;
    _role = preferences.getString(_roleKey);

    if (!_isKnownRole(_role)) {
      _isLoggedIn = false;
      _role = null;
    }
  }

  static Future<void> markAuthenticated(String role) async {
    if (!_isKnownRole(role)) {
      throw ArgumentError.value(role, 'role', 'Role tidak dikenal');
    }

    _isLoggedIn = true;
    _role = role;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_loggedInKey, true);
    await preferences.setString(_roleKey, role);
  }

  static Future<void> clear() async {
    _isLoggedIn = false;
    _role = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_loggedInKey, false);
    await preferences.remove(_roleKey);
  }

  static bool _isKnownRole(String? role) =>
      role == 'customer' || role == 'mentor' || role == 'admin';

  /// Allows isolated middleware tests without initializing platform storage.
  static void setForTesting({required bool isLoggedIn, String? role}) {
    _isLoggedIn = isLoggedIn;
    _role = role;
  }
}
