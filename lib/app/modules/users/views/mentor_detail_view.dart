import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/users_controller.dart';

class MentorDetailView extends GetView<UsersController> {
  final String mentorId;

  const MentorDetailView({super.key, required this.mentorId});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch $url', backgroundColor: AppColors.redColor, colorText: AppColors.surface);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentor = controller.mentorsList.firstWhereOrNull((m) => m.id == mentorId);

    if (mentor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mentor Detail'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
        ),
        body: const Center(child: Text('Mentor not found')),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.fetchMentorFullData(mentorId),
      builder: (context, snapshot) {
        final mentorData = snapshot.data;
        final linkedin = mentorData?['linkedin']?.toString() ?? '';
        final kampus = mentorData?['kampus']?.toString() ?? '';
        final jurusan = mentorData?['jurusan']?.toString() ?? '';
        final semester = mentorData?['semester']?.toString() ?? '';
        final mentorRole = mentorData?['mentorRole']?.toString() ?? '';
        final layanan = mentorData?['layanan'];
        final layananList = layanan is List ? List<String>.from(layanan) : <String>[];
        final noTelp = mentorData?['noTelp']?.toString() ?? mentorData?['noTelepon']?.toString() ?? '';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Mentor Detail',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          ),
          body: Obx(() {
            final currentMentor = controller.mentorsList.firstWhereOrNull((m) => m.id == mentorId) ?? mentor;
            final verificationStatus = currentMentor.verificationStatus;
            final isVerified = verificationStatus == 'verified';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.surface,
                            backgroundImage: currentMentor.image != null && currentMentor.image!.isNotEmpty
                                ? NetworkImage(currentMentor.image!) as ImageProvider
                                : const AssetImage('assets/images/profile_dummy.jpg'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentMentor.name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentMentor.email,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? AppColors.greenColor.withOpacity(0.1)
                                : AppColors.redColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isVerified ? AppColors.greenColor : AppColors.redColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified ? Icons.check_circle : Icons.pending,
                                size: 16,
                                color: isVerified ? AppColors.greenColor : AppColors.redColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVerified ? 'Verified' : (verificationStatus == 'pending' ? 'Pending' : 'Pending'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isVerified ? AppColors.greenColor : AppColors.redColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Information Section
                  Text(
                    'Information',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Role',
                    value: 'Mentor',
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: currentMentor.email,
                    iconColor: AppColors.primaryLight,
                  ),
                  if (noTelp.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'No. Telepon',
                      value: noTelp,
                      iconColor: AppColors.primaryLight,
                    ),
                  ],
                  if (kampus.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.school_outlined,
                      label: 'Kampus',
                      value: kampus,
                      iconColor: AppColors.primary,
                    ),
                  ],
                  if (jurusan.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.book_outlined,
                      label: 'Jurusan',
                      value: jurusan,
                      iconColor: AppColors.primaryLight,
                    ),
                  ],
                  if (semester.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Semester',
                      value: semester,
                      iconColor: AppColors.primaryLight,
                    ),
                  ],
                  if (mentorRole.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.work_outline,
                      label: 'Mentor Role',
                      value: mentorRole == 'complink'
                          ? 'CompLink'
                          : (mentorRole == 'paperlink' ? 'PaperLink' : mentorRole),
                      iconColor: AppColors.primary,
                    ),
                  ],
                  if (layananList.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.category_outlined,
                      label: 'Layanan',
                      value: layananList.join(', '),
                      iconColor: AppColors.primaryLight,
                    ),
                  ],
                  if (linkedin.isNotEmpty) ...[const SizedBox(height: 12), _buildLinkedInCard(linkedin)],
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    label: 'Verification Status',
                    value: isVerified
                        ? 'Verified Mentor'
                        : (verificationStatus == 'pending' ? 'Pending Verification' : 'Pending Verification'),
                    iconColor: isVerified ? AppColors.greenColor : AppColors.redColor,
                  ),
                  const SizedBox(height: 32),
                  // Activation Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Status',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isVerified
                              ? 'This mentor is verified and can login to the system.'
                              : 'This mentor is pending verification and cannot login yet.',
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isUpdating.value
                                  ? null
                                  : () {
                                      controller.toggleMentorStatus(mentorId, verificationStatus);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isVerified ? AppColors.redColor : AppColors.greenColor,
                                foregroundColor: AppColors.surface,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: controller.isUpdating.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(isVerified ? Icons.close : Icons.check_circle, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          isVerified ? 'Set to Pending' : 'Verify Mentor',
                                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedInCard(String linkedinUrl) {
    // Ensure URL has https:// prefix
    String url = linkedinUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0077B5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.link, color: Color(0xFF0077B5), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LinkedIn',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    linkedinUrl,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0077B5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: Color(0xFF0077B5), size: 18),
          ],
        ),
      ),
    );
  }
}
