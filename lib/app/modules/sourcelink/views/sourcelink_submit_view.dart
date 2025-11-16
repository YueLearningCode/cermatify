import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/sourcelink_controller.dart';

class SourcelinkSubmitView extends GetView<SourcelinkController> {
  const SourcelinkSubmitView({super.key});

  void _showSuccessDialog() {
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 8),
            Text(
              "Berhasil!",
              style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          "Link berhasil disebar ke peserta kuesioner. Anda akan menerima notifikasi ketika responden mulai mengisi.",
          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              "Kembali ke Beranda",
              style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
                          controller: controller.linkController,
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
                        // Button sebarkan
                        SizedBox(
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
                            onPressed: () async {
                              if (controller.linkController.text.isEmpty) {
                                Get.snackbar(
                                  'Perhatian',
                                  'Masukkan link terlebih dahulu',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.error,
                                  colorText: Colors.white,
                                  borderRadius: 8,
                                  margin: const EdgeInsets.all(16),
                                  icon: const Icon(Icons.error_outline, color: Colors.white, size: 20),
                                );
                                return;
                              }
                              await controller.createKuesioner();
                              _showSuccessDialog();
                            },
                            child: Obx(
                              () => controller.isSubmitting.value
                                  ? SizedBox(
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
                                        const Icon(Icons.share_rounded, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Sebarkan Link",
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
