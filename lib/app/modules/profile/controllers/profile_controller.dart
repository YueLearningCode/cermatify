import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Konfigurasi Cloudinary untuk upload gambar
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '885241489685565',
    apiSecret: 'Eo2Man-3sLzp9sCyYwslSXZFFtQ',
    cloudName: 'dvxsmpz3m',
  );

  final userName = 'User'.obs;
  final userEmail = ''.obs;
  final userImage = ''.obs;
  final userKampus = ''.obs;
  final userJurusan = ''.obs;
  final userSemester = ''.obs;
  final userRole = 'customer'.obs;
  final userMentorRole = ''.obs;
  final userLayanan = <String>[].obs;
  final isLoading = false.obs;
  final mentorOrders = <Map<String, dynamic>>[].obs;
  final isLoadingOrders = false.obs;
  final saldo = 0.obs;

  // Dropdown lists for edit profile - fetched from Firebase
  final listKampus = <Map<String, String>>[].obs; // [{id: '...', name: '...'}]
  final listJurusan = <Map<String, String>>[].obs; // [{id: '...', name: '...', kampusId: '...'}]

  final List<String> listSemester = ['1', '2', '3', '4', '5', '6', '7', '8'];

  // Mentor role dropdown (only for mentors)
  final List<String> listMentorRole = ['complink', 'paperlink'];

  // Layanan (services) for mentors only - fetched from Firebase
  final listLayanan = <Map<String, String>>[].obs; // [{id: '...', name: '...', type: 'complink'|'paperlink'}]

  // Get available layanan filtered by mentor role
  List<Map<String, String>> get availableLayanan {
    if (selectedMentorRole.value.isEmpty) return [];
    return listLayanan.where((layanan) => layanan['type'] == selectedMentorRole.value).toList();
  }

  // Selected values for dropdowns in edit profile
  var selectedKampus = ''.obs; // Store kampus ID
  var selectedJurusan = ''.obs; // Store jurusan ID
  var selectedSemester = ''.obs;
  var selectedMentorRole = ''.obs;
  var selectedLayanan = <String>[].obs; // Store layanan IDs

  // Get filtered jurusan list based on selected kampus
  List<Map<String, String>> get filteredJurusan {
    if (selectedKampus.value.isEmpty) return [];
    return listJurusan.where((jurusan) => jurusan['kampusId'] == selectedKampus.value).toList();
  }

  // Initialize dropdown values from user data
  void initializeEditProfileValues() async {
    // Fetch master data first
    await fetchMasterData();

    // Find kampus ID from name
    final kampusMap = listKampus.firstWhereOrNull((k) => k['name'] == userKampus.value);
    selectedKampus.value = kampusMap?['id'] ?? '';

    // Find jurusan ID from name
    final jurusanMap = listJurusan.firstWhereOrNull((j) => j['name'] == userJurusan.value);
    selectedJurusan.value = jurusanMap?['id'] ?? '';

    selectedSemester.value = userSemester.value;
    selectedMentorRole.value = userMentorRole.value;

    // Find layanan IDs from names
    selectedLayanan.value = userLayanan
        .map((name) {
          return listLayanan.firstWhereOrNull((l) => l['name'] == name)?['id'] ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  // Fetch master data from Firebase
  Future<void> fetchMasterData() async {
    try {
      // Fetch kampus
      final kampusSnapshot = await _firestore.collection('kampus').get();
      listKampus.value = kampusSnapshot.docs
          .map((doc) {
            return {'id': doc.id, 'name': doc.data()['name']?.toString() ?? ''};
          })
          .toList()
          .cast<Map<String, String>>();

      // Fetch all jurusan
      final jurusanSnapshot = await _firestore.collection('jurusan').get();
      listJurusan.value = jurusanSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name']?.toString() ?? '',
              'kampusId': data['kampusId']?.toString() ?? '',
            };
          })
          .toList()
          .cast<Map<String, String>>();

      // Fetch layanan
      final layananSnapshot = await _firestore.collection('layanan').get();
      listLayanan.value = layananSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {'id': doc.id, 'name': data['name']?.toString() ?? '', 'type': data['type']?.toString() ?? ''};
          })
          .toList()
          .cast<Map<String, String>>();
    } catch (e) {
      print('Error fetching master data: $e');
    }
  }

  void toggleLayanan(String layananId) {
    if (selectedLayanan.contains(layananId)) {
      selectedLayanan.remove(layananId);
    } else {
      selectedLayanan.add(layananId);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchMasterData();
    fetchUserData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _saldoSubscription?.cancel();
    super.onClose();
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _saldoSubscription;

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          userName.value = data['nama'] ?? user.displayName ?? 'User';
          userEmail.value = data['email'] ?? user.email ?? '';
          userImage.value = data['image'] ?? '';
          userKampus.value = data['kampus'] ?? '';
          userJurusan.value = data['jurusan'] ?? '';
          userSemester.value = data['semester'] ?? '';
          userRole.value = data['role'] ?? 'customer';
          userMentorRole.value = data['mentorRole'] ?? '';
          if (data['layanan'] != null && data['layanan'] is List) {
            userLayanan.value = List<String>.from(data['layanan'] as List);
          } else {
            userLayanan.value = <String>[];
          }

          // Fetch saldo and mentor orders if user is a mentor
          if (userRole.value == 'mentor') {
            // Get saldo from user document
            saldo.value = (data['saldo'] as int?) ?? 0;
            fetchMentorOrders();
            setupSaldoListener();
          } else {
            saldo.value = 0;
          }
        } else {
          userName.value = user.displayName ?? 'User';
          userEmail.value = user.email ?? '';
          saldo.value = 0;
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMentorOrders() async {
    try {
      isLoadingOrders.value = true;
      final User? user = _auth.currentUser;
      if (user == null) {
        mentorOrders.value = [];
        return;
      }

      // Query orders where mentorId equals current user ID and status is 'progress'
      final querySnapshot = await _firestore
          .collection('orders')
          .where('mentorId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'progress')
          .get();

      List<Map<String, dynamic>> ordersList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      // Fetch customer and layanan names for each order
      for (var order in ordersList) {
        final customerId = order['userId']?.toString();
        final layananId = order['layananId']?.toString();

        // Fetch customer name
        if (customerId != null && customerId.isNotEmpty) {
          try {
            final customerDoc = await _firestore.collection('users').doc(customerId).get();
            if (customerDoc.exists) {
              final customerData = customerDoc.data();
              order['customerName'] = customerData?['nama'] ?? customerData?['name'] ?? 'Unknown Customer';
            } else {
              order['customerName'] = 'Unknown Customer';
            }
          } catch (e) {
            print('Error fetching customer name: $e');
            order['customerName'] = 'Unknown Customer';
          }
        } else {
          order['customerName'] = 'Unknown Customer';
        }

        // Fetch layanan name
        if (layananId != null && layananId.isNotEmpty) {
          try {
            final layananDoc = await _firestore.collection('layanan').doc(layananId).get();
            if (layananDoc.exists) {
              final layananData = layananDoc.data();
              order['layananName'] = layananData?['name'] ?? 'Unknown Layanan';
            } else {
              order['layananName'] = 'Unknown Layanan';
            }
          } catch (e) {
            print('Error fetching layanan name: $e');
            order['layananName'] = 'Unknown Layanan';
          }
        } else {
          order['layananName'] = 'Unknown Layanan';
        }
      }

      // Sort by createdAt (newest first)
      ordersList.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime); // Descending (newest first)
        }
        return 0;
      });

      mentorOrders.value = ordersList;
    } catch (e) {
      print('Error fetching mentor orders: $e');
      mentorOrders.value = [];
    } finally {
      isLoadingOrders.value = false;
    }
  }

  void setupSaldoListener() {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // Cancel existing subscription
    _saldoSubscription?.cancel();

    // Set up real-time listener for user document to update saldo
    _saldoSubscription = _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          saldo.value = (data['saldo'] as int?) ?? 0;
        }
      }
    });
  }

  Future<bool> updateProfile({
    required String nama,
    required String kampusId,
    required String jurusanId,
    required String semester,
    String? mentorRole,
    List<String>? layananIds,
  }) async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user != null) {
        // Get kampus and jurusan names from IDs
        final kampusName = listKampus.firstWhereOrNull((k) => k['id'] == kampusId)?['name'] ?? kampusId;
        final jurusanName = filteredJurusan.firstWhereOrNull((j) => j['id'] == jurusanId)?['name'] ?? jurusanId;

        // Get layanan names from IDs
        final layananNames =
            layananIds?.map((id) {
              return availableLayanan.firstWhereOrNull((l) => l['id'] == id)?['name'] ?? id;
            }).toList() ??
            [];

        final Map<String, dynamic> updateData = {
          'nama': nama,
          'kampus': kampusName,
          'kampusId': kampusId,
          'jurusan': jurusanName,
          'jurusanId': jurusanId,
          'semester': semester,
        };

        // Add mentor role and layanan only for mentors
        if (userRole.value == 'mentor') {
          if (mentorRole != null && mentorRole.isNotEmpty) {
            updateData['mentorRole'] = mentorRole;
          }
          if (layananNames.isNotEmpty) {
            updateData['layanan'] = layananNames;
            updateData['layananIds'] = layananIds;
          }
        }

        await _firestore.collection('users').doc(user.uid).update(updateData);

        await fetchUserData();
        return true;
      }
      return false;
    } catch (e) {
      CustomSnackbar.show(title: 'Error', message: 'Gagal memperbarui profil: $e', backgroundColor: AppColors.redColor);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      isLoading.value = true;

      final User? user = _auth.currentUser;
      if (user == null) {
        CustomSnackbar.show(title: 'Error', message: 'User tidak ditemukan', backgroundColor: AppColors.redColor);
        return;
      }

      // Upload image to Cloudinary
      final File imageFile = File(pickedFile.path);
      if (!imageFile.existsSync()) {
        throw Exception('File does not exist at ${pickedFile.path}');
      }

      final cloudinaryResponse = await cloudinary.upload(
        fileBytes: imageFile.readAsBytesSync(),
        fileName: 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
        resourceType: CloudinaryResourceType.image,
      );

      final String? secureUrl = cloudinaryResponse.secureUrl;
      if (secureUrl == null) {
        throw Exception('Failed to get image URL from Cloudinary');
      }
      final String downloadUrl = secureUrl;

      // Update user document in Firestore
      await _firestore.collection('users').doc(user.uid).update({'image': downloadUrl});

      // Update local state
      userImage.value = downloadUrl;

      // Update Firebase Auth profile photo
      await user.updatePhotoURL(downloadUrl);

      await fetchUserData();

      CustomSnackbar.show(
        title: 'Sukses',
        message: 'Foto profil berhasil diperbarui',
        backgroundColor: AppColors.greenColor,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal memperbarui foto profil: $e',
        backgroundColor: AppColors.redColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // Clear SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userRole');

      // Sign out from Firebase
      await _auth.signOut();

      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);

      CustomSnackbar.show(
        title: 'Sukses',
        message: 'Anda telah berhasil logout',
        backgroundColor: AppColors.greenColor,
      );
    } catch (e) {
      CustomSnackbar.show(title: 'Error', message: 'Gagal logout: $e', backgroundColor: AppColors.redColor);
    }
  }
}
