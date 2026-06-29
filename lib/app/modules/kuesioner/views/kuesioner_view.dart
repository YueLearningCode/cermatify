import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/utils/responsive.dart';
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
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              controller.refreshAll();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              // Header dengan informasi
              Container(
                margin: EdgeInsets.all(Responsive.isDesktop(context) ? 24 : 20),
                padding: EdgeInsets.all(
                  Responsive.isDesktop(context) ? 24 : 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_turned_in_rounded,
                        color: AppColors.surface,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kuesioner Tersedia",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.surface,
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.hasRespondenData.value
                                  ? "${controller.kuesionerList.length} kuesioner menunggu"
                                  : "Lengkapi data tambahan untuk melihat kuesioner",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.surface.withOpacity(0.9),
                              ),
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

                  // Show empty state if user hasn't set data tambahan and on Rekomendasi tab
                  if (tab == 0 && !controller.hasRespondenData.value) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Lengkapi Data Tambahan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Untuk melihat kuesioner yang sesuai dengan profil Anda, lengkapi data tambahan terlebih dahulu',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() => const DataUserKuesionerView());
                              },
                              icon: const Icon(Icons.person_add_rounded),
                              label: Text(
                                'Lengkapi Data Tambahan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.surface,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Show empty state if no items
                  if (items.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tab == 1
                                  ? 'Belum ada kuesioner yang Anda buat'
                                  : 'Belum ada kuesioner yang Anda ikuti',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isDesktop(context) ? 24 : 20,
                    ),
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
                                shadowColor: AppColors.primary.withOpacity(
                                  0.15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.surface,
                                        AppColors.background,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        Get.to(
                                          () => KuesionerDetailView(
                                            kuesioner: kuesioner,
                                          ),
                                        );
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
                                                  colors: [
                                                    AppColors.primary,
                                                    AppColors.primaryDark,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withOpacity(0.3),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "Kuesioner ${index + 1}",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .textPrimary,
                                                              ),
                                                        ),
                                                      ),
                                                      // Status Badge
                                                      _buildStatusBadge(
                                                        kuesioner.status,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "Dibuat: ${_formatDate(kuesioner.createdAt)}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Progress bar atau informasi tambahan
                                                  Container(
                                                    height: 4,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
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
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
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
                                    color: AppColors.primaryLight.withOpacity(
                                      0.05,
                                    ),
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
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(hasData ? Icons.edit_rounded : Icons.people_alt_rounded),
          label: Text(
            hasData ? "Edit Data Diri" : "Data Tambahan",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
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
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border,
            ),
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

  Widget _buildStatusBadge(String? status) {
    if (status == null || status.isEmpty) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        backgroundColor = AppColors.success.withOpacity(0.15);
        textColor = AppColors.success;
        statusText = 'Disetujui';
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
      case 'ditolak':
        backgroundColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
        statusText = 'Ditolak';
        icon = Icons.cancel_rounded;
        break;
      case 'waiting verification':
      case 'menunggu verifikasi':
      default:
        backgroundColor = AppColors.yellowColor.withOpacity(0.15);
        textColor = AppColors.yellow2Color;
        statusText = 'Menunggu';
        icon = Icons.pending_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
