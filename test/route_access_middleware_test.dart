import 'package:cermatify/app/data/services/session_state.dart';
import 'package:cermatify/app/routes/route_access_middleware.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    SessionState.setForTesting(isLoggedIn: false);
  });

  test('protected route redirects a guest to login', () {
    SessionState.setForTesting(isLoggedIn: false);

    final redirect = AuthenticatedMiddleware().redirect('/profile');

    expect(redirect?.name, '/login');
    expect(redirect?.arguments, {'redirect': '/profile'});
  });

  test('customer cannot open an admin route', () {
    SessionState.setForTesting(isLoggedIn: true, role: 'customer');

    final redirect = AuthenticatedMiddleware(
      allowedRoles: const {'admin'},
    ).redirect('/admin-dashboard');

    expect(redirect?.name, '/dashboard');
  });

  test('admin can open an admin route', () {
    SessionState.setForTesting(isLoggedIn: true, role: 'admin');

    final redirect = AuthenticatedMiddleware(
      allowedRoles: const {'admin'},
    ).redirect('/admin-dashboard');

    expect(redirect, isNull);
  });

  test('guest-only page redirects authenticated user by role', () {
    SessionState.setForTesting(isLoggedIn: true, role: 'admin');

    final redirect = GuestOnlyMiddleware().redirect('/login');

    expect(redirect?.name, '/admin-dashboard');
  });
}
