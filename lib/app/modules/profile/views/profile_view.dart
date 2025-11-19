import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    // Income Dashboard for Mentors
                    Obx(
                      () => controller.userRole.value == 'mentor'
                          ? Column(
                              children: [
                                const SizedBox(height: 30),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withOpacity(0.1),
                                        AppColors.primaryLight.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.account_balance_wallet_rounded,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Saldo',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Obx(
                                                  () => Text(
                                                    _formatPrice(controller.saldo.value),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.greenColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.trending_up_rounded, color: AppColors.greenColor, size: 16),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    'Aktif',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.greenColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Saldo yang tersedia di akun Anda',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    // Orders Section for Mentors
                    Obx(
                      () => controller.userRole.value == 'mentor'
                          ? Column(
                              children: [
                                const SizedBox(height: 30),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Orders in Progress",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Obx(
                                            () => controller.isLoadingOrders.value
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : IconButton(
                                                    icon: const Icon(Icons.refresh_rounded),
                                                    onPressed: () => controller.fetchMentorOrders(),
                                                    tooltip: 'Refresh',
                                                  ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Obx(() {
                                        if (controller.isLoadingOrders.value) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        if (controller.mentorOrders.isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.shopping_bag_outlined,
                                                    size: 60,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Belum ada order',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return Column(
                                          children: controller.mentorOrders
                                              .map((order) => _buildOrderCard(order))
                                              .toList(),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final customerName = order['customerName']?.toString() ?? 'Unknown Customer';
    final layananName = order['layananName']?.toString() ?? 'Unknown Layanan';
    final price = order['price'] as int? ?? 0;
    final createdAt = order['createdAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order #${order['id'].toString().substring(0, 8)}',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'In Progress',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.greenColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderDetailRow('Customer', customerName),
          const SizedBox(height: 8),
          _buildOrderDetailRow('Layanan', layananName),
          const SizedBox(height: 8),
          _buildOrderDetailRow('Harga', _formatPrice(price)),
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            _buildOrderDetailRow(
              'Tanggal',
              '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    } else if (price >= 1000) {
      return 'Rp ${(price / 1000).toStringAsFixed(0)}k';
    }
    return 'Rp $price';
  }
}
