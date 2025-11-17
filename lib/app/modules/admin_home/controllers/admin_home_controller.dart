import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeController extends GetxController {
  final userName = 'Admin'.obs;
  final userImage = ''.obs;
  final totalUsers = 0.obs;
  final totalMasterData = 0.obs;
  final isLoading = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
    _fetchStatistics();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          userName.value = data['nama'] ?? user.displayName ?? 'Admin';
          userImage.value = data['image'] ?? '';
        } else {
          userName.value = user.displayName ?? 'Admin';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      userName.value = 'Admin';
    }
  }

  Future<void> _fetchStatistics() async {
    try {
      isLoading.value = true;

      // Fetch total users count
      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers.value = usersSnapshot.docs.length;

      // Fetch total master data count from kampus, jurusan, and layanan collections
      try {
        final kampusSnapshot = await _firestore.collection('kampus').get();
        final jurusanSnapshot = await _firestore.collection('jurusan').get();
        final layananSnapshot = await _firestore.collection('layanan').get();
        totalMasterData.value = kampusSnapshot.docs.length + jurusanSnapshot.docs.length + layananSnapshot.docs.length;
      } catch (e) {
        print('Error fetching master data count: $e');
        totalMasterData.value = 0;
      }
    } catch (e) {
      print('Error fetching statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStatistics() async {
    await _fetchStatistics();
  }
}
