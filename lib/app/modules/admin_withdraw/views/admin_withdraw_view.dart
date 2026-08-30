import 'package:cermatify/app/data/models/withdraw_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:cermatify/app/modules/admin_withdraw/controllers/admin_withdraw_controller.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminWithdrawView extends GetView<AdminWithdrawController> {
  const AdminWithdrawView({super.key});

  static const _filters = <(String, String)>[
    ('Semua', 'all'),
    ('Menunggu', 'pending'),
    ('Disetujui', 'approved'),
    ('Ditolak', 'rejected'),
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
            final visibleWithdraws = controller.filteredWithdraws;
            if (controller.isLoading.value && controller.withdraws.isEmpty) {
              return const _WithdrawLoadingState();
            }

            return RefreshIndicator(
              onRefresh: controller.fetchWithdraws,
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
                      child: AdminWithdrawHeader(
                        loadedCount: visibleWithdraws.length,
                        onBack: () => _handleBack(context),
                        onRefresh: controller.fetchWithdraws,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                    sliver: SliverToBoxAdapter(child: _buildFilters()),
                  ),
                  if (visibleWithdraws.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _WithdrawEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                      sliver: width < 600
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildWithdrawCard(
                                    visibleWithdraws[index],
                                  ),
                                ),
                                childCount: visibleWithdraws.length,
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 330,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildWithdrawCard(visibleWithdraws[index]),
                                childCount: visibleWithdraws.length,
                              ),
                            ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 36),
                    sliver: SliverToBoxAdapter(
                      child: AdminWithdrawLoadMoreButton(
                        hasMore: controller.hasMore.value,
                        hasWithdraws: controller.withdraws.isNotEmpty,
                        isLoading: controller.isLoadingMore.value,
                        onLoadMore: controller.loadMore,
                      ),
                    ),
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

  Widget _buildWithdrawCard(WithdrawModel withdraw) {
    return AdminWithdrawCard(
      withdraw: withdraw,
      statusColor: controller.getStatusColor(withdraw.status),
      statusText: controller.getStatusText(withdraw.status),
      isUpdating: controller.isUpdating.value,
      onStatusChanged: (status) =>
          controller.updateWithdrawStatus(withdraw.id, status),
    );
  }

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    Get.offAllNamed(Routes.ADMIN_DASHBOARD);
  }
}

class AdminWithdrawHeader extends StatelessWidget {
  const AdminWithdrawHeader({
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
              _WithdrawHeaderButton(
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
                      'Pengelolaan withdraw',
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tinjau dan verifikasi permintaan pencairan mentor.',
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
                _WithdrawHeaderButton(
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

class AdminWithdrawCard extends StatelessWidget {
  const AdminWithdrawCard({
    required this.withdraw,
    required this.statusColor,
    required this.statusText,
    required this.isUpdating,
    required this.onStatusChanged,
    super.key,
  });

  final WithdrawModel withdraw;
  final Color statusColor;
  final String statusText;
  final bool isUpdating;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
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
                    Icons.account_balance_wallet_outlined,
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
                        withdraw.mentorName.isEmpty
                            ? 'Mentor Cermatify'
                            : withdraw.mentorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AppFormats.formatDateHours(withdraw.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 104),
                  child: Container(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _WithdrawDetail(
              icon: Icons.account_circle_outlined,
              label: 'Pemilik',
              value: withdraw.namaRekening,
            ),
            const SizedBox(height: 9),
            _WithdrawDetail(
              icon: Icons.credit_card_outlined,
              label: 'Rekening',
              value: withdraw.nomorRekening,
            ),
            if (withdraw.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 9),
              _WithdrawDetail(
                icon: Icons.notes_rounded,
                label: 'Catatan',
                value: withdraw.notes!,
              ),
            ],
            if (constraints.hasBoundedHeight)
              const Spacer()
            else
              const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nominal pencairan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppFormats.hargaPendek(withdraw.nominal),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (withdraw.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isUpdating ? null : () => onStatusChanged('rejected'),
              style: _withdrawSecondaryButtonStyle(),
              child: const Text('Tolak'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton(
              onPressed: isUpdating ? null : () => onStatusChanged('approved'),
              style: _withdrawPrimaryButtonStyle(),
              child: const Text('Setujui'),
            ),
          ),
        ],
      );
    }

    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        withdraw.status == 'approved'
            ? 'Pencairan telah disetujui'
            : 'Permintaan telah ditolak',
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class AdminWithdrawLoadMoreButton extends StatelessWidget {
  const AdminWithdrawLoadMoreButton({
    required this.hasMore,
    required this.hasWithdraws,
    required this.isLoading,
    required this.onLoadMore,
    super.key,
  });

  final bool hasMore;
  final bool hasWithdraws;
  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Center(
        child: Text(
          hasWithdraws ? 'Semua permintaan telah ditampilkan' : '',
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
        label: Text(
          isLoading ? 'Memuat permintaan...' : 'Tampilkan lebih banyak',
        ),
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

class _WithdrawDetail extends StatelessWidget {
  const _WithdrawDetail({
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
            value.isEmpty ? '-' : value,
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

class _WithdrawHeaderButton extends StatelessWidget {
  const _WithdrawHeaderButton({
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

class _WithdrawLoadingState extends StatelessWidget {
  const _WithdrawLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            'Memuat permintaan withdraw...',
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

class _WithdrawEmptyState extends StatelessWidget {
  const _WithdrawEmptyState();

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
              Icons.account_balance_wallet_outlined,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada permintaan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Permintaan dengan status ini akan muncul di sini.',
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

ButtonStyle _withdrawPrimaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppColors.greenColor,
    foregroundColor: AppColors.surface,
    elevation: 0,
    minimumSize: const Size(0, 42),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
  );
}

ButtonStyle _withdrawSecondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: AppColors.redColor,
    minimumSize: const Size(0, 42),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    side: BorderSide(color: AppColors.redColor.withValues(alpha: 0.35)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
  );
}
