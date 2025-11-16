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

  // Kampus dropdown
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
  var selectedKampus = ''.obs;

  // Jurusan dropdown
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
  var selectedJurusan = ''.obs;

  // Semester dropdown (available for all users)
  final List<String> listSemester = ['1', '2', '3', '4', '5', '6', '7', '8'];
  var selectedSemester = ''.obs;

  // Mentor role dropdown (only for mentors)
  final List<String> listMentorRole = ['complink', 'paperlink'];
  var selectedMentorRole = ''.obs;

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
  var selectedLayanan = <String>[].obs;

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

    // Add listeners to all text controllers to trigger validation check
    namaController.addListener(_checkFormValidity);
    emailController.addListener(_checkFormValidity);
    passwordController.addListener(_checkFormValidity);
    confirmPasswordController.addListener(_checkFormValidity);
    noTelpController.addListener(_checkFormValidity);
    // Listen to observable changes
    ever(agreeToTerms, (_) => _checkFormValidity());
    ever(selectedKampus, (_) => _checkFormValidity());
    ever(selectedJurusan, (_) => _checkFormValidity());
    ever(selectedSemester, (_) => _checkFormValidity());
    ever(selectedMentorRole, (_) => _checkFormValidity());
    ever(selectedLayanan, (_) => _checkFormValidity());
    ever(userRole, (_) => _checkFormValidity());
  }

  @override
  void onClose() {
    namaController.removeListener(_checkFormValidity);
    emailController.removeListener(_checkFormValidity);
    passwordController.removeListener(_checkFormValidity);
    confirmPasswordController.removeListener(_checkFormValidity);
    noTelpController.removeListener(_checkFormValidity);
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    noTelpController.dispose();
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

    isFormValid.value = true;
  }

  void toggleLayanan(String layanan) {
    if (selectedLayanan.contains(layanan)) {
      selectedLayanan.remove(layanan);
    } else {
      selectedLayanan.add(layanan);
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

      // Menyimpan data pengguna di Firestore
      final userData = {
        'id': userId,
        'nama': namaController.text.trim(),
        'email': emailController.text.trim(),
        'noTelp': noTelpController.text.trim(),
        'kampus': selectedKampus.value,
        'jurusan': selectedJurusan.value,
        'semester': selectedSemester.value,
        'image': 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png?20210521171500',
        'role': userRole.value,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add mentorRole and layanan only for mentors
      if (userRole.value == 'mentor') {
        if (selectedMentorRole.value.isNotEmpty) {
          userData['mentorRole'] = selectedMentorRole.value;
        }
        if (selectedLayanan.isNotEmpty) {
          userData['layanan'] = selectedLayanan;
        }
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
