import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;
  final userName = 'User'.obs;
  final userImage = ''.obs;
  final isMentor = false.obs;
  Timer? _timer;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> bannerImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  @override
  void onInit() {
    super.onInit();
    _startAutoSlide();
    _fetchUserData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (currentPage.value < bannerImages.length - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          userName.value = data['nama'] ?? user.displayName ?? 'User';
          userImage.value = data['image'] ?? '';
          isMentor.value = (data['role'] as String?) == 'mentor';
        } else {
          // Fallback to display name if Firestore doc doesn't exist
          userName.value = user.displayName ?? 'User';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      userName.value = 'User';
    }
  }
}
