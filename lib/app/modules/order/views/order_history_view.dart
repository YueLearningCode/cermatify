import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/data/widgets/workspace_page_header.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/order_history_controller.dart';

int orderHistoryColumnCount(double width) => width >= 860 ? 2 : 1;

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  void _goBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    Get.offAllNamed(Routes.DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchOrders,
          child: ResponsiveContent(
            maxWidth: 1240,
            child: Obx(
              () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: WorkspacePageHeader(
                        eyebrow: 'Aktivitas layanan',
                        title: 'Riwayat order',
                        subtitle:
                            'Pantau pembayaran, progres layanan, dan akses percakapan mentor.',
                        onBack: _goBack,
                        trailing: _RefreshButton(
                          loading: controller.isLoading.value,
                          onPressed: controller.fetchOrders,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(child: _buildFilters()),
                  ),
                  if (controller.isLoading.value && controller.orders.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  else if (controller.filteredOrders.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: OrderHistoryEmptyState(
                        filtered: controller.selectedStatus.value != 'all',
                        onReset: () => controller.setStatusFilter('all'),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = orderHistoryColumnCount(
                              constraints.maxWidth,
                            );
                            final width = columns == 2
                                ? (constraints.maxWidth - 14) / 2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: controller.visibleOrders
                                  .map(
                                    (order) => SizedBox(
                                      width: width,
                                      child: OrderHistoryCard(
                                        order: order,
                                        statusLabel: controller.getStatusText(
                                          order['status']?.toString() ?? '',
                                        ),
                                        statusColor: controller.getStatusColor(
                                          order['status']?.toString() ?? '',
                                        ),
                                        onProof:
                                            order['paymentProofUrl'] == null
                                            ? null
                                            : () => _showPaymentProof(
                                                context,
                                                order['paymentProofUrl']
                                                    .toString(),
                                              ),
                                        onChat: _canChat(order)
                                            ? () => _openChat(order)
                                            : null,
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            );
                          },
                        ),
                      ),
                    ),
                    if (controller.hasMore)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: OutlinedButton.icon(
                              key: const Key('order-history-load-more'),
                              onPressed: controller.showMore,
                              icon: const Icon(Icons.expand_more_rounded),
                              label: Text(
                                'Tampilkan lebih banyak',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = <(String, String)>[
      ('all', 'Semua'),
      ('waiting', 'Menunggu'),
      ('progress', 'Diproses'),
      ('completed', 'Selesai'),
      ('rejected', 'Ditolak'),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters
              .map((filter) {
                final selected = controller.selectedStatus.value == filter.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    selected: selected,
                    onSelected: (_) => controller.setStatusFilter(filter.$1),
                    label: Text(filter.$2),
                    showCheckmark: false,
                    side: BorderSide.none,
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.primaryColor,
                    labelStyle: GoogleFonts.poppins(
                      color: selected
                          ? AppColors.surface
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  bool _canChat(Map<String, dynamic> order) {
    final status = order['status']?.toString().toLowerCase() ?? '';
    return status == 'progress' || status == 'approved';
  }

  Future<void> _openChat(Map<String, dynamic> order) async {
    final mentorId = order['mentorId']?.toString() ?? '';
    if (mentorId.isEmpty) return;
    final orderId = order['id']?.toString();
    final chat = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    await chat.createOrGetChatRoom(mentorId: mentorId, orderId: orderId);
    Get.toNamed(
      Routes.chatRoom(mentorId),
      arguments: {
        'orderId': orderId,
        'partnerName': order['mentorName']?.toString() ?? 'Mentor Cermatify',
      },
    );
  }

  void _showPaymentProof(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 10, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bukti pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Padding(
                      padding: EdgeInsets.all(48),
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 52,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    this.onProof,
    this.onChat,
  });

  final Map<String, dynamic> order;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onProof;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final id = order['id']?.toString() ?? '-';
    final shortId = id.length > 8 ? id.substring(0, 8) : id;
    final price = order['price'] as int? ?? 0;
    final createdAt = order['createdAt'];
    final date = createdAt is Timestamp
        ? '${createdAt.toDate().day.toString().padLeft(2, '0')}/${createdAt.toDate().month.toString().padLeft(2, '0')}/${createdAt.toDate().year}'
        : 'Tanggal tidak tersedia';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$shortId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 17),
          _OrderInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Mentor',
            value: order['mentorName']?.toString() ?? 'Mentor Cermatify',
          ),
          const SizedBox(height: 8),
          _OrderInfoRow(
            icon: Icons.design_services_outlined,
            label: 'Layanan',
            value: order['layananName']?.toString() ?? 'Layanan Cermatify',
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                AppFormats.hargaPendek(price),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (onProof != null || onChat != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                if (onProof != null)
                  OutlinedButton.icon(
                    onPressed: onProof,
                    icon: const Icon(Icons.receipt_long_outlined, size: 17),
                    label: const Text('Bukti bayar'),
                  ),
                if (onChat != null)
                  FilledButton.icon(
                    onPressed: onChat,
                    icon: const Icon(Icons.chat_bubble_outline, size: 17),
                    label: const Text('Chat mentor'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: 'Muat ulang order',
      onPressed: loading ? null : onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryColor,
      ),
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
    );
  }
}

class OrderHistoryEmptyState extends StatelessWidget {
  const OrderHistoryEmptyState({
    super.key,
    required this.filtered,
    required this.onReset,
  });

  final bool filtered;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
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
                  Icons.shopping_bag_outlined,
                  color: AppColors.primaryColor,
                  size: 31,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                filtered ? 'Order tidak ditemukan' : 'Belum ada order',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                filtered
                    ? 'Belum ada order dengan status yang dipilih.'
                    : 'Order layanan Anda akan muncul di halaman ini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (filtered) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onReset,
                  child: const Text('Lihat semua order'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
