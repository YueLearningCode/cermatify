import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/complink_controller.dart';
import '../../paperlink/views/list_mentor_view.dart';

class ComplinkView extends GetView<ComplinkController> {
  const ComplinkView({super.key});

  void _searchMentors() async {
    if (controller.isFilterComplete) {
      // Fetch layanan price from Firestore
      int? layananPrice;
      if (controller.selectedCabang.value.isNotEmpty) {
        try {
          final layananDoc = await FirebaseFirestore.instance
              .collection('layanan')
              .doc(controller.selectedCabang.value)
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
          layanan: controller.selectedCabangName,
          layananId: controller.selectedCabang.value,
          layananPrice: layananPrice,
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
      constraints: const BoxConstraints(minWidth: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        dropdownColor: AppColors.surface,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          final id = itemIds[index];
          return DropdownMenuItem(
            value: id,
            child: Text(
              name,
              style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        value: value,
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "CompLink",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.surface, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth > 600 ? 24 : 16, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight, maxWidth: constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.school_rounded, color: AppColors.surface, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cari Mentor Terbaikmu",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.surface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Dapatkan bimbingan untuk kompetisi dan beasiswa dari mentor terbaik",
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
                    const SizedBox(height: 24),
                    // Filter Section - only one dropdown
                    Text(
                      "Cabang Lomba Akademik",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pilih cabang lomba akademik sesuai kebutuhanmu",
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => _buildDropdown(
                        label: "Cabang Lomba Akademik",
                        items: controller.filteredLayanan.map((l) => l['name'] ?? '').toList(),
                        itemIds: controller.filteredLayanan.map((l) => l['id'] ?? '').toList(),
                        value: controller.selectedCabang.value.isEmpty ? null : controller.selectedCabang.value,
                        onChanged: (val) => controller.selectedCabang.value = val ?? '',
                        icon: Icons.emoji_events_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Pastikan semua filter telah dipilih untuk hasil pencarian yang optimal",
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
                    // Spacer for bottom padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
