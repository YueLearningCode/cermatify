import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/routes/app_pages.dart';

class CreateKuesionerController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Konfigurasi Cloudinary untuk upload gambar
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '885241489685565',
    apiSecret: 'Eo2Man-3sLzp9sCyYwslSXZFFtQ',
    cloudName: 'dvxsmpz3m',
  );

  final isLoading = false.obs;
  final paymentProofImage = Rxn<File>();
  final paymentProofUrl = ''.obs;

  // Criteria selections
  final selectedRentangUsia = ''.obs;
  final selectedJenisKelamin = ''.obs;
  final selectedTingkatPenghasilan = ''.obs;
  final selectedPendidikanTerakhir = ''.obs;
  final linkController = TextEditingController();

  // Dropdown options
  final List<String> rentangUsiaOptions = [
    '18-25 tahun',
    '26-35 tahun',
    '36-45 tahun',
    '46-55 tahun',
    '56 tahun ke atas',
  ];

  final List<String> jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  final List<String> tingkatPenghasilanOptions = [
    'Rp 0 - Rp 2.000.000',
    'Rp 2.000.000 - Rp 5.000.000',
    'Rp 5.000.000 - Rp 10.000.000',
    'Rp 10.000.000 - Rp 20.000.000',
    '> Rp 20.000.000',
  ];

  final List<String> pendidikanTerakhirOptions = [
    'SD/Sederajat',
    'SMP/Sederajat',
    'SMA/Sederajat',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];

  // Check if at least one criteria is selected
  bool get hasAtLeastOneCriteria {
    return selectedRentangUsia.value.isNotEmpty ||
        selectedJenisKelamin.value.isNotEmpty ||
        selectedTingkatPenghasilan.value.isNotEmpty ||
        selectedPendidikanTerakhir.value.isNotEmpty;
  }

  // Check if form is valid (no payment proof needed, already paid)
  bool get isFormValid {
    return linkController.text.trim().isNotEmpty && hasAtLeastOneCriteria;
  }

  // Create order first (called from payment dialog)
  // Returns orderId if successful, null if failed
  Future<String?> createOrder() async {
    try {
      if (paymentProofImage.value == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Please upload payment proof',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return null;
      }

      isLoading.value = true;

      final User? user = _auth.currentUser;
      if (user == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'User tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return null;
      }

      // Upload payment proof image to Cloudinary
      final File imageFile = paymentProofImage.value!;
      if (!imageFile.existsSync()) {
        throw Exception('File does not exist');
      }

      final cloudinaryResponse = await cloudinary.upload(
        fileBytes: imageFile.readAsBytesSync(),
        fileName: 'kuesioner_payment_${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
        resourceType: CloudinaryResourceType.image,
      );

      final String? secureUrl = cloudinaryResponse.secureUrl;
      if (secureUrl == null) {
        throw Exception('Failed to get image URL from Cloudinary');
      }

      // Find admin user for mentorId
      String? adminMentorId;
      try {
        final adminSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'admin').limit(1).get();
        if (adminSnapshot.docs.isNotEmpty) {
          adminMentorId = adminSnapshot.docs.first.id;
        }
      } catch (e) {
        print('Error finding admin: $e');
      }

      // Create order for kuesioner (25000)
      final orderData = {
        'userId': user.uid,
        'mentorId': adminMentorId ?? 'system',
        'layananId': 'kuesioner',
        'layananType': 'kuesioner',
        'price': 25000,
        'paymentProofUrl': secureUrl,
        'status': 'waiting verification',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final DocumentReference orderRef = await _firestore.collection('orders').add(orderData);
      final String orderId = orderRef.id;

      // Return orderId - don't create kuesioner yet, user needs to fill criteria first
      return orderId;
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal membuat order: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Create kuesioner (called after order is created)
  Future<void> createKuesioner({required String orderId}) async {
    try {
      // Validate form
      final link = linkController.text.trim();
      if (link.isEmpty) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Link kuesioner tidak boleh kosong',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      if (!hasAtLeastOneCriteria) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Pilih minimal satu kriteria responden',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      isLoading.value = true;

      final User? user = _auth.currentUser;
      if (user == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'User tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Create kuesioner document
      final kuesionerData = {
        'userId': user.uid,
        'orderId': orderId, // Use the orderId passed as parameter
        'link': link, // Link is required and validated above
        'status': 'waiting verification',
        'rentangUsia': selectedRentangUsia.value.isEmpty ? null : selectedRentangUsia.value,
        'jenisKelamin': selectedJenisKelamin.value.isEmpty ? null : selectedJenisKelamin.value,
        'tingkatPenghasilan': selectedTingkatPenghasilan.value.isEmpty ? null : selectedTingkatPenghasilan.value,
        'pendidikanTerakhir': selectedPendidikanTerakhir.value.isEmpty ? null : selectedPendidikanTerakhir.value,
        'answers': [],
        'signedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore - link is guaranteed to be non-empty due to validation above
      final docRef = await _firestore.collection('kuesioners').add(kuesionerData);

      // Verify link was saved (for debugging)
      print('Kuesioner created with ID: ${docRef.id}');
      print('Link saved: $link');

      CustomSnackbar.show(
        title: 'Berhasil',
        message: 'Pembuatan kuesioner berhasil. Menunggu verifikasi admin.',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );

      // Navigate to dashboard first (clear all routes)
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal membuat kuesioner: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick payment proof image
  Future<void> pickPaymentProofImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        paymentProofImage.value = File(pickedFile.path);
        paymentProofUrl.value = '';
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to pick image: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    }
  }

  // Remove payment proof image
  void removePaymentProofImage() {
    paymentProofImage.value = null;
    paymentProofUrl.value = '';
  }

  @override
  void onClose() {
    linkController.dispose();
    paymentProofImage.value = null;
    super.onClose();
  }
}
