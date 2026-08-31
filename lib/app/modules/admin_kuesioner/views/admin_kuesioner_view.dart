import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/admin_kuesioner/controllers/admin_kuesioner_controller.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminKuesionerView extends GetView<AdminKuesionerController> {
  const AdminKuesionerView({super.key});

  static const _filters = <(String, String)>[
    ('Semua', 'all'),
    ('Menunggu verifikasi', 'waiting verification'),
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
            final visibleItems = controller.filteredKuesioners;
            if (controller.isLoading.value && controller.kuesioners.isEmpty) {
              return const _KuesionerLoadingState();
            }

            return RefreshIndicator(
              onRefresh: controller.fetchKuesioners,
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
                      child: AdminKuesionerHeader(
                        loadedCount: visibleItems.length,
                        onBack: () => Get.offAllNamed(Routes.ADMIN_DASHBOARD),
                        onRefresh: controller.fetchKuesioners,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                    sliver: SliverToBoxAdapter(child: _buildFilters()),
                  ),
                  if (controller.loadError.value.isNotEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _KuesionerErrorState(
                        message: controller.loadError.value,
                        onRetry: controller.fetchKuesioners,
                      ),
                    )
                  else if (visibleItems.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _KuesionerEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                      sliver: width < 600
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildCard(
                                    context,
                                    visibleItems[index],
                                  ),
                                ),
                                childCount: visibleItems.length,
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 390,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildCard(context, visibleItems[index]),
                                childCount: visibleItems.length,
                              ),
                            ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 36),
                    sliver: SliverToBoxAdapter(
                      child: AdminKuesionerLoadMoreButton(
                        hasMore: controller.hasMore.value,
                        hasItems: controller.kuesioners.isNotEmpty,
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

  Widget _buildCard(BuildContext context, AdminKuesionerItem item) {
    final kuesioner = item.kuesioner;
    final status = kuesioner.status ?? '';
    return AdminKuesionerCard(
      item: item,
      statusColor: controller.getStatusColor(status),
      statusText: controller.getStatusText(status),
      isUpdating: controller.isUpdating.value,
      onViewDetail: () => _showDetails(context, item),
      onStatusChanged: (newStatus) =>
          _confirmStatusChange(context, item, newStatus),
    );
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    AdminKuesionerItem item,
    String status,
  ) async {
    final approve = status == 'approved';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: Icon(
          approve ? Icons.verified_outlined : Icons.cancel_outlined,
          color: approve ? AppColors.greenColor : AppColors.redColor,
          size: 32,
        ),
        title: Text(
          approve ? 'Setujui kuesioner?' : 'Tolak kuesioner?',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          approve
              ? 'Order terkait akan dilanjutkan ke tahap pemrosesan.'
              : 'Order terkait juga akan ditandai sebagai ditolak.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: approve
                  ? AppColors.greenColor
                  : AppColors.redColor,
            ),
            child: Text(approve ? 'Ya, setujui' : 'Ya, tolak'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.updateKuesionerStatus(item.kuesioner.id, status);
    }
  }

  void _showDetails(BuildContext context, AdminKuesionerItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => AdminKuesionerDetailDialog(item: item),
    );
  }
}

class AdminKuesionerHeader extends StatelessWidget {
  const AdminKuesionerHeader({
    super.key,
    required this.loadedCount,
    required this.onBack,
    required this.onRefresh,
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
                tooltip: 'Kembali',
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengelolaan kuesioner',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Verifikasi kebutuhan responden dan pantau progres layanan.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 11,
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
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _HeaderIconButton(
                  tooltip: 'Muat ulang',
                  icon: Icons.refresh_rounded,
                  onPressed: onRefresh,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class AdminKuesionerCard extends StatelessWidget {
  const AdminKuesionerCard({
    super.key,
    required this.item,
    required this.statusColor,
    required this.statusText,
    required this.isUpdating,
    required this.onViewDetail,
    required this.onStatusChanged,
  });

  final AdminKuesionerItem item;
  final Color statusColor;
  final String statusText;
  final bool isUpdating;
  final VoidCallback onViewDetail;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final kuesioner = item.kuesioner;
    final status = kuesioner.status?.toLowerCase() ?? '';
    final isWaiting = status == 'waiting verification' || status == 'pending';
    final shortId = kuesioner.id.length > 8
        ? kuesioner.id.substring(0, 8)
        : kuesioner.id;
    final criteria = _criteriaFor(kuesioner);

    return LayoutBuilder(
      builder: (context, _) {
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
                      Icons.assignment_outlined,
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
                          'Kuesioner #$shortId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy, HH:mm',
                          ).format(kuesioner.createdAt),
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(color: statusColor, label: statusText),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Pembuat',
                value: item.userName,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.groups_outlined,
                label: 'Responden',
                value: '${item.respondentCount} orang',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.link_rounded,
                label: 'Tautan',
                value: kuesioner.link?.isNotEmpty == true
                    ? kuesioner.link!
                    : 'Belum tersedia',
              ),
              const SizedBox(height: 14),
              Text(
                'Kriteria responden',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              if (criteria.isEmpty)
                Text(
                  'Tidak ada kriteria khusus',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: criteria
                      .map((value) => _CriteriaChip(label: value))
                      .toList(),
                ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onViewDetail,
                icon: const Icon(Icons.visibility_outlined, size: 17),
                label: const Text('Lihat detail'),
              ),
              if (isWaiting) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUpdating
                            ? null
                            : () => onStatusChanged('rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.redColor,
                          side: const BorderSide(color: AppColors.redColor),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton(
                        onPressed: isUpdating
                            ? null
                            : () => onStatusChanged('approved'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.greenColor,
                        ),
                        child: const Text('Setujui'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<String> _criteriaFor(Kuesioner kuesioner) {
    return <String?>[
      kuesioner.rentangUsia == null ? null : 'Usia ${kuesioner.rentangUsia}',
      kuesioner.jenisKelamin,
      kuesioner.tingkatPenghasilan,
      kuesioner.pendidikanTerakhir,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
  }
}

class AdminKuesionerDetailDialog extends StatelessWidget {
  const AdminKuesionerDetailDialog({super.key, required this.item});

  final AdminKuesionerItem item;

  @override
  Widget build(BuildContext context) {
    final kuesioner = item.kuesioner;
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 10, 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.08),
                    AppColors.lightPrimaryColor.withValues(alpha: 0.22),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Detail kuesioner',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailTile(label: 'Pembuat', value: item.userName),
                    _DetailTile(
                      label: 'Jumlah responden',
                      value: '${item.respondentCount} orang',
                    ),
                    _DetailTile(
                      label: 'Dibuat pada',
                      value: DateFormat(
                        'dd/MM/yyyy, HH:mm',
                      ).format(kuesioner.createdAt),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kriteria responden',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children:
                          <String?>[
                                kuesioner.rentangUsia,
                                kuesioner.jenisKelamin,
                                kuesioner.tingkatPenghasilan,
                                kuesioner.pendidikanTerakhir,
                              ]
                              .whereType<String>()
                              .where((value) => value.trim().isNotEmpty)
                              .map((value) => _CriteriaChip(label: value))
                              .toList(),
                    ),
                    if (kuesioner.link?.isNotEmpty == true) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                kuesioner.link!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 11),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Salin tautan',
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: kuesioner.link!),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded),
                            ),
                            IconButton(
                              tooltip: 'Buka tautan',
                              onPressed: () async {
                                final uri = Uri.tryParse(kuesioner.link!);
                                if (uri != null) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminKuesionerLoadMoreButton extends StatelessWidget {
  const AdminKuesionerLoadMoreButton({
    super.key,
    required this.hasMore,
    required this.hasItems,
    required this.isLoading,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool hasItems;
  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Center(
        child: Text(
          hasItems ? 'Semua kuesioner telah ditampilkan' : '',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 11,
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
          isLoading ? 'Memuat kuesioner...' : 'Tampilkan lebih banyak',
        ),
      ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
        Icon(icon, size: 15, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CriteriaChip extends StatelessWidget {
  const _CriteriaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.checkoutButtonColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.primaryColor,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KuesionerLoadingState extends StatelessWidget {
  const _KuesionerLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }
}

class _KuesionerEmptyState extends StatelessWidget {
  const _KuesionerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 54,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak ada kuesioner',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Data dengan status yang dipilih belum tersedia.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _KuesionerErrorState extends StatelessWidget {
  const _KuesionerErrorState({required this.message, required this.onRetry});

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
            size: 48,
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
