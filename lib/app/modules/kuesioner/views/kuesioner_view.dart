import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/kuesioner_controller.dart';
import 'kuesioner_detail_view.dart';
import 'data_user_kuesioner_view.dart';

class KuesionerView extends GetView<KuesionerController> {
  const KuesionerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Daftar Kuesioner",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Column(
        children: [
          // Header dengan informasi
          Container(
            margin: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.assignment_turned_in_rounded, color: AppColors.surface, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kuesioner Tersedia",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.surface),
                      ),
                      Obx(
                        () => Text(
                          "${controller.kuesionerList.length} kuesioner menunggu",
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.surface.withOpacity(0.9)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Segmented control for history
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Obx(
              () => Row(
                children: [
                  _buildSegment("Rekomendasi", 0),
                  const SizedBox(width: 8),
                  _buildSegment("Dibuat Saya", 1),
                  const SizedBox(width: 8),
                  _buildSegment("Saya Ikuti", 2),
                ],
              ),
            ),
          ),
          // List Kuesioner
          Expanded(
            child: Obx(() {
              final tab = controller.selectedTab.value;
              final items = tab == 0
                  ? controller.kuesionerList
                  : tab == 1
                  ? controller.createdByMeList
                  : controller.signedByMeList;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final kuesioner = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Stack(
                        children: [
                          // Main Card
                          Card(
                            elevation: 6,
                            shadowColor: AppColors.primary.withOpacity(0.15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.surface, AppColors.background],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Get.to(() => KuesionerDetailView(kuesioner: kuesioner));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        // Number Badge
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [AppColors.primary, AppColors.primaryDark],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                color: AppColors.surface,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Kuesioner ${index + 1}",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Dibuat: ${_formatDate(kuesioner.createdAt)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Progress bar atau informasi tambahan
                                              Container(
                                                height: 4,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Arrow dengan container yang lebih menarik
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: AppColors.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Decorative element
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      // Floating Action Button untuk Data Tambahan
      floatingActionButton: Obx(() {
        final bool hasData = controller.hasRespondenData.value;
        final Map<String, dynamic> data = controller.respondenData;
        return FloatingActionButton.extended(
          onPressed: () {
            Get.to(
              () => DataUserKuesionerView(
                initialUsia: data['rentangUsia'] as String?,
                initialKelamin: data['jenisKelamin'] as String?,
                initialPenghasilan: data['tingkatPenghasilan'] as String?,
                initialPendidikan: data['pendidikanTerakhir'] as String?,
              ),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.people_alt_rounded),
          label: Text(
            hasData ? "Edit Data" : "Data Tambahan",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        );
      }),
      // Posisi FAB agar tidak menutupi konten
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSegment(String label, int index) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
