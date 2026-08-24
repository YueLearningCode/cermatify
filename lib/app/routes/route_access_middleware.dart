import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/session_state.dart';

class GuestOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!SessionState.isLoggedIn) return null;
    return RouteSettings(name: _homeForRole(SessionState.role));
  }
}

class AuthenticatedMiddleware extends GetMiddleware {
  AuthenticatedMiddleware({this.allowedRoles});

  final Set<String>? allowedRoles;

  @override
  RouteSettings? redirect(String? route) {
    if (!SessionState.isLoggedIn) {
      return RouteSettings(
        name: '/login',
        arguments: <String, String?>{'redirect': route},
      );
    }

    final role = SessionState.role;
    if (allowedRoles != null && !allowedRoles!.contains(role)) {
      return RouteSettings(name: _homeForRole(role));
    }
    return null;
  }
}

String _homeForRole(String? role) =>
    role == 'admin' ? '/admin-dashboard' : '/dashboard';
