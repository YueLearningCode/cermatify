import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// [RegisterController] adalah kelas yang mengelola logika registrasi pengguna.
class RegisterController extends GetxController {
  // Form key untuk validasi
  final formKey = GlobalKey<FormState>();

  // Controller input
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();

  // Kampus dropdown - fetched from Firebase
  final listKampus = <Map<String, String>>[].obs; // [{id: '...', name: '...'}]
  var selectedKampus = ''.obs; // Store kampus ID

  // Jurusan dropdown - fetched from Firebase, filtered by kampus
  final listJurusan = <Map<String, String>>[].obs; // [{id: '...', name: '...', kampusId: '...'}]
  var selectedJurusan = ''.obs; // Store jurusan ID

  // Semester dropdown (available for all users)
  final List<String> listSemester = ['1', '2', '3', '4', '5', '6', '7', '8'];
  var selectedSemester = ''.obs;

  // Mentor role dropdown (only for mentors)
  final List<String> listMentorRole = ['complink', 'paperlink'];
  var selectedMentorRole = ''.obs;

  // Layanan (services) for mentors only - fetched from Firebase
  final listLayanan = <Map<String, String>>[].obs; // [{id: '...', name: '...', type: 'complink'|'paperlink'}]
  var selectedLayanan = <String>[].obs; // Store layanan IDs

  // Get available layanan filtered by mentor role
  List<Map<String, String>> get availableLayanan {
    if (selectedMentorRole.value.isEmpty) return [];
    return listLayanan.where((layanan) => layanan['type'] == selectedMentorRole.value).toList();
  }

  var agreeToTerms = false.obs;
  var isFormValid = false.obs;
  var userRole = 'customer'.obs; // Default role

  @override
  void onInit() {
    super.onInit();
    // Get role from arguments if provided
    final arguments = Get.arguments;
    if (arguments == 'mentor') {
      userRole.value = 'mentor';
    }

    // Fetch master data from Firebase
    fetchMasterData();

    // Add listeners to all text controllers to trigger validation check
    namaController.addListener(_checkFormValidity);
    emailController.addListener(_checkFormValidity);
    passwordController.addListener(_checkFormValidity);
    confirmPasswordController.addListener(_checkFormValidity);
    noTelpController.addListener(_checkFormValidity);
    linkedinController.addListener(_checkFormValidity);
    // Listen to observable changes
    ever(agreeToTerms, (_) => _checkFormValidity());
    ever(selectedKampus, (_) {
      _checkFormValidity();
      _filterJurusanByKampus();
    });
    ever(selectedJurusan, (_) => _checkFormValidity());
    ever(selectedSemester, (_) => _checkFormValidity());
    ever(selectedMentorRole, (_) {
      _checkFormValidity();
      selectedLayanan.clear(); // Clear selected layanan when role changes
    });
    ever(selectedLayanan, (_) => _checkFormValidity());
    ever(userRole, (_) => _checkFormValidity());

    // Initial validation check
    Future.microtask(() => _checkFormValidity());
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

  // Filter jurusan by selected kampus
  void _filterJurusanByKampus() {
    if (selectedKampus.value.isEmpty) {
      selectedJurusan.value = '';
    }
  }

  // Get filtered jurusan list based on selected kampus
  List<Map<String, String>> get filteredJurusan {
    if (selectedKampus.value.isEmpty) return [];
    return listJurusan.where((jurusan) => jurusan['kampusId'] == selectedKampus.value).toList();
  }

  @override
  void onClose() {
    namaController.removeListener(_checkFormValidity);
    emailController.removeListener(_checkFormValidity);
    passwordController.removeListener(_checkFormValidity);
    confirmPasswordController.removeListener(_checkFormValidity);
    noTelpController.removeListener(_checkFormValidity);
    linkedinController.removeListener(_checkFormValidity);
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    noTelpController.dispose();
    linkedinController.dispose();
    super.onClose();
  }

  void toggleAgreeToTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // Method to check and update form validity
  void _checkFormValidity() {
    if (!agreeToTerms.value) {
      isFormValid.value = false;
      return;
    }

    final nama = namaController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Check if all required fields are filled
    if (nama.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      isFormValid.value = false;
      return;
    }

    // Check basic validations
    if (nama.length < 3) {
      isFormValid.value = false;
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      isFormValid.value = false;
      return;
    }
    if (password.length < 6) {
      isFormValid.value = false;
      return;
    }
    if (password != confirmPassword) {
      isFormValid.value = false;
      return;
    }

    // Check semester validation (required for all users)
    if (selectedSemester.value.isEmpty) {
      isFormValid.value = false;
      return;
    }

    // Check mentor role validation (required for mentors only)
    if (userRole.value == 'mentor' && selectedMentorRole.value.isEmpty) {
      isFormValid.value = false;
      return;
    }

    // Check layanan validation (required for mentors only, at least one must be selected)
    if (userRole.value == 'mentor' && selectedLayanan.isEmpty) {
      isFormValid.value = false;
      return;
    }

    // Check LinkedIn validation (required for mentors only)
    if (userRole.value == 'mentor') {
      final linkedin = linkedinController.text.trim();
      if (linkedin.isEmpty) {
        isFormValid.value = false;
        return;
      }
      // Validate LinkedIn URL format - accept various LinkedIn URL formats
      // Just check that it's a valid URL containing linkedin.com
      final lowerLinkedin = linkedin.toLowerCase();
      if (!lowerLinkedin.contains('linkedin.com')) {
        isFormValid.value = false;
        return;
      }
      // Check if it's a valid URL format
      final urlPattern = RegExp(r'^https?://[^\s/$.?#].[^\s]*$', caseSensitive: false);
      if (!urlPattern.hasMatch(linkedin)) {
        isFormValid.value = false;
        return;
      }
    }

    isFormValid.value = true;
  }

  void toggleLayanan(String layananId) {
    if (selectedLayanan.contains(layananId)) {
      selectedLayanan.remove(layananId);
    } else {
      selectedLayanan.add(layananId);
    }
  }

  /// Instance FirebaseAuth untuk autentikasi pengguna.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Instance FirebaseFirestore untuk menyimpan data pengguna.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  /// Fungsi untuk melakukan pendaftaran pengguna baru.
  /// Validasi dilakukan untuk memastikan semua field terisi sebelum melakukan registrasi.
  Future<void> register() async {
    // Validate form first
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Check if agree to terms is checked
    if (!agreeToTerms.value) {
      CustomSnackbar.show(
        title: 'Perhatian',
        message: 'Anda harus menyetujui Syarat dan Ketentuan untuk melanjutkan',
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Registrasi pengguna menggunakan Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update display name pengguna
      await userCredential.user?.updateDisplayName(namaController.text.trim());

      // Mengambil ID pengguna yang baru dibuat
      final userId = userCredential.user?.uid;

      // Get kampus and jurusan names from IDs
      final kampusName =
          listKampus.firstWhereOrNull((k) => k['id'] == selectedKampus.value)?['name'] ?? selectedKampus.value;
      final jurusanName =
          filteredJurusan.firstWhereOrNull((j) => j['id'] == selectedJurusan.value)?['name'] ?? selectedJurusan.value;

      // Get layanan names from IDs
      final layananNames = selectedLayanan.map((id) {
        return availableLayanan.firstWhereOrNull((l) => l['id'] == id)?['name'] ?? id;
      }).toList();

      // Menyimpan data pengguna di Firestore
      final userData = {
        'id': userId,
        'nama': namaController.text.trim(),
        'email': emailController.text.trim(),
        'noTelp': noTelpController.text.trim(),
        'kampus': kampusName,
        'kampusId': selectedKampus.value,
        'jurusan': jurusanName,
        'jurusanId': selectedJurusan.value,
        'semester': selectedSemester.value,
        'image': 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png?20210521171500',
        'role': userRole.value,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add mentorRole, layanan, LinkedIn, and verificationStatus only for mentors
      if (userRole.value == 'mentor') {
        if (selectedMentorRole.value.isNotEmpty) {
          userData['mentorRole'] = selectedMentorRole.value;
        }
        if (layananNames.isNotEmpty) {
          userData['layanan'] = layananNames;
          userData['layananIds'] = selectedLayanan;
        }
        if (linkedinController.text.trim().isNotEmpty) {
          userData['linkedin'] = linkedinController.text.trim();
        }
        // Set verification status to pending for new mentors
        userData['verificationStatus'] = 'pending';
      }

      await _firestore.collection('users').doc(userId).set(userData);

      Get.toNamed(Routes.LOGIN);

      // Menampilkan snackbar untuk sukses dan navigasi ke halaman login
      CustomSnackbar.show(
        title: 'Sukses',
        message: "Berhasil register dengan email ${userCredential.user?.email}",
        backgroundColor: AppColors.greenColor,
      );
    } on FirebaseAuthException catch (e) {
      CustomSnackbar.show(title: 'Error', message: "${e.message}", backgroundColor: AppColors.redColor);
    } finally {
      isLoading.value = false;
    }
  }
}
