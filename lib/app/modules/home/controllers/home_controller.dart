import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final userName = 'User'.obs;
  final userImage = ''.obs;
  final isMentor = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
  }

  Future<void> refreshUserData() => _fetchUserData();

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!snapshot.exists) {
        userName.value = user.displayName ?? 'User';
        return;
      }
      final data = snapshot.data() ?? <String, dynamic>{};
      userName.value = data['nama']?.toString() ?? user.displayName ?? 'User';
      userImage.value = data['image']?.toString() ?? '';
      isMentor.value = data['role']?.toString() == 'mentor';
    } catch (error) {
      AppLogger.info('Error fetching user data: $error');
      userName.value = 'User';
    }
  }
}
