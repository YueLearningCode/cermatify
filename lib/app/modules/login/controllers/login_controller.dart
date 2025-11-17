import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  // Controller input
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Instance FirebaseAuth untuk autentikasi pengguna.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variable.
  var isLoading = false.obs;
  var isLogin = false.obs;
  var isUserLogin = false.obs;
  var isCheckingSession = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthSession();
  }

  // Metode untuk menangani proses login menggunakan email dan password.
  Future<void> login() async {
    try {
      isLoading.value = true;

      // Login menggunakan Firebase Authentication.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Mengambil data pengguna dari Firestore.
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String userRole = userDoc['role'];

      // Save login status and role to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userRole', userRole);

      CustomSnackbar.show(
        title: 'Sukses',
        message: "Selamat datang di Cermatify",
        backgroundColor: AppColors.greenColor,
        isNav: true,
      );

      // Navigasi ke dashboard berdasarkan role.
      if (userRole == 'customer') {
        Get.offAllNamed(Routes.DASHBOARD);
      } else if (userRole == 'mentor') {
        Get.offAllNamed(Routes.DASHBOARD);
      } else if (userRole == 'admin') {
        Get.offAllNamed(Routes.ADMIN_DASHBOARD);
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: "Role tidak valid",
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      CustomSnackbar.show(title: 'Error', message: "${e.message}", backgroundColor: AppColors.redColor, isNav: false);
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk memeriksa status login berdasarkan Firebase Auth session.
  Future<void> checkAuthSession() async {
    try {
      isCheckingSession.value = true;

      // Check if there's a current Firebase Auth user
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // User has an active session, fetch role from Firestore
        try {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

          if (userDoc.exists) {
            String userRole = userDoc['role'] ?? 'customer';

            // Save login status and role to SharedPreferences for consistency
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userRole', userRole);

            // Navigate to dashboard based on role
            if (userRole == 'customer' || userRole == 'mentor') {
              Get.offAllNamed(Routes.DASHBOARD);
            } else if (userRole == 'admin') {
              Get.offAllNamed(Routes.ADMIN_DASHBOARD);
            } else {
              // Invalid role, sign out and show login
              await _auth.signOut();
              await _clearLoginData();
            }
          } else {
            // User document doesn't exist in Firestore, sign out
            await _auth.signOut();
            await _clearLoginData();
          }
        } catch (e) {
          // Error fetching user data, sign out and show login
          print('Error fetching user data: $e');
          await _auth.signOut();
          await _clearLoginData();
        }
      } else {
        // No active session, clear any stored data and stay on login page
        await _clearLoginData();
      }
    } catch (e) {
      print('Error checking auth session: $e');
      await _clearLoginData();
    } finally {
      isCheckingSession.value = false;
    }
  }

  // Helper method to clear login data
  Future<void> _clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userRole');
  }

  // Metode untuk memeriksa status login (kept for backward compatibility).
  Future<void> checkLoginStatus() async {
    await checkAuthSession();
  }
}
