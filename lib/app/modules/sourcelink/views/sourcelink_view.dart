import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/dummy_sourcelink.dart';
import '../controllers/sourcelink_controller.dart';
import 'sourcelink_submit_view.dart';

class SourcelinkView extends GetView<SourcelinkController> {
  const SourcelinkView({super.key});

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
                      'Cermat Kuesioner',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tentukan Kriteria Responden',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih karakteristik responden yang sesuai dengan kebutuhan penelitian Anda',
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
                        // Badge informasi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Pilih minimal satu kriteria',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => _buildFormSection(
                            icon: Icons.calendar_today,
                            title: "Rentang Usia",
                            subtitle: "Pilih rentang usia responden",
                            child: _buildDropdown(
                              value: controller.selectedUsia.value,
                              items: dummyRentangUsia,
                              onChanged: (value) => controller.selectedUsia.value = value ?? dummyRentangUsia.first,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => _buildFormSection(
                            icon: Icons.person_outline,
                            title: "Jenis Kelamin",
                            subtitle: "Pilih jenis kelamin responden",
                            child: _buildDropdown(
                              value: controller.selectedKelamin.value,
                              items: dummyJenisKelamin,
                              onChanged: (value) => controller.selectedKelamin.value = value ?? dummyJenisKelamin.first,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => _buildFormSection(
                            icon: Icons.attach_money,
                            title: "Tingkat Penghasilan",
                            subtitle: "Pilih tingkat penghasilan responden",
                            child: _buildDropdown(
                              value: controller.selectedPenghasilan.value,
                              items: dummyTingkatPenghasilan,
                              onChanged: (value) =>
                                  controller.selectedPenghasilan.value = value ?? dummyTingkatPenghasilan.first,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => _buildFormSection(
                            icon: Icons.school,
                            title: "Pendidikan Terakhir",
                            subtitle: "Pilih tingkat pendidikan responden",
                            child: _buildDropdown(
                              value: controller.selectedPendidikan.value,
                              items: dummyPendidikanTerakhir,
                              onChanged: (value) =>
                                  controller.selectedPendidikan.value = value ?? dummyPendidikanTerakhir.first,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildFormSection(
                          icon: Icons.tune,
                          title: "Kriteria Lainnya",
                          subtitle: "Tambahkan kriteria khusus (opsional)",
                          child: Column(
                            children: [
                              TextField(
                                controller: controller.kriteriaController,
                                maxLines: 3,
                                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText:
                                      "Contoh: Mahasiswa aktif, berdomisili di Jabodetabek, pengguna e-commerce...",
                                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13),
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
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kriteria akan membantu menemukan responden yang lebih spesifik',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Button yang diperkecil
                        _buildContinueButton(),
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

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16),
                  ),
                  Text(subtitle, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
      style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
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
        onPressed: () {
          Get.to(() => const SourcelinkSubmitView());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Lanjutkan",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 16),
          ],
        ),
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
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih kriteria yang spesifik untuk mendapatkan responden yang lebih relevan dengan penelitian Anda',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
