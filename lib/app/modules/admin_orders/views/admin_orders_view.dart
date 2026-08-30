import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:cermatify/app/modules/admin_orders/controllers/admin_orders_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOrdersView extends GetView<AdminOrdersController> {
  const AdminOrdersView({super.key});

  static const _filters = <(String, String)>[
    ('Semua', 'all'),
    ('Menunggu verifikasi', 'waiting verification'),
    ('Sedang diproses', 'progress'),
    ('Ditolak', 'rejected'),
    ('Selesai', 'completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pagePadding = width < 600 ? 16.0 : 28.0;
          final gutter = width > 1256 ? (width - 1200) / 2 : pagePadding;
          final columns = width >= 1050 ? 2 : 1;

          return Obx(() {
            final visibleOrders = controller.filteredOrders;
            if (controller.isLoading.value && controller.orders.isEmpty) {
              return const _OrdersLoadingState();
            }

            return RefreshIndicator(
              onRefresh: controller.fetchOrders,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      width < 600 ? 16 : 28,
                      gutter,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AdminOrdersHeader(
                        loadedCount: visibleOrders.length,
                        onBack: Get.back,
                        onRefresh: controller.fetchOrders,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                    sliver: SliverToBoxAdapter(child: _buildFilters()),
                  ),
                  if (visibleOrders.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _OrdersEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: width < 600 ? 420 : 338,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final order = visibleOrders[index];
                          return AdminOrderCard(
                            order: order,
                            statusColor: controller.getStatusColor(
                              order['status']?.toString() ?? '',
                            ),
                            statusText: controller.getStatusText(
                              order['status']?.toString() ?? '',
                            ),
                            isUpdating: controller.isUpdating.value,
                            onViewPayment: order['paymentProofUrl'] == null
                                ? null
                                : () => _showPaymentProof(
                                    order['paymentProofUrl'].toString(),
                                  ),
                            onStatusChanged: (status) =>
                                controller.updateOrderStatus(
                                  order['id'].toString(),
                                  status,
                                ),
                          );
                        }, childCount: visibleOrders.length),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 36),
                    sliver: SliverToBoxAdapter(child: _buildPagination()),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _filters.map((filter) {
          final selected = controller.selectedStatusFilter.value == filter.$2;
          return FilterChip(
            selected: selected,
            showCheckmark: false,
            label: Text(filter.$1),
            onSelected: (_) => controller.changeStatusFilter(filter.$2),
            backgroundColor: Colors.transparent,
            selectedColor: AppColors.primaryColor,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            labelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.surface : AppColors.textSecondary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    return AdminOrdersLoadMoreButton(
      hasMore: controller.hasMore.value,
      hasOrders: controller.orders.isNotEmpty,
      isLoading: controller.isLoadingMore.value,
      onLoadMore: controller.loadMore,
    );
  }

  void _showPaymentProof(String url) {
    Get.dialog<void>(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
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
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('Bukti pembayaran tidak dapat dimuat'),
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

class AdminOrdersLoadMoreButton extends StatelessWidget {
  const AdminOrdersLoadMoreButton({
    required this.hasMore,
    required this.hasOrders,
    required this.isLoading,
    required this.onLoadMore,
    super.key,
  });

  final bool hasMore;
  final bool hasOrders;
  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Center(
        child: Text(
          hasOrders ? 'Semua order telah ditampilkan' : '',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Center(
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onLoadMore,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more_rounded),
        label: Text(isLoading ? 'Memuat order...' : 'Tampilkan lebih banyak'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AdminOrdersHeader extends StatelessWidget {
  const AdminOrdersHeader({
    required this.loadedCount,
    required this.onBack,
    required this.onRefresh,
    super.key,
  });

  final int loadedCount;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Container(
          padding: EdgeInsets.all(compact ? 18 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.08),
                AppColors.lightPrimaryColor.withValues(alpha: 0.28),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Kembali',
                onTap: onBack,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengelolaan order',
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Verifikasi dan pantau seluruh transaksi Cermatify.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$loadedCount dimuat',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Muat ulang',
                  onTap: onRefresh,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({
    required this.order,
    required this.statusColor,
    required this.statusText,
    required this.isUpdating,
    required this.onStatusChanged,
    this.onViewPayment,
    super.key,
  });

  final Map<String, dynamic> order;
  final Color statusColor;
  final String statusText;
  final bool isUpdating;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback? onViewPayment;

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString().toLowerCase() ?? '';
    final price = (order['price'] as num?)?.toInt() ?? 0;
    final createdAt = order['createdAt'];
    final id = order['id']?.toString() ?? '-';
    final shortId = id.length > 8 ? id.substring(0, 8) : id;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _OrderDetail(
            icon: Icons.person_outline_rounded,
            label: 'Pengguna',
            value: order['userName']?.toString() ?? '-',
          ),
          const SizedBox(height: 8),
          _OrderDetail(
            icon: Icons.school_outlined,
            label: 'Mentor',
            value: order['mentorName']?.toString() ?? '-',
          ),
          const SizedBox(height: 8),
          _OrderDetail(
            icon: Icons.design_services_outlined,
            label: 'Layanan',
            value: order['layananName']?.toString() ?? '-',
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                AppFormats.hargaPendek(price),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (onViewPayment != null)
            OutlinedButton.icon(
              onPressed: onViewPayment,
              icon: const Icon(Icons.receipt_long_outlined, size: 17),
              label: const Text('Lihat bukti pembayaran'),
              style: _secondaryButtonStyle(),
            ),
          if (onViewPayment != null) const SizedBox(height: 8),
          _buildActions(status),
        ],
      ),
    );
  }

  Widget _buildActions(String status) {
    if (status == 'waiting verification' || status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isUpdating ? null : () => onStatusChanged('rejected'),
              style: _secondaryButtonStyle(color: AppColors.redColor),
              child: const Text('Tolak'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton(
              onPressed: isUpdating ? null : () => onStatusChanged('progress'),
              style: _primaryButtonStyle(AppColors.greenColor),
              child: const Text('Verifikasi'),
            ),
          ),
        ],
      );
    }
    if (status == 'progress' || status == 'approved') {
      return ElevatedButton.icon(
        onPressed: isUpdating ? null : () => onStatusChanged('completed'),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
        label: const Text('Tandai selesai'),
        style: _primaryButtonStyle(AppColors.primaryColor),
      );
    }
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == 'completed' ? 'Order telah selesai' : 'Tidak ada tindakan',
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  static String _formatDate(dynamic value) {
    final date = value is Timestamp
        ? value.toDate()
        : value is DateTime
        ? value
        : null;
    if (date == null) return 'Tanggal tidak tersedia';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({
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
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _OrdersLoadingState extends StatelessWidget {
  const _OrdersLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            'Memuat order terbaru...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada order',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order dengan status ini akan muncul di sini.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

ButtonStyle _primaryButtonStyle(Color color) {
  return ElevatedButton.styleFrom(
    backgroundColor: color,
    foregroundColor: AppColors.surface,
    elevation: 0,
    minimumSize: const Size(0, 42),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
  );
}

ButtonStyle _secondaryButtonStyle({Color color = AppColors.primaryColor}) {
  return OutlinedButton.styleFrom(
    foregroundColor: color,
    minimumSize: const Size(0, 42),
    side: BorderSide(color: color.withValues(alpha: 0.35)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
  );
}
