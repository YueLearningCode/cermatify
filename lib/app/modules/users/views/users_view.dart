import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/users_controller.dart';
import 'mentor_detail_view.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Users",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.surface,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Obx(
        () => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                    isDesktop ? 24 : 16,
                    16,
                    isDesktop ? 24 : 16,
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          label: 'Users',
                          index: 0,
                          icon: Icons.people_outlined,
                          isSelected: controller.selectedTab.value == 0,
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          label: 'Mentors',
                          index: 1,
                          icon: Icons.school_outlined,
                          isSelected: controller.selectedTab.value == 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.selectedTab.value == 0
                      ? _buildUsersList(context)
                      : _buildMentorsList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    if (controller.usersList.isEmpty) {
      return _buildEmptyState(Icons.people_outlined, 'No users found');
    }

    return _buildResponsiveList(
      context: context,
      itemCount: controller.usersList.length,
      itemBuilder: (index) =>
          _buildUserCard(controller.usersList[index], isMentor: false),
    );
  }

  Widget _buildMentorsList(BuildContext context) {
    if (controller.mentorsList.isEmpty) {
      return _buildEmptyState(Icons.school_outlined, 'No mentors found');
    }

    return _buildResponsiveList(
      context: context,
      itemCount: controller.mentorsList.length,
      itemBuilder: (index) =>
          _buildUserCard(controller.mentorsList[index], isMentor: true),
    );
  }

  Widget _buildResponsiveList({
    required BuildContext context,
    required int itemCount,
    required Widget Function(int index) itemBuilder,
  }) {
    if (!Responsive.isDesktop(context)) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) => itemBuilder(index),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserData user, {required bool isMentor}) {
    return GestureDetector(
      onTap: isMentor
          ? () {
              Get.to(() => MentorDetailView(mentorId: user.id));
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surface,
                backgroundImage: user.image != null && user.image!.isNotEmpty
                    ? NetworkImage(user.image!) as ImageProvider
                    : const AssetImage('assets/images/profile_dummy.jpg'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isMentor) ...[
                    const SizedBox(height: 6),
                    Obx(() {
                      final mentor = controller.mentorsList.firstWhereOrNull(
                        (m) => m.id == user.id,
                      );
                      final verificationStatus =
                          mentor?.verificationStatus ?? user.verificationStatus;
                      final isVerified = verificationStatus == 'verified';
                      final statusText = isVerified ? 'Verified' : 'Pending';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? AppColors.greenColor.withValues(alpha: 0.1)
                              : AppColors.redColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isVerified
                                ? AppColors.greenColor
                                : AppColors.redColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            if (isMentor)
              Obx(() {
                final mentor = controller.mentorsList.firstWhereOrNull(
                  (m) => m.id == user.id,
                );
                final verificationStatus =
                    mentor?.verificationStatus ?? user.verificationStatus;
                final isVerified = verificationStatus == 'verified';
                return Switch(
                  value: isVerified,
                  onChanged: controller.isUpdating.value
                      ? null
                      : (value) {
                          controller.toggleMentorStatus(
                            user.id,
                            verificationStatus,
                          );
                        },
                  activeColor: AppColors.greenColor,
                  inactiveThumbColor: AppColors.redColor,
                  inactiveTrackColor: AppColors.redColor.withValues(alpha: 0.3),
                );
              }),
          ],
        ),
      ),
    );
  }
}
