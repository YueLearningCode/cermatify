import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/modules/chat/views/chat_room_view.dart';
import '../controllers/admin_withdraw_controller.dart';

class AdminWithdrawView extends GetView<AdminWithdrawController> {
  const AdminWithdrawView({super.key});

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'id_ID').format(timestamp);
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  String _formatDate(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Withdraw Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.surface, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter
            Row(
              children: [
                Expanded(child: _buildFilterButton('all', 'All')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton('pending', 'Pending')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton('approved', 'Approved')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton('rejected', 'Rejected')),
              ],
            ),
            const SizedBox(height: 24),
            // Withdraw List
            Text(
              'Daftar Withdraw',
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                    )
                  : controller.filteredWithdraws.isEmpty
                  ? _buildEmptyWithdrawState()
                  : _buildWithdrawList(),
            ),
            const SizedBox(height: 32),
            // Chat from Users Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chat dari User',
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Obx(
                  () => IconButton(
                    icon: controller.isLoadingChats.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: controller.isLoadingChats.value ? null : () => controller.refreshChats(),
                    tooltip: 'Refresh',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => controller.isLoadingChats.value
                  ? const Center(
                      child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                    )
                  : controller.mentorChats.isEmpty
                  ? _buildEmptyChatState()
                  : _buildChatList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String status, String label) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.changeStatusFilter(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: controller.selectedStatusFilter.value == status ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.selectedStatusFilter.value == status ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: controller.selectedStatusFilter.value == status ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWithdrawState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Belum ada permintaan withdraw',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawList() {
    return Obx(
      () => Column(
        children: controller.filteredWithdraws.map((withdraw) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            withdraw.mentorName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(withdraw.nominal),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: controller.getStatusColor(withdraw.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.getStatusText(withdraw.status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: controller.getStatusColor(withdraw.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.account_circle_outlined, 'Nama Rekening/E-Wallet', withdraw.namaRekening),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.credit_card_outlined, 'Nomor Rekening/E-Wallet', withdraw.nomorRekening),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today_outlined, 'Tanggal', _formatDate(withdraw.createdAt)),
                if (withdraw.notes != null && withdraw.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.note_outlined, 'Catatan', withdraw.notes!),
                ],
                if (withdraw.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.updateWithdrawStatus(withdraw.id, 'rejected'),
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
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.updateWithdrawStatus(withdraw.id, 'approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenColor,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChatState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Belum ada chat dari user',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Obx(
      () => Column(
        children: controller.mentorChats.take(5).map((chat) {
          final userId = chat.senderId == controller.currentUserId ? chat.receiverId : chat.senderId;
          final userName = controller.getMentorName(userId);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  // Get user data (mentor or regular user)
                  try {
                    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                    final userData = userDoc.data();
                    final userName = userData?['nama'] ?? userData?['name'] ?? 'User';
                    final userImage = userData?['image'] ?? '';
                    final userEmail = userData?['email'] ?? '';

                    // Create or get chat room
                    final ChatController chatController = Get.isRegistered<ChatController>()
                        ? Get.find<ChatController>()
                        : Get.put(ChatController());

                    await chatController.createOrGetChatRoom(mentorId: userId, orderId: chat.orderId);

                    // Navigate to chat room
                    Get.to(
                      () => ChatRoomView(
                        mentorId: userId,
                        mentor: Mentor(
                          id: userId,
                          name: userName,
                          image: userImage,
                          kampus: '',
                          jurusan: '',
                          email: userEmail,
                          layanan: '',
                          bio: '',
                          rating: 0.0,
                          totalSessions: 0,
                        ),
                        orderId: chat.orderId,
                      ),
                    );
                  } catch (e) {
                    CustomSnackbar.show(
                      title: 'Error',
                      message: 'Gagal membuka chat: ${e.toString()}',
                      backgroundColor: AppColors.redColor,
                      isNav: false,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatTime(chat.timestamp),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat.message,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
