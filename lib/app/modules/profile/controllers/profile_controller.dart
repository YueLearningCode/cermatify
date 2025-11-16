import 'dart:io';
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

  // Dropdown lists for edit profile
  final List<String> listKampus = [
    'Universitas Indonesia (UI)',
    'Institut Teknologi Bandung (ITB)',
    'Universitas Gadjah Mada (UGM)',
    'Institut Teknologi Sepuluh Nopember (ITS)',
    'Universitas Padjadjaran (UNPAD)',
    'Universitas Brawijaya (UB)',
    'Universitas Diponegoro (UNDIP)',
    'Universitas Airlangga (UNAIR)',
    'Universitas Hasanuddin (UNHAS)',
    'Universitas Sumatera Utara (USU)',
  ];

  final List<String> listJurusan = [
    'Teknik Informatika',
    'Teknik Elektro',
    'Teknik Mesin',
    'Teknik Sipil',
    'Manajemen',
    'Akuntansi',
    'Kedokteran',
    'Hukum',
    'Psikologi',
    'Komunikasi',
  ];

  final List<String> listSemester = ['1', '2', '3', '4', '5', '6', '7', '8'];

  // Mentor role dropdown (only for mentors)
  final List<String> listMentorRole = ['complink', 'paperlink'];

  // Layanan (services) for mentors only
  final List<String> paperlinkLayanan = [
    "Bimbingan Penulisan Paper Ilmiah",
    "Bimbingan Skripsi/Tesis/Disertasi",
    "Bimbingan Publikasi Jurnal Scopus",
    "Bimbingan Publikasi Jurnal Sinta",
    "Bimbingan Riset Eksperimen (Lab)",
    "Bimbingan Analisis Data Kuantitatif",
    "Bimbingan Analisis Data Kualitatif",
    "Bimbingan Proposal Penelitian",
    "Bimbingan Lomba Karya Ilmiah (PKM, ONMIPA)",
    "Bimbingan Turnitin & Parafrase",
  ];
  final List<String> complinkLayanan = const [
    'Business Plan Competition',
    'Startup Competition',
    'Olimpiade Mahasiswa',
    'Data Science Competition',
    'Programming Competition',
    'Debat Mahasiswa',
  ];
  List<String> get availableLayanan => selectedMentorRole.value == 'complink' ? complinkLayanan : paperlinkLayanan;

  // Selected values for dropdowns in edit profile
  var selectedKampus = ''.obs;
  var selectedJurusan = ''.obs;
  var selectedSemester = ''.obs;
  var selectedMentorRole = ''.obs;
  var selectedLayanan = <String>[].obs;

  // Initialize dropdown values from user data
  void initializeEditProfileValues() {
    selectedKampus.value = userKampus.value;
    selectedJurusan.value = userJurusan.value;
    selectedSemester.value = userSemester.value;
    selectedMentorRole.value = userMentorRole.value;
    selectedLayanan.value = List<String>.from(userLayanan);
  }

  void toggleLayanan(String layanan) {
    if (selectedLayanan.contains(layanan)) {
      selectedLayanan.remove(layanan);
    } else {
      selectedLayanan.add(layanan);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

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
        } else {
          userName.value = user.displayName ?? 'User';
          userEmail.value = user.email ?? '';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String nama,
    required String kampus,
    required String jurusan,
    required String semester,
    String? mentorRole,
    List<String>? layanan,
  }) async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user != null) {
        final Map<String, dynamic> updateData = {
          'nama': nama,
          'kampus': kampus,
          'jurusan': jurusan,
          'semester': semester,
        };

        // Add mentor role and layanan only for mentors
        if (userRole.value == 'mentor') {
          if (mentorRole != null && mentorRole.isNotEmpty) {
            updateData['mentorRole'] = mentorRole;
          }
          if (layanan != null && layanan.isNotEmpty) {
            updateData['layanan'] = layanan;
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
