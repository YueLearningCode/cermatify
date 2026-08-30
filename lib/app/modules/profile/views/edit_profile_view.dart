import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final ProfileController controller;
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    nameController = TextEditingController(text: controller.userName.value);
    emailController = TextEditingController(text: controller.userEmail.value);
    controller.initializeEditProfileValues();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final horizontalPadding = viewportWidth < 600 ? 16.0 : 28.0;
          final contentGutter = viewportWidth > 1104
              ? (viewportWidth - 1048) / 2
              : horizontalPadding;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              contentGutter,
              viewportWidth < 600 ? 16 : 28,
              contentGutter,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditProfileHeader(onBack: Get.back),
                const SizedBox(height: 22),
                Text(
                  'Data diri dan akademik',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan informasi berikut tetap lengkap dan sesuai.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: EdgeInsets.all(viewportWidth < 600 ? 16 : 22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EditProfileFieldGrid(
                        children: [
                          TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              label: 'Nama lengkap',
                              hint: 'Masukkan nama lengkap',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          TextFormField(
                            controller: emailController,
                            enabled: false,
                            decoration: _fieldDecoration(
                              label: 'Alamat email',
                              hint: 'Email tidak dapat diubah',
                              icon: Icons.email_outlined,
                              disabled: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Obx(() => _buildAcademicFields()),
                      Obx(
                        () => controller.userRole.value == 'mentor'
                            ? _buildMentorFields()
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAcademicFields() {
    final campusItems = controller.listKampus;
    final majorItems = controller.filteredJurusan;

    return EditProfileFieldGrid(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _validMapValue(
            controller.selectedKampus.value,
            campusItems,
          ),
          isExpanded: true,
          decoration: _fieldDecoration(
            label: 'Kampus',
            hint: 'Pilih kampus',
            icon: Icons.school_outlined,
          ),
          items: campusItems
              .map(
                (campus) => DropdownMenuItem<String>(
                  value: campus['id'],
                  child: Text(
                    campus['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            controller.selectedKampus.value = value ?? '';
            controller.selectedJurusan.value = '';
          },
        ),
        DropdownButtonFormField<String>(
          initialValue: _validMapValue(
            controller.selectedJurusan.value,
            majorItems,
          ),
          isExpanded: true,
          decoration: _fieldDecoration(
            label: 'Program studi',
            hint: controller.selectedKampus.value.isEmpty
                ? 'Pilih kampus terlebih dahulu'
                : 'Pilih program studi',
            icon: Icons.menu_book_outlined,
          ),
          items: majorItems
              .map(
                (major) => DropdownMenuItem<String>(
                  value: major['id'],
                  child: Text(
                    major['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: controller.selectedKampus.value.isEmpty
              ? null
              : (value) => controller.selectedJurusan.value = value ?? '',
        ),
        DropdownButtonFormField<String>(
          initialValue:
              controller.listSemester.contains(
                controller.selectedSemester.value,
              )
              ? controller.selectedSemester.value
              : null,
          isExpanded: true,
          decoration: _fieldDecoration(
            label: 'Semester',
            hint: 'Pilih semester',
            icon: Icons.calendar_today_outlined,
          ),
          items: controller.listSemester
              .map(
                (semester) => DropdownMenuItem<String>(
                  value: semester,
                  child: Text('Semester $semester'),
                ),
              )
              .toList(),
          onChanged: (value) => controller.selectedSemester.value = value ?? '',
        ),
      ],
    );
  }

  Widget _buildMentorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Divider(color: AppColors.border.withValues(alpha: 0.8)),
        const SizedBox(height: 16),
        Text(
          'Informasi mentor',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue:
              controller.listMentorRole.contains(
                controller.selectedMentorRole.value,
              )
              ? controller.selectedMentorRole.value
              : null,
          isExpanded: true,
          decoration: _fieldDecoration(
            label: 'Peran mentor',
            hint: 'Pilih peran mentor',
            icon: Icons.work_outline_rounded,
          ),
          items: controller.listMentorRole
              .map(
                (role) => DropdownMenuItem<String>(
                  value: role,
                  child: Text(
                    role == 'complink' ? 'Cermat Competition' : 'Cermat Paper',
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            controller.selectedMentorRole.value = value ?? '';
            controller.selectedLayanan.clear();
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.checklist_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Layanan yang disediakan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.availableLayanan.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Pilih peran mentor untuk menampilkan layanan.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...controller.availableLayanan.map((service) {
                  final serviceId = service['id'] ?? '';
                  return CheckboxListTile(
                    value: controller.selectedLayanan.contains(serviceId),
                    onChanged: (_) => controller.toggleLayanan(serviceId),
                    title: Text(
                      service['name'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    activeColor: AppColors.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width < 600 ? double.infinity : 260,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: controller.isLoading.value ? null : _saveProfile,
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 19),
            label: Text(
              controller.isLoading.value ? 'Menyimpan...' : 'Simpan perubahan',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.surface,
              elevation: 0,
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final success = await controller.updateProfile(
      nama: nameController.text.trim(),
      kampusId: controller.selectedKampus.value,
      jurusanId: controller.selectedJurusan.value,
      semester: controller.selectedSemester.value,
      mentorRole: controller.userRole.value == 'mentor'
          ? controller.selectedMentorRole.value
          : null,
      layananIds:
          controller.userRole.value == 'mentor' &&
              controller.selectedLayanan.isNotEmpty
          ? controller.selectedLayanan.toList()
          : null,
    );

    if (!success || controller.isLoading.value) return;
    CustomSnackbar.show(
      title: 'Sukses',
      message: 'Edit Profil Berhasil',
      backgroundColor: AppColors.greenColor,
      duration: const Duration(seconds: 2),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    Get.back();
  }

  String? _validMapValue(String value, Iterable<Map<String, String>> items) {
    if (value.isEmpty || !items.any((item) => item['id'] == value)) {
      return null;
    }
    return value;
  }
}

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Container(
          padding: EdgeInsets.all(compact ? 18 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.08),
                AppColors.lightPrimaryColor.withValues(alpha: 0.28),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Material(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(14),
                  child: const SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit profil',
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      compact
                          ? 'Perbarui informasi akun Anda.'
                          : 'Kelola identitas dan informasi akademik akun Anda.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'PENGATURAN AKUN',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class EditProfileFieldGrid extends StatelessWidget {
  const EditProfileFieldGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        const spacing = 14.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  required String hint,
  required IconData icon,
  bool disabled = false,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.border),
  );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: disabled ? AppColors.disabledColor : AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.textSecondary,
    ),
    hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
    enabledBorder: border,
    disabledBorder: border.copyWith(
      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
    ),
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    ),
  );
}
