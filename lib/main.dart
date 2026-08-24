import 'package:cermatify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/data/services/firebase_web_service.dart';
import 'app/data/services/session_state.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseWebService.initialize();
  await SessionState.initialize();

  await initializeDateFormatting('id_ID');

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cermatify",
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        focusColor: const Color(0xFF1E88E5).withValues(alpha: 0.20),
        hoverColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
        splashColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      unknownRoute: AppPages.unknownRoute,
    ),
  );
}
