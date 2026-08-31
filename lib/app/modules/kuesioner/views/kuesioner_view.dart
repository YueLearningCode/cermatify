import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/kuesioner/controllers/kuesioner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cermatify/app/routes/app_pages.dart';

int kuesionerColumnCount(double width) => width >= 980 ? 2 : 1;

class KuesionerView extends GetView<KuesionerController> {
  const KuesionerView({super.key});

  static const _tabs = ['Rekomendasi', 'Dibuat saya', 'Saya ikuti'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final padding = viewport.maxWidth < 600 ? 16.0 : 28.0;
            final gutter = viewport.maxWidth > 1256
                ? (viewport.maxWidth - 1200) / 2
                : padding;
            final columns = kuesionerColumnCount(viewport.maxWidth);
            return Obx(() {
              final items = _visibleItems;
              return RefreshIndicator(
                onRefresh: controller.refreshAll,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 0),
                      sliver: SliverToBoxAdapter(
                        child: KuesionerHeader(
                          itemCount: items.length,
                          hasProfileData: controller.hasRespondenData.value,
                          onRefresh: controller.refreshAll,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                      sliver: SliverToBoxAdapter(child: _buildTabs()),
                    ),
                    if (controller.selectedTab.value == 0 &&
                        !controller.hasRespondenData.value)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: KuesionerEmptyState(
                          icon: Icons.manage_accounts_outlined,
                          title: 'Lengkapi data responden',
                          message:
                              'Isi data tambahan agar rekomendasi kuesioner sesuai dengan profil Anda.',
                          actionLabel: 'Lengkapi data',
                          onAction: _openRespondentData,
                        ),
                      )
                    else if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: KuesionerEmptyState(
                          icon: Icons.assignment_outlined,
                          title: _emptyTitle,
                          message:
                              'Kuesioner yang tersedia akan ditampilkan pada bagian ini.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 100),
                        sliver: SliverList.separated(
                          itemCount: (items.length / columns).ceil(),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, rowIndex) {
                            final first = rowIndex * columns;
                            if (columns == 1) {
                              return KuesionerUserCard(
                                index: first,
                                item: items[first],
                                onTap: () => _openDetail(items[first]),
                              );
                            }
                            final second = first + 1;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: KuesionerUserCard(
                                    index: first,
                                    item: items[first],
                                    onTap: () => _openDetail(items[first]),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: second < items.length
                                      ? KuesionerUserCard(
                                          index: second,
                                          item: items[second],
                                          onTap: () =>
                                              _openDetail(items[second]),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            });
          },
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: _openRespondentData,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          icon: Icon(
            controller.hasRespondenData.value
                ? Icons.edit_outlined
                : Icons.person_add_alt_rounded,
          ),
          label: Text(
            controller.hasRespondenData.value
                ? 'Edit data responden'
                : 'Data responden',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<Kuesioner> get _visibleItems {
    switch (controller.selectedTab.value) {
      case 1:
        return controller.createdByMeList;
      case 2:
        return controller.signedByMeList;
      default:
        return controller.kuesionerList;
    }
  }

  String get _emptyTitle {
    switch (controller.selectedTab.value) {
      case 1:
        return 'Belum membuat kuesioner';
      case 2:
        return 'Belum mengikuti kuesioner';
      default:
        return 'Belum ada rekomendasi';
    }
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final selected = controller.selectedTab.value == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
              child: Material(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => controller.selectedTab.value = index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Text(
                      _tabs[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: selected
                            ? AppColors.surface
                            : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _openDetail(Kuesioner item) {
    Get.toNamed(Routes.kuesionerDetail(item.id), arguments: item);
  }

  void _openRespondentData() {
    final data = controller.respondenData;
    Get.toNamed(
      Routes.RESPONDENT_DATA,
      arguments: <String, dynamic>{
        'rentangUsia': data['rentangUsia'] as String?,
        'jenisKelamin': data['jenisKelamin'] as String?,
        'tingkatPenghasilan': data['tingkatPenghasilan'] as String?,
        'pendidikanTerakhir': data['pendidikanTerakhir'] as String?,
      },
    );
  }
}

class KuesionerHeader extends StatelessWidget {
  const KuesionerHeader({
    super.key,
    required this.itemCount,
    required this.hasProfileData,
    required this.onRefresh,
  });
  final int itemCount;
  final bool hasProfileData;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 22 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.07),
            AppColors.lightPrimaryColor.withValues(alpha: 0.32),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.lightPrimaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuesioner',
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 21 : 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  hasProfileData
                      ? '$itemCount data pada tab aktif.'
                      : 'Lengkapi profil responden untuk rekomendasi yang sesuai.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Muat ulang',
            onPressed: onRefresh,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class KuesionerUserCard extends StatelessWidget {
  const KuesionerUserCard({
    super.key,
    required this.index,
    required this.item,
    required this.onTap,
  });
  final int index;
  final Kuesioner item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(item.status);
    final criteria = <String?>[
      item.rentangUsia,
      item.jenisKelamin,
      item.pendidikanTerakhir,
    ].whereType<String>().where((value) => value.isNotEmpty).toList();
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: status.color,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kuesioner ${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy, HH:mm',
                          ).format(item.createdAt),
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
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: GoogleFonts.poppins(
                        color: status.color,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (criteria.isNotEmpty) ...[
                const SizedBox(height: 15),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: criteria
                      .map(
                        (value) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.link?.isNotEmpty == true
                          ? item.link!
                          : 'Lihat informasi kuesioner',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static ({Color color, String label}) _statusPresentation(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return (color: AppColors.greenColor, label: 'Disetujui');
      case 'rejected':
      case 'ditolak':
        return (color: AppColors.redColor, label: 'Ditolak');
      default:
        return (color: AppColors.yellow2Color, label: 'Menunggu');
    }
  }
}

class KuesionerEmptyState extends StatelessWidget {
  const KuesionerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.primary, size: 29),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
