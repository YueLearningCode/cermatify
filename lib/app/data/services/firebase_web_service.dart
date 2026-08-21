import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Konfigurasi Firebase yang hanya diperlukan saat aplikasi berjalan di web.
abstract final class FirebaseWebService {
  static const String _recaptchaSiteKey = String.fromEnvironment(
    'FIREBASE_RECAPTCHA_SITE_KEY',
  );

  static Future<void> initialize() async {
    if (!kIsWeb) {
      return;
    }

    if (_recaptchaSiteKey.trim().isEmpty) {
      if (kReleaseMode) {
        throw StateError(
          'FIREBASE_RECAPTCHA_SITE_KEY wajib diisi untuk build web release.',
        );
      }

      debugPrint(
        'Firebase App Check dilewati: FIREBASE_RECAPTCHA_SITE_KEY belum diisi.',
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaV3Provider(_recaptchaSiteKey.trim()),
      );
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    }

    // Pertahankan sesi pada origin browser yang sama sampai pengguna logout.
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
}
