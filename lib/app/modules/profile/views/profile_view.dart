import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    bool isOutlined = false,
  }) {
    return isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(color: textColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Pilih Sumber Gambar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text('Kamera', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: Text('Galeri', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Konfirmasi Logout",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        content: Text(
          "Apakah Anda yakin ingin logout dari akun ini?",
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(color: AppColors.textLight, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redColor,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Profil Saya",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Header Profile dengan Gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Foto Profil
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.surface.withOpacity(0.8), AppColors.primaryLight],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: controller.userImage.value.isNotEmpty
                                      ? NetworkImage(controller.userImage.value) as ImageProvider
                                      : const AssetImage('assets/images/profile_dummy.jpg'),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Obx(
                                  () => GestureDetector(
                                    onTap: controller.isLoading.value ? null : () => _showImageSourceDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                                              ),
                                            )
                                          : const Icon(Icons.camera_alt_rounded, color: AppColors.surface, size: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.userName.value,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.surface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.userEmail.value,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.surface.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (controller.userKampus.value.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.userKampus.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Informasi detail dalam card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.border.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (controller.userJurusan.value.isNotEmpty)
                            _buildInfoItem(
                              icon: Icons.school_rounded,
                              iconColor: AppColors.primary,
                              title: "Program Studi",
                              value: controller.userJurusan.value,
                            ),
                          if (controller.userJurusan.value.isNotEmpty && controller.userSemester.value.isNotEmpty)
                            const SizedBox(height: 16),
                          if (controller.userSemester.value.isNotEmpty)
                            _buildInfoItem(
                              icon: Icons.library_books_rounded,
                              iconColor: AppColors.primaryLight,
                              title: "Semester",
                              value: controller.userSemester.value,
                            ),
                          if (controller.userSemester.value.isNotEmpty) const SizedBox(height: 16),
                          _buildInfoItem(
                            icon: Icons.assignment_turned_in_rounded,
                            iconColor: AppColors.greenColor,
                            title: "Status",
                            value: "Aktif",
                            valueColor: AppColors.greenColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Tombol Aksi
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () {
                              Get.to(() => const EditProfileView());
                            },
                            icon: Icons.edit_rounded,
                            label: "Edit Profil",
                            backgroundColor: AppColors.primary,
                            textColor: AppColors.surface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            onPressed: _showLogoutDialog,
                            icon: Icons.logout_rounded,
                            label: "Logout",
                            backgroundColor: AppColors.surface,
                            textColor: AppColors.redColor,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
