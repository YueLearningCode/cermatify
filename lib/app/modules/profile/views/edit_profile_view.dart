import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dropdown values when view is built
    controller.initializeEditProfileValues();

    final nameController = TextEditingController(text: controller.userName.value);
    final emailController = TextEditingController(text: controller.userEmail.value);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.surface, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Email tidak dapat diubah',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.disabledColor,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: controller.selectedKampus.value.isNotEmpty ? AppColors.secondaryColor : Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: controller.selectedKampus.value.isEmpty ? null : controller.selectedKampus.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    prefixIcon: IconTheme(
                      data: IconThemeData(
                        color: controller.selectedKampus.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                      ),
                      child: const Icon(Icons.school_outlined),
                    ),
                    hintText: "Kampus",
                    hintStyle: AppStyles.body1(),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: AppStyles.body1(color: AppColors.black414),
                  items: controller.listKampus.map((String kampus) {
                    return DropdownMenuItem<String>(
                      value: kampus,
                      child: Text(
                        kampus,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppStyles.body1(color: AppColors.black414),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedKampus.value = newValue ?? '';
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: controller.selectedKampus.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: controller.selectedJurusan.value.isNotEmpty ? AppColors.secondaryColor : Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: controller.selectedJurusan.value.isEmpty ? null : controller.selectedJurusan.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    prefixIcon: IconTheme(
                      data: IconThemeData(
                        color: controller.selectedJurusan.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                      ),
                      child: const Icon(Icons.menu_book_outlined),
                    ),
                    hintText: "Jurusan",
                    hintStyle: AppStyles.body1(),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: AppStyles.body1(color: AppColors.black414),
                  items: controller.listJurusan.map((String jurusan) {
                    return DropdownMenuItem<String>(
                      value: jurusan,
                      child: Text(
                        jurusan,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppStyles.body1(color: AppColors.black414),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedJurusan.value = newValue ?? '';
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: controller.selectedJurusan.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: controller.selectedSemester.value.isNotEmpty ? AppColors.secondaryColor : Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: controller.selectedSemester.value.isEmpty ? null : controller.selectedSemester.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    prefixIcon: IconTheme(
                      data: IconThemeData(
                        color: controller.selectedSemester.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                      ),
                      child: const Icon(Icons.calendar_today_outlined),
                    ),
                    hintText: "Semester",
                    hintStyle: AppStyles.body1(),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: AppStyles.body1(color: AppColors.black414),
                  items: controller.listSemester.map((String semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text(semester, style: AppStyles.body1(color: AppColors.black414)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedSemester.value = newValue ?? '';
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: controller.selectedSemester.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                  ),
                ),
              ),
            ),
            // Mentor Role and Layanan (only for mentors)
            Obx(
              () => controller.userRole.value == 'mentor'
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                              color: controller.selectedMentorRole.value.isNotEmpty
                                  ? AppColors.secondaryColor
                                  : Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: controller.selectedMentorRole.value.isEmpty
                                ? null
                                : controller.selectedMentorRole.value,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              prefixIcon: IconTheme(
                                data: IconThemeData(
                                  color: controller.selectedMentorRole.value.isNotEmpty
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                                ),
                                child: const Icon(Icons.work_outline),
                              ),
                              hintText: "Role Mentor",
                              hintStyle: AppStyles.body1(),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: AppStyles.body1(color: AppColors.black414),
                            items: controller.listMentorRole.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(
                                  role == 'complink' ? 'CompLink' : 'PaperLink',
                                  style: AppStyles.body1(color: AppColors.black414),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              controller.selectedMentorRole.value = newValue ?? '';
                            },
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: controller.selectedMentorRole.value.isNotEmpty
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Layanan Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: controller.selectedLayanan.isNotEmpty ? AppColors.secondaryColor : Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.list_alt_rounded,
                                    color: controller.selectedLayanan.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Layanan yang Disediakan",
                                    style: AppStyles.body1(color: AppColors.black414, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...controller.availableLayanan.map((layanan) {
                                return Obx(
                                  () => CheckboxListTile(
                                    value: controller.selectedLayanan.contains(layanan),
                                    onChanged: (value) => controller.toggleLayanan(layanan),
                                    title: Text(
                                      layanan,
                                      style: AppStyles.body2(
                                        color: AppColors.black414,
                                        fontWeight: controller.selectedLayanan.contains(layanan)
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    activeColor: AppColors.primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 30),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final success = await controller.updateProfile(
                            nama: nameController.text.trim(),
                            kampus: controller.selectedKampus.value,
                            jurusan: controller.selectedJurusan.value,
                            semester: controller.selectedSemester.value,
                            mentorRole: controller.userRole.value == 'mentor'
                                ? controller.selectedMentorRole.value
                                : null,
                            layanan: controller.userRole.value == 'mentor' && controller.selectedLayanan.isNotEmpty
                                ? controller.selectedLayanan.toList()
                                : null,
                          );
                          if (success && !controller.isLoading.value) {
                            // Show snackbar before navigating back
                            CustomSnackbar.show(
                              title: 'Sukses',
                              message: 'Edit Profil Berhasil',
                              backgroundColor: AppColors.greenColor,
                              duration: const Duration(seconds: 2),
                            );
                            // Wait a bit for snackbar to show before navigating back
                            await Future.delayed(const Duration(milliseconds: 300));
                            Get.back();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                          ),
                        )
                      : Text('Simpan Perubahan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
