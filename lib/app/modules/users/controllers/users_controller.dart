import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class UserData {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String role;
  final bool? isActive; // For mentors only

  UserData({required this.id, required this.name, required this.email, this.image, required this.role, this.isActive});

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: doc.id,
      name: data['nama'] ?? data['namaLengkap'] ?? 'Unknown',
      email: data['email'] ?? '',
      image: data['image'] ?? data['foto'],
      role: data['role'] ?? 'customer',
      isActive: data['isActive'] ?? true, // Default to active
    );
  }
}

class UsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final selectedTab = 0.obs; // 0 = Users, 1 = Mentors
  final usersList = <UserData>[].obs;
  final mentorsList = <UserData>[].obs;
  final isLoading = false.obs;
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      final usersSnapshot = await _firestore.collection('users').get();

      final List<UserData> users = [];
      final List<UserData> mentors = [];

      for (var doc in usersSnapshot.docs) {
        final userData = UserData.fromFirestore(doc);

        // Exclude admin users
        if (userData.role == 'admin') continue;

        if (userData.role == 'customer') {
          users.add(userData);
        } else if (userData.role == 'mentor') {
          mentors.add(userData);
        }
      }

      usersList.value = users;
      mentorsList.value = mentors;
    } catch (e) {
      print('Error fetching users: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to fetch users: $e',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleMentorStatus(String mentorId, bool currentStatus) async {
    try {
      isUpdating.value = true;

      await _firestore.collection('users').doc(mentorId).update({'isActive': !currentStatus});

      // Update local list
      final index = mentorsList.indexWhere((mentor) => mentor.id == mentorId);
      if (index != -1) {
        mentorsList[index] = UserData(
          id: mentorsList[index].id,
          name: mentorsList[index].name,
          email: mentorsList[index].email,
          image: mentorsList[index].image,
          role: mentorsList[index].role,
          isActive: !currentStatus,
        );
        mentorsList.refresh();
      }

      CustomSnackbar.show(
        title: 'Success',
        message: !currentStatus ? 'Mentor activated successfully' : 'Mentor deactivated successfully',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (e) {
      print('Error updating mentor status: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to update mentor status: $e',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
