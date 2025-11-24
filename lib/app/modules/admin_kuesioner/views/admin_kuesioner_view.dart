import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/admin_kuesioner_controller.dart';

class AdminKuesionerView extends GetView<AdminKuesionerController> {
  const AdminKuesionerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pengelolaan Kuesioner',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', controller.selectedStatusFilter.value == 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Waiting Verification',
                          'waiting verification',
                          controller.selectedStatusFilter.value == 'waiting verification',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip('Approved', 'approved', controller.selectedStatusFilter.value == 'approved'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Rejected', 'rejected', controller.selectedStatusFilter.value == 'rejected'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Kuesioners List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.kuesioners.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 80, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada kuesioner',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kuesioner akan muncul di sini',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.kuesioners.length,
                itemBuilder: (context, index) {
                  final kuesioner = controller.kuesioners[index];
                  return _buildKuesionerCard(kuesioner);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.changeStatusFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildKuesionerCard(kuesioner) {
    final statusColor = controller.getStatusColor(kuesioner.status);
    final statusText = controller.getStatusText(kuesioner.status);
    final isWaitingVerification = kuesioner.status == 'waiting verification';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.surface),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(kuesioner.createdAt),
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.link_rounded,
                        label: 'Link',
                        value: (kuesioner.link != null && kuesioner.link!.isNotEmpty) ? 'Ada' : 'Tidak Ada',
                        color: (kuesioner.link != null && kuesioner.link!.isNotEmpty)
                            ? AppColors.greenColor
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('kuesioners').doc(kuesioner.id).snapshots(),
                        builder: (context, snapshot) {
                          final List<dynamic> signedBy = (snapshot.data?.data()?['signedBy'] as List<dynamic>?) ?? [];
                          final int jumlahResponden = signedBy.length;
                          return _buildStatItem(
                            icon: Icons.people_outline_rounded,
                            label: 'Responden',
                            value: '$jumlahResponden',
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Link
                if (kuesioner.link != null && kuesioner.link!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          kuesioner.link!,
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Creator Info
                if (kuesioner.userId != null && kuesioner.userId!.isNotEmpty)
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance.collection('users').doc(kuesioner.userId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData = snapshot.data!.data();
                        final userName = userData?['nama'] as String? ?? 'Unknown User';
                        return Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Dibuat oleh: ',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                if (kuesioner.userId != null && kuesioner.userId!.isNotEmpty) const SizedBox(height: 12),
                // Criteria
                if (kuesioner.rentangUsia != null ||
                    kuesioner.jenisKelamin != null ||
                    kuesioner.tingkatPenghasilan != null ||
                    kuesioner.pendidikanTerakhir != null) ...[
                  Text(
                    'Kriteria Responden:',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (kuesioner.rentangUsia != null) _buildCriteriaChip('Usia: ${kuesioner.rentangUsia}'),
                      if (kuesioner.jenisKelamin != null) _buildCriteriaChip('${kuesioner.jenisKelamin}'),
                      if (kuesioner.tingkatPenghasilan != null) _buildCriteriaChip('${kuesioner.tingkatPenghasilan}'),
                      if (kuesioner.pendidikanTerakhir != null) _buildCriteriaChip('${kuesioner.pendidikanTerakhir}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                // // View Details Button
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       Get.to(() => KuesionerDetailView(kuesioner: kuesioner));
                //     },
                //     icon: const Icon(Icons.visibility_outlined, size: 18),
                //     label: Text('Lihat Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: AppColors.primary,
                //       side: const BorderSide(color: AppColors.primary),
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 12),
                // Action Buttons
                if (isWaitingVerification)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isUpdating.value
                              ? null
                              : () => controller.updateKuesionerStatus(kuesioner.id, 'rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.redColor,
                            side: const BorderSide(color: AppColors.redColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.isUpdating.value
                              ? null
                              : () => controller.updateKuesionerStatus(kuesioner.id, 'approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenColor,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isUpdating.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                                  ),
                                )
                              : Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary)),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
