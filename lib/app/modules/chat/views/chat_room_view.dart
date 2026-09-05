import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class ChatRoomView extends GetView<ChatController> {
  const ChatRoomView({
    super.key,
    required this.mentorId,
    this.mentor,
    this.orderId,
    this.partnerName,
  });

  /// Kept for compatibility with existing callers; this is the chat partner ID.
  final String mentorId;
  final Mentor? mentor;
  final String? orderId;
  final String? partnerName;

  String get _displayName {
    if (partnerName?.trim().isNotEmpty == true) return partnerName!.trim();
    if (mentor?.name.trim().isNotEmpty == true) return mentor!.name.trim();
    return controller.getUserName(mentorId);
  }

  void _goBack() {
    if (controller.isAdmin) {
      Get.offNamed(Routes.CHAT);
      return;
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeTab(1);
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
      return;
    }
    Get.offAllNamed(Routes.DASHBOARD, arguments: const {'initialTab': 1});
  }

  @override
  Widget build(BuildContext context) {
    controller.loadMessages(mentorId, orderId: orderId);
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 1160,
          child: Padding(
            padding: EdgeInsets.all(compact ? 0 : 20),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(compact ? 0 : 28),
                border: compact ? null : Border.all(color: AppColors.border),
                boxShadow: compact
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  ChatRoomHeader(
                    displayName: _displayName,
                    isAdmin: controller.isAdmin,
                    imageUrl: mentor?.image,
                    orderId: orderId,
                    onBack: _goBack,
                  ),
                  Expanded(child: _buildMessages()),
                  _buildMessageComposer(compact),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ColoredBox(
      color: AppColors.background,
      child: Obx(() {
        if (controller.isLoadingMessages.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        if (controller.messageLoadError.value.isNotEmpty) {
          return _ChatRoomErrorState(
            message: controller.messageLoadError.value,
            onRetry: () => controller.loadMessages(mentorId, orderId: orderId),
          );
        }
        if (controller.chatMessages.isEmpty) {
          return _ChatRoomEmptyState(
            partnerName: _displayName,
            isAdmin: controller.isAdmin,
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          itemCount:
              controller.chatMessages.length +
              (controller.isTyping.value ? 1 : 0) +
              1,
          itemBuilder: (context, index) {
            if (index == 0) return const _TodaySeparator();
            final messageIndex = index - 1;
            if (messageIndex == controller.chatMessages.length) {
              return _TypingIndicator(isAdmin: controller.isAdmin);
            }
            final message = controller.chatMessages[messageIndex];
            return ChatMessageBubble(
              message: message,
              isMine: message.senderId == controller.currentUserId,
              partnerName: _displayName,
            );
          },
        );
      }),
    );
  }

  Widget _buildMessageComposer(bool compact) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 18,
        12,
        compact ? 12 : 18,
        compact ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!compact) ...[
            IconButton.filledTonal(
              tooltip: 'Lampiran',
              onPressed: () => Get.snackbar(
                'Info',
                'Fitur lampiran akan segera hadir',
                snackPosition: SnackPosition.BOTTOM,
              ),
              icon: const Icon(Icons.attach_file_rounded),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              key: const Key('chat-message-field'),
              controller: controller.messageController,
              focusNode: controller.focusNode,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) =>
                  controller.sendMessage(mentorId, orderId: orderId),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                key: const Key('send-chat-button'),
                onPressed: controller.isSending.value
                    ? null
                    : () => controller.sendMessage(mentorId, orderId: orderId),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isSending.value
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 21),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatRoomHeader extends StatelessWidget {
  const ChatRoomHeader({
    super.key,
    required this.displayName,
    required this.isAdmin,
    required this.onBack,
    this.imageUrl,
    this.orderId,
  });

  final String displayName;
  final bool isAdmin;
  final String? imageUrl;
  final String? orderId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final initial = displayName.trim().isEmpty
        ? 'P'
        : displayName.trim()[0].toUpperCase();
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 20,
            vertical: compact ? 12 : 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.primaryLight.withValues(alpha: 0.18),
              ],
            ),
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                child: IconButton(
                  key: const Key('chat-room-back-button'),
                  tooltip: 'Kembali',
                  padding: EdgeInsets.zero,
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              SizedBox(width: compact ? 3 : 6),
              CircleAvatar(
                radius: compact ? 19 : 24,
                backgroundColor: AppColors.checkoutButtonColor,
                backgroundImage: imageUrl?.isNotEmpty == true
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl?.isNotEmpty == true
                    ? null
                    : Text(
                        initial,
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              SizedBox(width: compact ? 9 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAdmin
                          ? 'Pengguna Cermatify'
                          : 'Percakapan pendampingan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact && orderId?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 15,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Terkait order',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.partnerName,
  });

  final ChatMessage message;
  final bool isMine;
  final String partnerName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBubbleWidth = (constraints.maxWidth * 0.72).clamp(180, 620);
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth.toDouble()),
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: isMine ? AppColors.primaryColor : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 5),
                bottomRight: Radius.circular(isMine ? 5 : 18),
              ),
              border: isMine ? null : Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: GoogleFonts.poppins(
                    color: isMine ? AppColors.surface : AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat('HH:mm').format(message.timestamp.toLocal()),
                  style: GoogleFonts.poppins(
                    color: isMine
                        ? AppColors.surface.withValues(alpha: 0.76)
                        : AppColors.textLight,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodaySeparator extends StatelessWidget {
  const _TodaySeparator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Hari ini',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          isAdmin ? 'Pengguna sedang mengetik...' : 'Sedang mengetik...',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _ChatRoomEmptyState extends StatelessWidget {
  const _ChatRoomEmptyState({required this.partnerName, required this.isAdmin});

  final String partnerName;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.checkoutButtonColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.waving_hand_outlined,
                size: 30,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              'Mulai percakapan',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isAdmin
                  ? 'Kirim pesan pertama kepada $partnerName.'
                  : 'Belum ada pesan dalam percakapan ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRoomErrorState extends StatelessWidget {
  const _ChatRoomErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.poppins()),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
