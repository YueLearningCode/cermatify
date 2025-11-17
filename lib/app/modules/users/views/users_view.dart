import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/users_controller.dart';
import 'mentor_detail_view.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Users",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Obx(
        () => Column(
          children: [
            // Tab Selector
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
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
            // Content
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.selectedTab.value == 0
                  ? _buildUsersList()
                  : _buildMentorsList(),
            ),
          ],
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
            Icon(icon, size: 20, color: isSelected ? AppColors.surface : AppColors.textSecondary),
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

  Widget _buildUsersList() {
    if (controller.usersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.usersList.length,
      itemBuilder: (context, index) {
        final user = controller.usersList[index];
        return _buildUserCard(user, isMentor: false);
      },
    );
  }

  Widget _buildMentorsList() {
    if (controller.mentorsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No mentors found',
              style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.mentorsList.length,
      itemBuilder: (context, index) {
        final mentor = controller.mentorsList[index];
        return _buildUserCard(mentor, isMentor: true);
      },
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
          boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
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
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isMentor) ...[
                    const SizedBox(height: 6),
                    Obx(() {
                      final mentor = controller.mentorsList.firstWhereOrNull((m) => m.id == user.id);
                      final isActive = mentor?.isActive ?? user.isActive ?? true;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.greenColor.withOpacity(0.1) : AppColors.redColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.greenColor : AppColors.redColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            // Action Button (for mentors only)
            if (isMentor)
              Obx(() {
                final mentor = controller.mentorsList.firstWhereOrNull((m) => m.id == user.id);
                final isActive = mentor?.isActive ?? user.isActive ?? true;
                return Switch(
                  value: isActive,
                  onChanged: controller.isUpdating.value
                      ? null
                      : (value) {
                          controller.toggleMentorStatus(user.id, isActive);
                        },
                  activeColor: AppColors.greenColor,
                  inactiveThumbColor: AppColors.redColor,
                  inactiveTrackColor: AppColors.redColor.withOpacity(0.3),
                );
              }),
          ],
        ),
      ),
    );
  }
}
