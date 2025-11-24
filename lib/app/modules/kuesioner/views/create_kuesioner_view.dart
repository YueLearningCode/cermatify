import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/create_kuesioner_controller.dart';

class CreateKuesionerView extends GetView<CreateKuesionerController> {
  final String orderId;

  const CreateKuesionerView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Cermat Kuesioner",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tentukan Kriteria Responden",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.surface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pilih karakteristik responden yang sesuai dengan kebutuhan penelitian Anda",
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.surface.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Info bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Pilih minimal satu kriteria",
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // White card container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rentang Usia
                  _buildCriteriaField(
                    icon: Icons.calendar_today_rounded,
                    title: "Rentang Usia",
                    subtitle: "Pilih rentang usia responden",
                    value: controller.selectedRentangUsia.value,
                    options: controller.rentangUsiaOptions,
                    onChanged: (value) => controller.selectedRentangUsia.value = value ?? '',
                  ),
                  const SizedBox(height: 20),
                  // Jenis Kelamin
                  _buildCriteriaField(
                    icon: Icons.people_alt_rounded,
                    title: "Jenis Kelamin",
                    subtitle: "Pilih jenis kelamin responden",
                    value: controller.selectedJenisKelamin.value,
                    options: controller.jenisKelaminOptions,
                    onChanged: (value) => controller.selectedJenisKelamin.value = value ?? '',
                  ),
                  const SizedBox(height: 20),
                  // Tingkat Penghasilan
                  _buildCriteriaField(
                    icon: Icons.attach_money_rounded,
                    title: "Tingkat Penghasilan",
                    subtitle: "Pilih tingkat penghasilan responden",
                    value: controller.selectedTingkatPenghasilan.value,
                    options: controller.tingkatPenghasilanOptions,
                    onChanged: (value) => controller.selectedTingkatPenghasilan.value = value ?? '',
                  ),
                  const SizedBox(height: 20),
                  // Pendidikan Terakhir
                  _buildCriteriaField(
                    icon: Icons.school_rounded,
                    title: "Pendidikan Terakhir",
                    subtitle: "Pilih tingkat pendidikan responden",
                    value: controller.selectedPendidikanTerakhir.value,
                    options: controller.pendidikanTerakhirOptions,
                    onChanged: (value) => controller.selectedPendidikanTerakhir.value = value ?? '',
                  ),
                  const SizedBox(height: 24),
                  // Link Input
                  Text(
                    "Link Kuesioner",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Masukkan link kuesioner Anda (Google Forms, dll)",
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.linkController,
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
                      hintText: "https://forms.google.com/...",
                      hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value || !controller.isFormValid
                      ? null
                      : () => controller.createKuesioner(orderId: orderId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                          ),
                        )
                      : Text('Buat Kuesioner', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaField({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            hint: Text(
              'Pilih ${title.toLowerCase()}',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
            ),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
