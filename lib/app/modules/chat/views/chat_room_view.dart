import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/data/models/mentor_model.dart';
import '../controllers/chat_controller.dart';

class ChatRoomView extends GetView<ChatController> {
  final String mentorId;
  final Mentor? mentor;

  const ChatRoomView({super.key, required this.mentorId, this.mentor});

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Mentor sedang mengetik...",
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(Get.context!).size.width * 0.75),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  mentorId.isNotEmpty ? mentorId[0].toUpperCase() : 'M',
                  style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border.withOpacity(isMe ? 0.3 : 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: GoogleFonts.poppins(
                      color: isMe ? AppColors.surface : AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(msg.timestamp),
                        style: GoogleFonts.poppins(
                          color: isMe ? AppColors.surface.withOpacity(0.7) : AppColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all_rounded, size: 12, color: AppColors.surface.withOpacity(0.7)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.person_rounded, color: AppColors.surface, size: 16)),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load messages when view is created
    controller.loadMessages(mentorId);
    final String displayName = (mentor?.name.isNotEmpty == true ? mentor!.name : controller.getUserName(mentorId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.greenColor, AppColors.primaryLight]),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surface,
                    backgroundImage: mentor != null && mentor!.image.isNotEmpty ? NetworkImage(mentor!.image) : null,
                    child: (mentor == null || mentor!.image.isEmpty)
                        ? Text(
                            (displayName.isNotEmpty ? displayName[0] : (mentorId.isNotEmpty ? mentorId[0] : 'M'))
                                .toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.surface),
                  ),
                  Text(
                    "Online",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.surface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surface),
        actions: const [],
      ),
      body: Column(
        children: [
          // Date separator
          Obx(
            () => controller.chatMessages.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.border.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "Hari ini",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          // Messages list
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.chatMessages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.chatMessages.length && controller.isTyping.value) {
                    return _buildTypingIndicator();
                  }
                  final msg = controller.chatMessages[index];
                  // Align bubbles by actual sender: current user on the right, mentor on the left
                  final bool isMe = msg.senderId == controller.currentUserId;
                  return _buildMessageBubble(msg, isMe);
                },
              ),
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () {
                      Get.snackbar(
                        'Info',
                        'Fitur lampiran akan segera hadir',
                        backgroundColor: AppColors.primary,
                        colorText: AppColors.surface,
                        snackPosition: SnackPosition.BOTTOM,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    icon: Icon(Icons.attach_file_rounded, color: AppColors.textSecondary, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24)),
                    child: TextField(
                      controller: controller.messageController,
                      focusNode: controller.focusNode,
                      decoration: InputDecoration(
                        hintText: "Ketik pesan...",
                        hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 5,
                      minLines: 1,
                      onSubmitted: (_) => controller.sendMessage(mentorId),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: IconButton(
                      onPressed: controller.isSending.value ? null : () => controller.sendMessage(mentorId),
                      icon: controller.isSending.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: AppColors.surface, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
