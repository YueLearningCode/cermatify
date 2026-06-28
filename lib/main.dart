import 'package:cermatify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('id_ID');

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cermatify",
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: false),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
