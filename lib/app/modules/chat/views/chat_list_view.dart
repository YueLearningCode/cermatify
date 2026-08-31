import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cermatify/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_controller.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key, this.embed = true});

  final bool embed;

  void _goBack() {
    if (controller.isAdmin) {
      Get.offAllNamed(Routes.ADMIN_DASHBOARD);
      return;
    }
    if (controller.isMentor && Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeTab(0);
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    Get.offAllNamed(Routes.DASHBOARD);
  }

  Future<void> _startAdminConversation(BuildContext context) async {
    await controller.loadAdminContacts();
    if (!context.mounted) return;
    final contact = await showDialog<ChatContact>(
      context: context,
      builder: (context) => Obx(
        () => AdminChatContactPicker(
          contacts: controller.adminContacts,
          isLoading: controller.isLoadingContacts.value,
        ),
      ),
    );
    if (contact == null) return;
    await controller.createOrGetChatRoom(mentorId: contact.id);
    Get.toNamed(
      Routes.chatRoom(contact.id),
      arguments: <String, dynamic>{'partnerName': contact.name},
    );
  }

  Future<void> _openConversation(ChatMessage chat) async {
    final partnerId = chat.senderId == controller.currentUserId
        ? chat.receiverId
        : chat.senderId;
    if (controller.isMentor || controller.isAdmin) {
      await controller.createOrGetChatRoom(
        mentorId: partnerId,
        orderId: chat.orderId,
      );
    }
    Get.toNamed(
      Routes.chatRoom(partnerId),
      arguments: <String, dynamic>{
        'orderId': chat.orderId,
        'partnerName': controller.getUserName(partnerId),
      },
    );
  }

  Widget _conversationContent({required bool includePageHeader}) {
    return Column(
      children: [
        if (includePageHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ChatPageHeader(
              isAdmin: controller.isAdmin,
              isMentor: controller.isMentor,
              conversationCount: controller.chatRoomCount.value,
              searchController: controller.searchController,
              onBack: _goBack,
              onRefresh: controller.loadChats,
              onStartConversation: controller.isAdmin
                  ? () => _startAdminConversation(Get.context!)
                  : null,
            ),
          ),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingChats.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (controller.chatLoadError.value.isNotEmpty) {
              return ChatLoadErrorState(
                message: controller.chatLoadError.value,
                onRetry: controller.loadChats,
              );
            }
            if (controller.filteredChats.isEmpty) {
              return ChatEmptyState(
                isAdmin: controller.isAdmin,
                isMentor: controller.isMentor,
                isSearchResult: controller.searchController.text
                    .trim()
                    .isNotEmpty,
                onRefresh: controller.loadChats,
                onStartConversation: controller.isAdmin
                    ? () => _startAdminConversation(Get.context!)
                    : null,
              );
            }
            return _buildConversationGrid();
          }),
        ),
      ],
    );
  }

  Widget _buildConversationGrid() {
    return RefreshIndicator(
      onRefresh: () async => controller.loadChats(),
      color: AppColors.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTwoColumn = constraints.maxWidth >= 900;
          final horizontalPadding = constraints.maxWidth >= 700 ? 20.0 : 16.0;
          if (!isTwoColumn) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                28,
              ),
              itemCount: controller.filteredChats.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildConversationCard(index),
            );
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              28,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 142,
            ),
            itemCount: controller.filteredChats.length,
            itemBuilder: (context, index) => _buildConversationCard(index),
          );
        },
      ),
    );
  }

  Widget _buildConversationCard(int index) {
    final chat = controller.filteredChats[index];
    final partnerId = chat.senderId == controller.currentUserId
        ? chat.receiverId
        : chat.senderId;
    return Obx(
      () => ChatConversationCard(
        chat: chat,
        partnerName: controller.getUserName(partnerId),
        isAdmin: controller.isAdmin,
        onTap: () => _openConversation(chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!embed) return _conversationContent(includePageHeader: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 1280,
          child: Obx(() => _conversationContent(includePageHeader: true)),
        ),
      ),
    );
  }
}

class ChatPageHeader extends StatelessWidget {
  const ChatPageHeader({
    super.key,
    required this.isAdmin,
    this.isMentor = false,
    required this.conversationCount,
    required this.searchController,
    required this.onBack,
    required this.onRefresh,
    this.onStartConversation,
  });

  final bool isAdmin;
  final bool isMentor;
  final int conversationCount;
  final TextEditingController searchController;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback? onStartConversation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin
                    ? 'PUSAT PERCAKAPAN'
                    : isMentor
                    ? 'MENTOR WORKSPACE'
                    : 'PERCAKAPAN',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAdmin
                  ? 'Pesan dari pengguna'
                  : isMentor
                  ? 'Percakapan pendampingan'
                  : 'Pesan',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: compact ? 23 : 28,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAdmin
                  ? 'Pantau dan tanggapi kebutuhan pengguna dari satu tempat.'
                  : isMentor
                  ? 'Tanggapi pengguna dan lanjutkan setiap sesi pendampingan.'
                  : 'Lanjutkan percakapan dan pendampingan Anda.',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: compact ? 12 : 13,
                height: 1.5,
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _HeaderCountBadge(count: conversationCount, compact: compact),
            if (onStartConversation != null) ...[
              FilledButton.icon(
                key: const Key('start-admin-chat-button'),
                onPressed: onStartConversation,
                icon: compact
                    ? const SizedBox.shrink()
                    : const Icon(Icons.add_comment_outlined, size: 17),
                label: Text(compact ? 'Baru' : 'Pesan baru'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            _HeaderIconButton(
              tooltip: 'Muat ulang',
              icon: Icons.refresh_rounded,
              onPressed: onRefresh,
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(compact ? 18 : 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 24 : 28),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.primaryLight.withValues(alpha: 0.25),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderIconButton(
                    tooltip: 'Kembali',
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBack,
                  ),
                  SizedBox(width: compact ? 12 : 16),
                  Expanded(child: copy),
                  if (!compact) actions,
                ],
              ),
              if (compact) ...[
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: actions),
              ],
              const SizedBox(height: 18),
              TextField(
                key: const Key('chat-search-field'),
                controller: searchController,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: isAdmin
                      ? 'Cari nama pengguna atau isi pesan...'
                      : 'Cari percakapan...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryColor,
                  ),
                  filled: true,
                  fillColor: AppColors.surface.withValues(alpha: 0.92),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.4,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primaryColor),
      ),
    );
  }
}

class _HeaderCountBadge extends StatelessWidget {
  const _HeaderCountBadge({required this.count, required this.compact});

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 17,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 7),
          Text(
            compact ? '$count chat' : '$count percakapan',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatConversationCard extends StatelessWidget {
  const ChatConversationCard({
    super.key,
    required this.chat,
    required this.partnerName,
    required this.isAdmin,
    required this.onTap,
  });

  final ChatMessage chat;
  final String partnerName;
  final bool isAdmin;
  final VoidCallback onTap;

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final local = timestamp.toLocal();
    final isToday =
        now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;
    if (isToday) return DateFormat('HH:mm').format(local);
    if (now.difference(local).inDays < 7) {
      return DateFormat('EEE', 'id_ID').format(local);
    }
    return DateFormat('dd/MM/yy').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final initial = partnerName.trim().isEmpty
        ? 'P'
        : partnerName.trim()[0].toUpperCase();
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        key: const Key('chat-conversation-card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.checkoutButtonColor,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            partnerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(chat.timestamp),
                          style: GoogleFonts.poppins(
                            color: AppColors.textLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chat.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAdmin
                                  ? Icons.person_outline_rounded
                                  : Icons.chat_bubble_outline_rounded,
                              size: 14,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isAdmin ? 'Pengguna' : 'Percakapan aktif',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (chat.orderId?.isNotEmpty == true)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 14,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Terkait order',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryColor,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.isAdmin,
    this.isMentor = false,
    required this.isSearchResult,
    required this.onRefresh,
    this.onStartConversation,
  });

  final bool isAdmin;
  final bool isMentor;
  final bool isSearchResult;
  final VoidCallback onRefresh;
  final VoidCallback? onStartConversation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 40).clamp(260, 560),
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 720),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 42,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.checkoutButtonColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        isSearchResult
                            ? Icons.search_off_rounded
                            : Icons.forum_outlined,
                        size: 36,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSearchResult
                          ? 'Percakapan tidak ditemukan'
                          : 'Belum ada percakapan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSearchResult
                          ? 'Coba gunakan nama atau kata kunci pesan yang berbeda.'
                          : isAdmin
                          ? 'Pesan bantuan dari pengguna akan tampil di halaman ini.'
                          : isMentor
                          ? 'Percakapan dari order pendampingan aktif akan tampil di sini.'
                          : 'Percakapan aktif Anda akan tampil di halaman ini.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    if (!isSearchResult) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (onStartConversation != null)
                            FilledButton.icon(
                              onPressed: onStartConversation,
                              icon: const Icon(
                                Icons.add_comment_outlined,
                                size: 18,
                              ),
                              label: const Text('Pilih pengguna'),
                            ),
                          OutlinedButton.icon(
                            onPressed: onRefresh,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Periksa kembali'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminChatContactPicker extends StatefulWidget {
  const AdminChatContactPicker({
    super.key,
    required this.contacts,
    required this.isLoading,
  });

  final List<ChatContact> contacts;
  final bool isLoading;

  @override
  State<AdminChatContactPicker> createState() => _AdminChatContactPickerState();
}

class _AdminChatContactPickerState extends State<AdminChatContactPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatContact> get _filteredContacts {
    if (_query.isEmpty) return widget.contacts;
    return widget.contacts
        .where(
          (contact) =>
              contact.name.toLowerCase().contains(_query) ||
              contact.email.toLowerCase().contains(_query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: viewport.width < 600 ? 16 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: viewport.height * 0.82,
        ),
        child: Padding(
          padding: EdgeInsets.all(viewport.width < 600 ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.checkoutButtonColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.add_comment_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih pengguna',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Buka detail percakapan dengan pengguna.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau email pengguna...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildContactList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactList() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    final contacts = _filteredContacts;
    if (contacts.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty
              ? 'Belum ada akun pengguna.'
              : 'Pengguna tidak ditemukan.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final initial = contact.name.trim().isEmpty
            ? 'P'
            : contact.name.trim()[0].toUpperCase();
        return Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            key: ValueKey('admin-chat-contact-${contact.id}'),
            onTap: () => Navigator.of(context).pop(contact),
            borderRadius: BorderRadius.circular(17),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.checkoutButtonColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (contact.email.isNotEmpty)
                          Text(
                            contact.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChatLoadErrorState extends StatelessWidget {
  const ChatLoadErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 14),
            Text(message, style: GoogleFonts.poppins()),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
