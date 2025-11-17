import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import '../controllers/admin_orders_controller.dart';

class AdminOrdersView extends GetView<AdminOrdersController> {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pengelolaan Order',
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
                        _buildFilterChip(
                          'In Progress',
                          'progress',
                          controller.selectedStatusFilter.value == 'progress',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip('Rejected', 'rejected', controller.selectedStatusFilter.value == 'rejected'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Completed',
                          'completed',
                          controller.selectedStatusFilter.value == 'completed',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredOrders = controller.filteredOrders;

              if (filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orders will appear here',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'waiting verification';
    final price = order['price'] as int? ?? 0;
    final createdAt = order['createdAt'] as Timestamp?;
    final mentorName = order['mentorName']?.toString() ?? order['mentorId']?.toString() ?? 'Unknown Mentor';
    final layananName = order['layananName']?.toString() ?? order['layananId']?.toString() ?? 'Unknown Layanan';
    final userName = order['userName']?.toString() ?? 'Unknown User';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['id'].toString().substring(0, 8)}',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.getStatusText(status),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.surface),
                  ),
                ),
              ],
            ),
          ),
          // Order details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('User', userName),
                const SizedBox(height: 8),
                _buildDetailRow('Mentor', mentorName),
                const SizedBox(height: 8),
                _buildDetailRow('Layanan', layananName),
                const SizedBox(height: 8),
                _buildDetailRow('Harga', AppFormats.hargaPendek(price)),
                if (createdAt != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Tanggal',
                    '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}',
                  ),
                ],
                if (order['paymentProofUrl'] != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Show payment proof image in full screen
                      Get.dialog(
                        Dialog(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppBar(
                                  title: const Text('Bukti Pembayaran'),
                                  actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back())],
                                ),
                                Expanded(child: Image.network(order['paymentProofUrl'], fit: BoxFit.contain)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Lihat Bukti Pembayaran',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Action buttons for waiting verification status
                if (status.toLowerCase() == 'waiting verification' || status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isUpdating.value
                              ? null
                              : () async {
                                  await controller.updateOrderStatus(order['id'], 'rejected');
                                },
                          icon: const Icon(Icons.close, size: 18),
                          label: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.redColor,
                            side: const BorderSide(color: AppColors.redColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.isUpdating.value
                              ? null
                              : () async {
                                  await controller.updateOrderStatus(order['id'], 'progress');
                                },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenColor,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Action button for progress status (mark as completed)
                if (status.toLowerCase() == 'progress' || status.toLowerCase() == 'approved') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isUpdating.value
                          ? null
                          : () async {
                              await controller.updateOrderStatus(order['id'], 'completed');
                            },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: Text('Mark as Completed', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
