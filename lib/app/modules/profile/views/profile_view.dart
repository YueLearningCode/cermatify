import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/modules/dashboard/controllers/dashboard_controller.dart';
import '../controllers/profile_controller.dart';
import 'withdraw_dialog_view.dart';
import '../../../routes/app_pages.dart';

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
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
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
            label: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(color: textColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          constraints: const BoxConstraints(maxWidth: 480),
          scrollable: true,
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pilih Sumber Gambar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primary),
                  title: Text(
                    'Kamera',
                    style: GoogleFonts.poppins(color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickAndUploadImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(
                  'Galeri',
                  style: GoogleFonts.poppins(color: AppColors.textPrimary),
                ),
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 480),
        scrollable: true,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Konfirmasi Logout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
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
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoading.value &&
          controller.userRole.value != 'admin' &&
          controller.userRole.value != 'mentor') {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: _buildMemberProfile(context),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.userRole.value == 'admin'
              ? _buildAdminProfile(context)
              : controller.userRole.value == 'mentor'
              ? _buildMentorProfile(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ResponsiveContent(
                    maxWidth: 900,
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
                              colors: [
                                AppColors.primary.withValues(alpha: 0.8),
                                AppColors.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
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
                                        colors: [
                                          AppColors.surface.withValues(
                                            alpha: 0.8,
                                          ),
                                          AppColors.primaryLight,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppColors.surface,
                                      backgroundImage:
                                          controller.userImage.value.isNotEmpty
                                          ? NetworkImage(
                                                  controller.userImage.value,
                                                )
                                                as ImageProvider
                                          : const AssetImage(
                                              'assets/images/profile_dummy.jpg',
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Obx(
                                      () => IconButton(
                                        tooltip: 'Ubah foto profil',
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : () => _showImageSourceDialog(
                                                context,
                                              ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.surface,
                                          disabledBackgroundColor:
                                              AppColors.primary,
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        icon: controller.isLoading.value
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.surface),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.camera_alt_rounded,
                                                color: AppColors.surface,
                                                size: 18,
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
                                  color: AppColors.surface.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (controller.userKampus.value.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(
                                      alpha: 0.2,
                                    ),
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
                                color: AppColors.border.withValues(alpha: 0.5),
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
                              if (controller.userJurusan.value.isNotEmpty &&
                                  controller.userSemester.value.isNotEmpty)
                                const SizedBox(height: 16),
                              if (controller.userSemester.value.isNotEmpty)
                                _buildInfoItem(
                                  icon: Icons.library_books_rounded,
                                  iconColor: AppColors.primaryLight,
                                  title: "Semester",
                                  value: controller.userSemester.value,
                                ),
                              if (controller.userSemester.value.isNotEmpty)
                                const SizedBox(height: 16),
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
                                  Get.toNamed(Routes.EDIT_PROFILE);
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
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _buildActionButton(
                            onPressed: () =>
                                Get.toNamed(Routes.CHANGE_PASSWORD),
                            icon: Icons.lock_reset_rounded,
                            label: "Ubah Kata Sandi",
                            backgroundColor: AppColors.surface,
                            textColor: AppColors.primary,
                            isOutlined: true,
                          ),
                        ),
                        // Saldo for mentor and customer only
                        Obx(
                          () => controller.userRole.value != 'admin'
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
                                            AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            AppColors.primaryLight.withValues(
                                              alpha: 0.1,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .account_balance_wallet_rounded,
                                                  color: AppColors.primary,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Saldo',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .textSecondary,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Obx(
                                                      () => Text(
                                                        _formatPrice(
                                                          controller
                                                              .saldo
                                                              .value,
                                                        ),
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.greenColor
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.trending_up_rounded,
                                                      color:
                                                          AppColors.greenColor,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        'Aktif',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .greenColor,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline_rounded,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Saldo yang tersedia di akun Anda',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Withdraw and Chat Admin Buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    Get.dialog(
                                                      WithdrawDialogView(
                                                        currentSaldo: controller
                                                            .saldo
                                                            .value,
                                                      ),
                                                      barrierDismissible: false,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .account_balance_wallet_rounded,
                                                    size: 18,
                                                  ),
                                                  label: Text(
                                                    'Withdraw',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    foregroundColor:
                                                        AppColors.surface,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () async {
                                                    try {
                                                      final adminQuery =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                'users',
                                                              )
                                                              .where(
                                                                'role',
                                                                isEqualTo:
                                                                    'admin',
                                                              )
                                                              .limit(1)
                                                              .get();

                                                      if (adminQuery
                                                          .docs
                                                          .isEmpty) {
                                                        CustomSnackbar.show(
                                                          title: 'Error',
                                                          message:
                                                              'Admin tidak ditemukan',
                                                          backgroundColor:
                                                              AppColors
                                                                  .redColor,
                                                          isNav: false,
                                                        );
                                                        return;
                                                      }

                                                      final adminId = adminQuery
                                                          .docs
                                                          .first
                                                          .id;
                                                      final adminData =
                                                          adminQuery.docs.first
                                                              .data();
                                                      final adminName =
                                                          adminData['nama'] ??
                                                          'Admin';

                                                      final ChatController
                                                      chatController =
                                                          Get.isRegistered<
                                                            ChatController
                                                          >()
                                                          ? Get.find<
                                                              ChatController
                                                            >()
                                                          : Get.put(
                                                              ChatController(),
                                                            );

                                                      await chatController
                                                          .createOrGetChatRoom(
                                                            mentorId: adminId,
                                                          );

                                                      Get.toNamed(
                                                        Routes.chatRoom(
                                                          adminId,
                                                        ),
                                                        arguments:
                                                            <String, dynamic>{
                                                              'partnerName':
                                                                  adminName,
                                                            },
                                                      );
                                                    } catch (e) {
                                                      CustomSnackbar.show(
                                                        title: 'Error',
                                                        message:
                                                            'Gagal membuka chat admin: ${e.toString()}',
                                                        backgroundColor:
                                                            AppColors.redColor,
                                                        isNav: false,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .chat_bubble_outline_rounded,
                                                    size: 18,
                                                  ),
                                                  label: Text(
                                                    'Chat Admin',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.primary,
                                                    side: const BorderSide(
                                                      color: AppColors.primary,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                            color: AppColors.border.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                () =>
                                                    controller
                                                        .isLoadingOrders
                                                        .value
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : IconButton(
                                                        icon: const Icon(
                                                          Icons.refresh_rounded,
                                                        ),
                                                        onPressed: () => controller
                                                            .fetchMentorOrders(),
                                                        tooltip: 'Refresh',
                                                      ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Obx(() {
                                            if (controller
                                                .isLoadingOrders
                                                .value) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            }
                                            if (controller
                                                .mentorOrders
                                                .isEmpty) {
                                              return Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .shopping_bag_outlined,
                                                        size: 60,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Text(
                                                        'Belum ada order',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            return Column(
                                              children: controller.mentorOrders
                                                  .map(
                                                    (order) =>
                                                        _buildOrderCard(order),
                                                  )
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
        ),
      );
    });
  }

  Widget _buildMemberProfile(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        final compact = viewport.maxWidth < 600;
        final padding = compact ? 16.0 : 28.0;
        final gutter = viewport.maxWidth > 1156
            ? (viewport.maxWidth - 1156) / 2
            : 0.0;
        return RefreshIndicator(
          onRefresh: controller.fetchUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              padding + gutter,
              compact ? 18 : 28,
              padding + gutter,
              compact ? 112 : 44,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminProfileHero(
                  name: controller.userName.value,
                  email: controller.userEmail.value,
                  imageUrl: controller.userImage.value,
                  campus: controller.userKampus.value,
                  profileLabel: 'PROFIL PENGGUNA',
                  statusLabel: 'Akun pengguna aktif',
                  onChangePhoto: () => _showImageSourceDialog(context),
                ),
                const SizedBox(height: 26),
                const _ProfileSectionHeading(
                  title: 'Informasi akademik',
                  subtitle:
                      'Data utama yang digunakan dalam layanan Cermatify.',
                ),
                const SizedBox(height: 14),
                AdminProfileInfoGrid(
                  items: [
                    AdminProfileInfo(
                      icon: Icons.account_balance_outlined,
                      label: 'Kampus',
                      value: controller.userKampus.value.isEmpty
                          ? 'Belum dilengkapi'
                          : controller.userKampus.value,
                      color: AppColors.primaryColor,
                    ),
                    AdminProfileInfo(
                      icon: Icons.menu_book_outlined,
                      label: 'Program studi',
                      value: controller.userJurusan.value.isEmpty
                          ? 'Belum dilengkapi'
                          : controller.userJurusan.value,
                      color: AppColors.primaryColor,
                    ),
                    AdminProfileInfo(
                      icon: Icons.calendar_month_outlined,
                      label: 'Semester',
                      value: controller.userSemester.value.isEmpty
                          ? 'Belum dilengkapi'
                          : controller.userSemester.value,
                      color: AppColors.primaryLight,
                    ),
                    const AdminProfileInfo(
                      icon: Icons.verified_user_outlined,
                      label: 'Status akun',
                      value: 'Aktif',
                      color: AppColors.greenColor,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _MemberWalletCard(
                  balance: controller.saldo.value,
                  onWithdraw: () => Get.dialog(
                    WithdrawDialogView(currentSaldo: controller.saldo.value),
                    barrierDismissible: false,
                  ),
                  onChat: _openMemberChat,
                ),
                const SizedBox(height: 26),
                const _ProfileSectionHeading(
                  title: 'Pengaturan akun',
                  subtitle: 'Kelola identitas, keamanan, dan sesi akun Anda.',
                ),
                const SizedBox(height: 14),
                AdminProfileActions(
                  onEdit: () => Get.toNamed(Routes.EDIT_PROFILE),
                  onChangePassword: () => Get.toNamed(Routes.CHANGE_PASSWORD),
                  onLogout: _showLogoutDialog,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMemberChat() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeTab(1);
      return;
    }
    Get.offAllNamed(Routes.DASHBOARD, arguments: const {'initialTab': 1});
  }

  Widget _buildMentorProfile(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        final padding = viewport.maxWidth < 600 ? 16.0 : 28.0;
        final gutter = viewport.maxWidth > 1256
            ? (viewport.maxWidth - 1200) / 2
            : padding;
        return RefreshIndicator(
          onRefresh: controller.fetchUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminProfileHero(
                  name: controller.userName.value,
                  email: controller.userEmail.value,
                  imageUrl: controller.userImage.value,
                  campus: controller.userKampus.value,
                  profileLabel: 'MENTOR PROFILE',
                  statusLabel: 'Mentor terverifikasi',
                  onChangePhoto: () => _showImageSourceDialog(context),
                ),
                const SizedBox(height: 26),
                const _ProfileSectionHeading(
                  title: 'Informasi mentor',
                  subtitle:
                      'Identitas akademik dan layanan pendampingan yang aktif.',
                ),
                const SizedBox(height: 14),
                AdminProfileInfoGrid(
                  items: [
                    AdminProfileInfo(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Spesialisasi',
                      value: _mentorRoleLabel(controller.userMentorRole.value),
                      color: AppColors.primary,
                    ),
                    AdminProfileInfo(
                      icon: Icons.menu_book_outlined,
                      label: 'Program studi',
                      value: controller.userJurusan.value.isEmpty
                          ? 'Belum dilengkapi'
                          : controller.userJurusan.value,
                      color: AppColors.primary,
                    ),
                    AdminProfileInfo(
                      icon: Icons.calendar_month_outlined,
                      label: 'Semester',
                      value: controller.userSemester.value.isEmpty
                          ? 'Belum dilengkapi'
                          : controller.userSemester.value,
                      color: AppColors.primaryLight,
                    ),
                    AdminProfileInfo(
                      icon: Icons.category_outlined,
                      label: 'Layanan aktif',
                      value: '${controller.userLayanan.length} layanan',
                      color: AppColors.greenColor,
                    ),
                    AdminProfileInfo(
                      icon: Icons.work_outline_rounded,
                      label: 'Order berjalan',
                      value: '${controller.mentorOrders.length} order',
                      color: AppColors.greenColor,
                    ),
                    const AdminProfileInfo(
                      icon: Icons.verified_user_outlined,
                      label: 'Status akun',
                      value: 'Aktif dan terverifikasi',
                      color: AppColors.greenColor,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                MentorBalanceCard(
                  balance: controller.saldo.value,
                  onWithdraw: () => Get.dialog(
                    WithdrawDialogView(currentSaldo: controller.saldo.value),
                    barrierDismissible: false,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: _ProfileSectionHeading(
                        title: 'Order aktif',
                        subtitle:
                            'Daftar pendampingan yang sedang berlangsung.',
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Muat ulang order',
                      onPressed: controller.isLoadingOrders.value
                          ? null
                          : controller.fetchMentorOrders,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (controller.isLoadingOrders.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (controller.mentorOrders.isEmpty)
                  const MentorProfileEmptyOrders()
                else
                  MentorProfileOrderGrid(orders: controller.mentorOrders),
                const SizedBox(height: 26),
                const _ProfileSectionHeading(
                  title: 'Pengaturan akun',
                  subtitle: 'Kelola identitas, keamanan, dan sesi akun Anda.',
                ),
                const SizedBox(height: 14),
                AdminProfileActions(
                  onEdit: () => Get.toNamed(Routes.EDIT_PROFILE),
                  onChangePassword: () => Get.toNamed(Routes.CHANGE_PASSWORD),
                  onLogout: _showLogoutDialog,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _mentorRoleLabel(String value) {
    switch (value.toLowerCase()) {
      case 'complink':
        return 'Cermat Competition';
      case 'paperlink':
        return 'Cermat Paper';
      default:
        return 'Mentor Cermatify';
    }
  }

  Widget _buildAdminProfile(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        final basePadding = viewport.maxWidth < 600 ? 16.0 : 28.0;
        final gutter = viewport.maxWidth > 1156
            ? (viewport.maxWidth - 1156) / 2
            : 0.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            basePadding + gutter,
            24,
            basePadding + gutter,
            viewport.maxWidth < 600 ? 112 : 44,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminProfileHero(
                name: controller.userName.value,
                email: controller.userEmail.value,
                imageUrl: controller.userImage.value,
                campus: controller.userKampus.value,
                onChangePhoto: () => _showImageSourceDialog(context),
              ),
              const SizedBox(height: 28),
              const _ProfileSectionHeading(
                title: 'Informasi profil',
                subtitle: 'Data akademik dan status akun administrator.',
              ),
              const SizedBox(height: 14),
              AdminProfileInfoGrid(
                items: [
                  AdminProfileInfo(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Peran akun',
                    value: 'Administrator',
                    color: AppColors.primaryColor,
                  ),
                  AdminProfileInfo(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: controller.userEmail.value,
                    color: AppColors.primaryColor,
                  ),
                  if (controller.userKampus.value.isNotEmpty)
                    AdminProfileInfo(
                      icon: Icons.account_balance_outlined,
                      label: 'Kampus',
                      value: controller.userKampus.value,
                      color: AppColors.primaryColor,
                    ),
                  if (controller.userJurusan.value.isNotEmpty)
                    AdminProfileInfo(
                      icon: Icons.menu_book_outlined,
                      label: 'Program studi',
                      value: controller.userJurusan.value,
                      color: AppColors.primaryColor,
                    ),
                  if (controller.userSemester.value.isNotEmpty)
                    AdminProfileInfo(
                      icon: Icons.calendar_month_outlined,
                      label: 'Semester',
                      value: controller.userSemester.value,
                      color: AppColors.primaryLight,
                    ),
                  const AdminProfileInfo(
                    icon: Icons.verified_user_outlined,
                    label: 'Status akun',
                    value: 'Aktif',
                    color: AppColors.greenColor,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _ProfileSectionHeading(
                title: 'Pengaturan akun',
                subtitle: 'Kelola identitas, keamanan, dan sesi akun Anda.',
              ),
              const SizedBox(height: 14),
              AdminProfileActions(
                onEdit: () => Get.toNamed(Routes.EDIT_PROFILE),
                onChangePassword: () => Get.toNamed(Routes.CHANGE_PASSWORD),
                onLogout: _showLogoutDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final customerName =
        order['customerName']?.toString() ?? 'Unknown Customer';
    final layananName = order['layananName']?.toString() ?? 'Unknown Layanan';
    final price = order['price'] as int? ?? 0;
    final createdAt = order['createdAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
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
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'In Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenColor,
                  ),
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
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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

class _MemberWalletCard extends StatelessWidget {
  const _MemberWalletCard({
    required this.balance,
    required this.onWithdraw,
    required this.onChat,
  });

  final int balance;
  final VoidCallback onWithdraw;
  final VoidCallback onChat;

  String get formattedBalance =>
      'Rp ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: .08),
            AppColors.lightPrimaryColor.withValues(alpha: .2),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: .18),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final balanceInfo = Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo akun',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formattedBalance,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _walletButton(
                      onWithdraw,
                      Icons.payments_outlined,
                      'Ajukan withdraw',
                      true,
                    ),
                    const SizedBox(height: 10),
                    _walletButton(
                      onChat,
                      Icons.support_agent_outlined,
                      'Chat admin',
                      false,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _walletButton(
                        onWithdraw,
                        Icons.payments_outlined,
                        'Ajukan withdraw',
                        true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _walletButton(
                        onChat,
                        Icons.support_agent_outlined,
                        'Chat admin',
                        false,
                      ),
                    ),
                  ],
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              balanceInfo,
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  'Saldo akan diperbarui otomatis setelah transaksi diverifikasi.',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _walletButton(
    VoidCallback onPressed,
    IconData icon,
    String label,
    bool primary,
  ) {
    if (primary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
    );
  }
}

class MentorBalanceCard extends StatelessWidget {
  const MentorBalanceCard({
    super.key,
    required this.balance,
    required this.onWithdraw,
  });

  final int balance;
  final VoidCallback onWithdraw;

  String get formattedBalance =>
      'Rp ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryColor.withValues(alpha: 0.86),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final information = Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo tersedia',
                      style: GoogleFonts.poppins(
                        color: AppColors.surface.withValues(alpha: 0.76),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      formattedBalance,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.surface,
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onWithdraw,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primaryDark,
              minimumSize: Size(compact ? double.infinity : 160, 46),
            ),
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: const Text('Ajukan withdraw'),
          );
          if (compact) {
            return Column(
              children: [information, const SizedBox(height: 18), action],
            );
          }
          return Row(
            children: [
              Expanded(child: information),
              const SizedBox(width: 20),
              action,
            ],
          );
        },
      ),
    );
  }
}

class MentorProfileOrderGrid extends StatelessWidget {
  const MentorProfileOrderGrid({super.key, required this.orders});
  final List<Map<String, dynamic>> orders;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 2 : 1;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (orders.length / columns).ceil(),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, rowIndex) {
            final first = rowIndex * columns;
            if (columns == 1) {
              return MentorProfileOrderCard(order: orders[first]);
            }
            final second = first + 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: MentorProfileOrderCard(order: orders[first])),
                const SizedBox(width: 12),
                Expanded(
                  child: second < orders.length
                      ? MentorProfileOrderCard(order: orders[second])
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class MentorProfileOrderCard extends StatelessWidget {
  const MentorProfileOrderCard({super.key, required this.order});
  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final id = order['id']?.toString() ?? '';
    final shortId = id.length > 8 ? id.substring(0, 8) : id;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.greenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.greenColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Order #$shortId',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Berjalan',
                  style: GoogleFonts.poppins(
                    color: AppColors.greenColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MentorOrderInfo(
            icon: Icons.person_outline_rounded,
            value: order['customerName']?.toString() ?? 'Pengguna',
          ),
          const SizedBox(height: 8),
          _MentorOrderInfo(
            icon: Icons.category_outlined,
            value: order['layananName']?.toString() ?? 'Layanan pendampingan',
          ),
        ],
      ),
    );
  }
}

class _MentorOrderInfo extends StatelessWidget {
  const _MentorOrderInfo({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class MentorProfileEmptyOrders extends StatelessWidget {
  const MentorProfileEmptyOrders({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.work_history_outlined,
            color: AppColors.textLight,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada order aktif',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Pendampingan baru akan tampil pada bagian ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminProfileHero extends StatelessWidget {
  const AdminProfileHero({
    super.key,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.campus,
    required this.onChangePhoto,
    this.profileLabel = 'ADMIN PROFILE',
    this.statusLabel = 'Administrator aktif',
  });

  final String name;
  final String email;
  final String imageUrl;
  final String campus;
  final VoidCallback onChangePhoto;
  final String profileLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.checkoutButtonColor,
            AppColors.lightPrimaryColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final avatar = Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: compact ? 82 : 94,
                height: compact ? 82 : 94,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.checkoutButtonColor,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/images/profile_dummy.jpg')
                            as ImageProvider,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onChangePhoto,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
          final identity = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  profileLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: compact ? 23 : 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                email,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (campus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 15,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        campus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
          final status = _ProfileStatusBadge(label: statusLabel);

          if (compact) {
            return Column(
              children: [
                avatar,
                const SizedBox(height: 18),
                identity,
                const SizedBox(height: 16),
                status,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 20),
              Expanded(child: identity),
              const SizedBox(width: 20),
              status,
            ],
          );
        },
      ),
    );
  }
}

class AdminProfileInfo {
  const AdminProfileInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class AdminProfileInfoGrid extends StatelessWidget {
  const AdminProfileInfoGrid({super.key, required this.items});

  final List<AdminProfileInfo> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 92,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.label == 'Status akun'
                                ? AppColors.greenColor
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AdminProfileActions extends StatelessWidget {
  const AdminProfileActions({
    super.key,
    required this.onEdit,
    required this.onChangePassword,
    required this.onLogout,
  });

  final VoidCallback onEdit;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final buttons = [
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit profil'),
          ),
          OutlinedButton.icon(
            onPressed: onChangePassword,
            icon: const Icon(Icons.lock_reset_rounded, size: 18),
            label: const Text('Ubah kata sandi'),
          ),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.redColor,
              side: const BorderSide(color: AppColors.redColor),
            ),
          ),
        ];

        Widget styled(Widget button) => SizedBox(
          height: 48,
          width: compact ? double.infinity : null,
          child: button,
        );

        if (compact) {
          return Column(
            children: [
              for (var index = 0; index < buttons.length; index++) ...[
                styled(buttons[index]),
                if (index < buttons.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < buttons.length; index++) ...[
              Expanded(child: styled(buttons[index])),
              if (index < buttons.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ProfileSectionHeading extends StatelessWidget {
  const _ProfileSectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatusBadge extends StatelessWidget {
  const _ProfileStatusBadge({this.label = 'Administrator aktif'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.greenColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 16,
            color: AppColors.greenColor,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.greenColor,
            ),
          ),
        ],
      ),
    );
  }
}
