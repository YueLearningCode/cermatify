import 'package:cermatify/app/data/services/app_logger.dart';
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
  final String? verificationStatus; // For mentors only
  final String accountStatus;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.role,
    this.verificationStatus,
    this.accountStatus = 'active',
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: doc.id,
      name: data['nama'] ?? data['namaLengkap'] ?? 'Unknown',
      email: data['email'] ?? '',
      image: data['image'] ?? data['foto'],
      role: data['role'] ?? 'customer',
      verificationStatus:
          data['verificationStatus']
              as String?, // null or 'pending' or 'verified'
      accountStatus: data['accountStatus']?.toString() ?? 'active',
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
  final searchQuery = ''.obs;

  List<UserData> get filteredUsers => _filterUsers(usersList);
  List<UserData> get filteredMentors => _filterUsers(mentorsList);

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
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
      AppLogger.info('Error fetching users: $e');
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

  Future<void> toggleMentorStatus(
    String mentorId,
    String? currentStatus,
  ) async {
    try {
      isUpdating.value = true;

      // Toggle between 'pending' and 'verified'
      // If currentStatus is 'verified', change to 'pending'
      // If currentStatus is 'pending' or null, change to 'verified'
      final newStatus = (currentStatus == 'verified') ? 'pending' : 'verified';

      await _firestore.collection('users').doc(mentorId).update({
        'verificationStatus': newStatus,
      });

      // Update local list
      final index = mentorsList.indexWhere((mentor) => mentor.id == mentorId);
      if (index != -1) {
        mentorsList[index] = UserData(
          id: mentorsList[index].id,
          name: mentorsList[index].name,
          email: mentorsList[index].email,
          image: mentorsList[index].image,
          role: mentorsList[index].role,
          verificationStatus: newStatus,
          accountStatus: mentorsList[index].accountStatus,
        );
        mentorsList.refresh();
      }

      CustomSnackbar.show(
        title: 'Success',
        message: newStatus == 'verified'
            ? 'Mentor verified successfully'
            : 'Mentor verification set to pending',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (e) {
      AppLogger.info('Error updating mentor verification status: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to update mentor verification status: $e',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> toggleAccountAccess(UserData account) async {
    if (isUpdating.value) return;
    final disabled = account.accountStatus == 'disabled';
    final nextStatus = disabled ? 'active' : 'disabled';
    isUpdating.value = true;
    try {
      await _firestore.collection('users').doc(account.id).update({
        'accountStatus': nextStatus,
        'accountStatusUpdatedAt': FieldValue.serverTimestamp(),
      });
      final list = account.role == 'mentor' ? mentorsList : usersList;
      final index = list.indexWhere((item) => item.id == account.id);
      if (index >= 0) {
        list[index] = UserData(
          id: account.id,
          name: account.name,
          email: account.email,
          image: account.image,
          role: account.role,
          verificationStatus: account.verificationStatus,
          accountStatus: nextStatus,
        );
        list.refresh();
      }
      CustomSnackbar.show(
        title: disabled ? 'Akses dipulihkan' : 'Akses dinonaktifkan',
        message: disabled
            ? '${account.name} dapat masuk kembali.'
            : '${account.name} tidak dapat masuk hingga akses dipulihkan.',
        backgroundColor: disabled ? AppColors.greenColor : AppColors.redColor,
        isNav: false,
      );
    } catch (error) {
      AppLogger.info('Error updating account access: $error');
      CustomSnackbar.show(
        title: 'Perubahan gagal',
        message: 'Status akses akun belum dapat diperbarui.',
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

  void updateSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  List<UserData> _filterUsers(List<UserData> source) {
    final query = searchQuery.value;
    if (query.isEmpty) return source.toList(growable: false);

    return source
        .where(
          (user) =>
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> fetchUserFullData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      AppLogger.info('Error fetching user detail: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchMentorFullData(String mentorId) {
    return fetchUserFullData(mentorId);
  }
}
