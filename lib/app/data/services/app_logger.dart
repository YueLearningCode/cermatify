import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Development-only logging that is stripped from release behavior.
class AppLogger {
  AppLogger._();

  static void info(Object? message) {
    if (kDebugMode) {
      developer.log(message?.toString() ?? 'null', name: 'cermatify');
    }
  }
}
