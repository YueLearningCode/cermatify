import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/models/chat_model.dart';
import '../controllers/chat_controller.dart';
import 'chat_room_view.dart';
import '../../home/controllers/home_controller.dart';

class ChatListView extends GetView<ChatController> {
  final bool embed; // if true, builds full Scaffold; if false, builds only list content (no AppBar/Scaffold)
  const ChatListView({super.key, this.embed = true});

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

  Widget _buildOnlineIndicator(bool isOnline) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.greenColor : AppColors.textLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 2),
        ),
      ),
    );
  }

  Widget _buildUnreadIndicator(int unreadCount) {
    if (unreadCount == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: const TextStyle(color: AppColors.surface, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMentorAvatar(String partnerId, bool isOnline) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: isOnline
                ? LinearGradient(colors: [AppColors.greenColor, AppColors.primaryLight])
                : LinearGradient(colors: [AppColors.textLight, AppColors.border]),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              partnerId.isNotEmpty ? partnerId[0].toUpperCase() : 'M',
              style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        _buildOnlineIndicator(isOnline),
      ],
    );
  }

  Widget _buildChatItem(ChatMessage chat, bool isOnline, int unreadCount) {
    final partnerId = chat.senderId == controller.currentUserId ? chat.receiverId : chat.senderId;
    final lastMessage = chat.message;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // For mentors, partnerId is customerId
            // For customers, partnerId is mentorId
            final orderId = chat.orderId;
            if (controller.isMentor) {
              // Mentor chatting with customer
              await controller.createOrGetChatRoom(mentorId: partnerId, orderId: orderId);
              Get.to(() => ChatRoomView(mentorId: partnerId, orderId: orderId));
            } else {
              // Customer chatting with mentor
              Get.to(() => ChatRoomView(mentorId: partnerId, orderId: orderId));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMentorAvatar(partnerId, isOnline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final displayName = controller.getUserName(partnerId);
                              return Text(
                                displayName,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) const SizedBox(width: 8),
                          if (unreadCount > 0) _buildUnreadIndicator(unreadCount),
                        ],
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
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 80, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Percakapan',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Mulai percakapan dengan mentor untuk mendapatkan bantuan belajar',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final bool isMentor = Get.isRegistered<HomeController>() ? Get.find<HomeController>().isMentor.value : false;
    return RefreshIndicator(
      onRefresh: () async {
        controller.loadChats();
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: Obx(
        () => controller.filteredChats.isEmpty
            ? _buildEmptyStateWrapper(isMentor)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = controller.filteredChats[index];
                  final isOnline = index % 3 == 0; // Dummy online status
                  final unreadCount = index % 4; // Dummy unread count
                  return _buildChatItem(chat, isOnline, unreadCount);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyStateWrapper(bool isMentor) {
    // Reuse existing empty state but optionally hide the CTA button
    final body = _buildEmptyState();
    if (!embed || isMentor) {
      // Remove the CTA button by replacing it with spacer
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 80, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Percakapan',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Mulai percakapan dengan mentor untuk mendapatkan bantuan belajar',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMentor = Get.isRegistered<HomeController>() ? Get.find<HomeController>().isMentor.value : false;
    if (!embed) {
      // Only the body without app bar/scaffold
      return _buildBody();
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => controller.isSearching.value
              ? TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.surface, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Cari percakapan...',
                    hintStyle: TextStyle(color: AppColors.surface.withOpacity(0.7)),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.surface.withOpacity(0.7)),
                  ),
                )
              : Text(
                  "Pesan",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.surface, fontSize: 18),
                ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(controller.isSearching.value ? Icons.close_rounded : Icons.search_rounded, size: 24),
              onPressed: controller.toggleSearch,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
