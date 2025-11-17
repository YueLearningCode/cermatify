import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import '../controllers/order_history_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_room_view.dart';
import 'package:cermatify/app/data/models/mentor_model.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Order',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              onPressed: controller.isLoading.value ? null : () => controller.fetchOrders(),
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'Belum ada order',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Riwayat order akan muncul di sini',
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
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'pending';
    final price = order['price'] as int? ?? 0;
    final createdAt = order['createdAt'] as Timestamp?;
    final mentorName = order['mentorName']?.toString() ?? order['mentorId']?.toString() ?? 'Unknown Mentor';
    final layananName = order['layananName']?.toString() ?? order['layananId']?.toString() ?? 'Unknown Layanan';

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
              color: _getStatusColor(status).withOpacity(0.1),
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
                  decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(20)),
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
                // Chat button for orders in progress
                if (status.toLowerCase() == 'progress' || status.toLowerCase() == 'approved') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final mentorId = order['mentorId']?.toString();
                        if (mentorId != null && mentorId.isNotEmpty) {
                          try {
                            // Fetch mentor data from Firestore
                            final mentorDoc = await FirebaseFirestore.instance.collection('users').doc(mentorId).get();

                            if (!mentorDoc.exists) {
                              Get.snackbar(
                                'Error',
                                'Mentor tidak ditemukan',
                                backgroundColor: AppColors.redColor,
                                colorText: AppColors.surface,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final mentorData = mentorDoc.data()!;

                            // Create Mentor object from Firestore data
                            final mentor = Mentor(
                              id: mentorId,
                              name: mentorData['nama'] ?? mentorData['name'] ?? 'Unknown Mentor',
                              kampus: mentorData['kampus']?.toString() ?? '',
                              jurusan: mentorData['jurusan']?.toString() ?? '',
                              layanan: mentorData['layanan']?.toString() ?? '',
                              image: mentorData['image']?.toString() ?? '',
                              email: mentorData['email']?.toString() ?? '',
                              bio: mentorData['bio']?.toString() ?? '',
                              rating: (mentorData['rating'] as num?)?.toDouble() ?? 0.0,
                              totalSessions: mentorData['totalSessions'] as int? ?? 0,
                            );

                            // Get or create ChatController
                            final ChatController chatController = Get.isRegistered<ChatController>()
                                ? Get.find<ChatController>()
                                : Get.put(ChatController());

                            // Create or get chat room
                            await chatController.createOrGetChatRoom(mentorId: mentorId);

                            // Navigate to chat room with mentor data
                            Get.to(() => ChatRoomView(mentorId: mentorId, mentor: mentor));
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Gagal membuka chat: ${e.toString()}',
                              backgroundColor: AppColors.redColor,
                              colorText: AppColors.surface,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.chat, size: 18),
                      label: Text('Chat Mentor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenColor,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting verification':
        return AppColors.yellow2Color;
      case 'progress':
        return AppColors.greenColor;
      case 'rejected':
        return AppColors.redColor;
      case 'completed':
        return AppColors.primary;
      // Legacy support for old status names
      case 'pending':
        return AppColors.yellow2Color;
      case 'approved':
        return AppColors.greenColor;
      default:
        return AppColors.textSecondary;
    }
  }
}
