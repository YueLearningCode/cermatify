import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/dummy_sourcelink.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/sourcelink_controller.dart';
import '../../kuesioner/controllers/create_kuesioner_controller.dart';

class SourcelinkSubmitView extends GetView<SourcelinkController> {
  const SourcelinkSubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load saved criteria when view is built
    controller.loadSavedCriteria();

    return _SourcelinkSubmitViewStateful(controller: controller);
  }
}

class _SourcelinkSubmitViewStateful extends StatefulWidget {
  final SourcelinkController controller;

  const _SourcelinkSubmitViewStateful({required this.controller});

  @override
  State<_SourcelinkSubmitViewStateful> createState() => _SourcelinkSubmitViewStatefulState();
}

class _SourcelinkSubmitViewStatefulState extends State<_SourcelinkSubmitViewStateful> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '885241489685565',
    apiSecret: 'Eo2Man-3sLzp9sCyYwslSXZFFtQ',
    cloudName: 'dvxsmpz3m',
  );

  final isLoading = false.obs;
  final paymentProofImage = Rxn<File>();

  Future<void> _createOrderAndKuesioner() async {
    try {
      // Validate link
      if (widget.controller.linkController.text.trim().isEmpty) {
        CustomSnackbar.show(
          title: 'Perhatian',
          message: 'Masukkan link terlebih dahulu',
          backgroundColor: AppColors.error,
          isNav: false,
        );
        return;
      }

      // Validate payment proof
      if (paymentProofImage.value == null) {
        CustomSnackbar.show(
          title: 'Perhatian',
          message: 'Upload bukti pembayaran terlebih dahulu',
          backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.error,
          isNav: false,
        );
        return;
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

      // Map criteria from sourcelink format to kuesioner format
      final createController = Get.put(CreateKuesionerController());
      final usiaValue = widget.controller.selectedUsia.value;
      final kelaminValue = widget.controller.selectedKelamin.value;
      final penghasilanValue = widget.controller.selectedPenghasilan.value;
      final pendidikanValue = widget.controller.selectedPendidikan.value;

      // Map criteria - check if value exists in create_kuesioner options
      String? mappedUsia;
      if (createController.rentangUsiaOptions.contains(usiaValue)) {
        mappedUsia = usiaValue;
      } else if (usiaValue != dummyRentangUsia.first) {
        // Try to map similar values
        if (usiaValue.contains('56') || usiaValue.contains('65')) {
          mappedUsia = '56 tahun ke atas';
        }
      }

      String? mappedKelamin;
      if (createController.jenisKelaminOptions.contains(kelaminValue)) {
        mappedKelamin = kelaminValue;
      }

      String? mappedPenghasilan;
      if (createController.tingkatPenghasilanOptions.contains(penghasilanValue)) {
        mappedPenghasilan = penghasilanValue;
      } else if (penghasilanValue != dummyTingkatPenghasilan.first) {
        // Try to map similar values
        if (penghasilanValue.contains('0 - 2.000.000')) {
          mappedPenghasilan = '< Rp 2.000.000';
        } else if (penghasilanValue.contains('2.000.000 - 5.000.000')) {
          mappedPenghasilan = 'Rp 2.000.000 - Rp 5.000.000';
        } else if (penghasilanValue.contains('5.000.000 - 10.000.000')) {
          mappedPenghasilan = 'Rp 5.000.000 - Rp 10.000.000';
        } else if (penghasilanValue.contains('10.000.000 - 20.000.000')) {
          mappedPenghasilan = 'Rp 10.000.000 - Rp 20.000.000';
        } else if (penghasilanValue.contains('20.000.000')) {
          mappedPenghasilan = '> Rp 20.000.000';
        }
      }

      String? mappedPendidikan;
      if (createController.pendidikanTerakhirOptions.contains(pendidikanValue)) {
        mappedPendidikan = pendidikanValue;
      } else if (pendidikanValue != dummyPendidikanTerakhir.first) {
        // Try to map similar values
        if (pendidikanValue.contains('Diploma')) {
          mappedPendidikan = 'D1/D2/D3';
        } else if (pendidikanValue == 'S1') {
          mappedPendidikan = 'S1/D4';
        }
      }

      // Check if at least one criteria is selected
      if (mappedUsia == null && mappedKelamin == null && mappedPenghasilan == null && mappedPendidikan == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Pilih minimal satu kriteria responden',
          backgroundColor: AppColors.error,
          isNav: false,
        );
        return;
      }

      // Create kuesioner document
      final kuesionerData = {
        'userId': user.uid,
        'orderId': orderId,
        'link': widget.controller.linkController.text.trim(),
        'status': 'waiting verification',
        'rentangUsia': mappedUsia,
        'jenisKelamin': mappedKelamin,
        'tingkatPenghasilan': mappedPenghasilan,
        'pendidikanTerakhir': mappedPendidikan,
        'answers': [],
        'signedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('kuesioners').add(kuesionerData);

      // Clear saved criteria after successful creation
      await widget.controller.clearSavedCriteria();

      // Show success snackbar
      CustomSnackbar.show(
        title: 'Berhasil',
        message: 'Pembuatan kuesioner berhasil. Menunggu verifikasi admin.',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );

      // Navigate to dashboard and clear navigation stack
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal membuat kuesioner: ${e.toString()}',
        backgroundColor: AppColors.error,
        isNav: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _pickPaymentProof(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        setState(() {
          paymentProofImage.value = File(pickedFile.path);
        });
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal memilih gambar: ${e.toString()}',
        backgroundColor: AppColors.error,
        isNav: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header dengan gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sebarkan Kuesioner',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Masukkan link Google Form Anda',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Link akan disebarkan ke responden yang sesuai dengan kriteria yang telah dipilih',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Konten form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Card container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon dan judul section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link_rounded, color: AppColors.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "Link Google Form",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Input field
                        Text(
                          "Masukkan Link",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: widget.controller.linkController,
                          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "https://forms.gle/abcd1234xyz",
                            hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(Icons.link, color: AppColors.textLight, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pastikan link Google Form sudah dalam mode 'Dapat mengisi'",
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
                        ),
                        const SizedBox(height: 32),
                        // QRIS Section
                        Text(
                          "QRIS Pembayaran",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              // QR Code Image from Assets
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Image.asset(
                                  'assets/images/qrqris.jpeg',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Price display
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        'Rp',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppFormats.hargaPendek(25000),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Payment Proof Section
                        Text(
                          "Bukti Pembayaran",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => paymentProofImage.value != null
                              ? Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(paymentProofImage.value!, fit: BoxFit.cover),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _pickPaymentProof(ImageSource.gallery),
                                            icon: const Icon(Icons.edit, size: 18),
                                            label: Text('Ganti', style: GoogleFonts.poppins()),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              side: const BorderSide(color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                paymentProofImage.value = null;
                                              });
                                            },
                                            icon: const Icon(Icons.delete_outline, size: 18),
                                            label: Text('Hapus', style: GoogleFonts.poppins()),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                              side: const BorderSide(color: AppColors.error),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_outlined, size: 48, color: AppColors.textLight),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Belum ada bukti pembayaran',
                                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _pickPaymentProof(ImageSource.camera),
                                            icon: const Icon(Icons.camera_alt, size: 18),
                                            label: Text('Kamera', style: GoogleFonts.poppins()),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              side: const BorderSide(color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _pickPaymentProof(ImageSource.gallery),
                                            icon: const Icon(Icons.photo_library, size: 18),
                                            label: Text('Galeri', style: GoogleFonts.poppins()),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              side: const BorderSide(color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 32),
                        // Button submit
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                elevation: 2,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                              onPressed: isLoading.value ? null : () => _createOrderAndKuesioner(),
                              child: isLoading.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Buat Kuesioner",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tips section
                  const SizedBox(height: 24),
                  _buildTipsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Penyebaran Kuesioner',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Pastikan kuesioner tidak meminta data pribadi sensitif\n'
                  '• Gunakan pertanyaan yang jelas dan mudah dipahami\n'
                  '• Test kuesioner terlebih dahulu sebelum menyebar\n'
                  '• Perkirakan waktu pengisian yang diperlukan',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
