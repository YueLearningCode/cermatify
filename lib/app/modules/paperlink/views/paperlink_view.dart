import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/paperlink_controller.dart';
import 'list_mentor_view.dart';

class PaperlinkView extends GetView<PaperlinkController> {
  const PaperlinkView({super.key});

  void _searchMentors() async {
    if (controller.isFilterComplete) {
      // Fetch layanan price from Firestore
      int? layananPrice;
      if (controller.selectedLayanan.value.isNotEmpty) {
        try {
          final layananDoc = await FirebaseFirestore.instance
              .collection('layanan')
              .doc(controller.selectedLayanan.value)
              .get();
          if (layananDoc.exists) {
            final data = layananDoc.data();
            layananPrice = data?['harga'] as int?;
          }
        } catch (e) {
          print('Error fetching layanan price: $e');
        }
      }

      Get.to(
        () => ListMentorView(
          kampus: controller.selectedUniversitasName,
          jurusan: controller.selectedJurusanName,
          layanan: controller.selectedLayananName,
          layananId: controller.selectedLayanan.value,
          layananPrice: layananPrice,
          layananType: 'paperlink', // This is paperlink view
        ),
      );
    } else {
      Get.snackbar(
        'Perhatian',
        'Silakan pilih semua opsi terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        messageText: Text(
          'Silakan pilih semua opsi terlebih dahulu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.surface),
        ),
      );
    }
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required List<String> itemIds,
    required String? value,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        dropdownColor: AppColors.surface,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          final id = itemIds[index];
          return DropdownMenuItem(
            value: id,
            child: Container(
              width: double.infinity,
              child: Text(
                name,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
        value: value,
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
        borderRadius: BorderRadius.circular(16),
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Cermat Paper",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.surface, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.description_rounded, color: AppColors.surface, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Temukan Mentor Cermat Paper",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Dapatkan bimbingan untuk penelitian dan publikasi dari mentor berpengalaman",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.surface.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Filter Section
            Text(
              "Filter Pencarian",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              "Pilih kriteria mentor yang Anda butuhkan",
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            // Dropdown Universitas
            Obx(
              () => _buildDropdown(
                label: "Pilih Universitas",
                items: controller.listKampus.map((k) => k['name'] ?? '').toList(),
                itemIds: controller.listKampus.map((k) => k['id'] ?? '').toList(),
                value: controller.selectedUniversitas.value.isEmpty ? null : controller.selectedUniversitas.value,
                onChanged: (val) => controller.selectedUniversitas.value = val ?? '',
                icon: Icons.account_balance_rounded,
              ),
            ),
            const SizedBox(height: 20),
            // Dropdown Jurusan
            Obx(
              () => _buildDropdown(
                label: "Pilih Jurusan",
                items: controller.filteredJurusan.map((j) => j['name'] ?? '').toList(),
                itemIds: controller.filteredJurusan.map((j) => j['id'] ?? '').toList(),
                value: controller.selectedJurusan.value.isEmpty ? null : controller.selectedJurusan.value,
                onChanged: (val) => controller.selectedJurusan.value = val ?? '',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(height: 20),
            // Dropdown Layanan
            Obx(
              () => _buildDropdown(
                label: "Pilih Layanan Riset/Publikasi",
                items: controller.filteredLayanan.map((l) => l['name'] ?? '').toList(),
                itemIds: controller.filteredLayanan.map((l) => l['id'] ?? '').toList(),
                value: controller.selectedLayanan.value.isEmpty ? null : controller.selectedLayanan.value,
                onChanged: (val) => controller.selectedLayanan.value = val ?? '',
                icon: Icons.analytics_rounded,
              ),
            ),
            const SizedBox(height: 32),
            // Search Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _searchMentors,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_rounded, size: 22),
                    const SizedBox(width: 12),
                    Text("Cari Mentor", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
            ),
            // Info Section
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Temukan mentor yang sesuai dengan bidang penelitian dan publikasi Anda",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
