import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:cermatify/app/modules/profile/controllers/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

int mentorMetricColumnCount(double width) {
  if (width >= 1000) return 4;
  if (width >= 520) return 2;
  return 1;
}

class MentorHomeView extends GetView<ProfileController> {
  const MentorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final chat = Get.find<ChatController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            chat.loadChats();
            await Future.wait([
              controller.fetchUserData(),
              controller.fetchMentorOrders(),
            ]);
          },
          child: LayoutBuilder(
            builder: (context, viewport) {
              final padding = viewport.maxWidth < 600 ? 16.0 : 28.0;
              final gutter = viewport.maxWidth > 1256
                  ? (viewport.maxWidth - 1200) / 2
                  : padding;
              return Obx(
                () => CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 0),
                      sliver: SliverToBoxAdapter(
                        child: MentorWelcomeHeader(
                          name: controller.userName.value,
                          specialization: _specializationLabel(
                            controller.userMentorRole.value,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 26, gutter, 0),
                      sliver: const SliverToBoxAdapter(
                        child: _SectionTitle(
                          title: 'Ringkasan pendampingan',
                          subtitle:
                              'Pantau aktivitas utama dan kondisi akun mentor Anda.',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate([
                          MentorMetricCard(
                            icon: Icons.work_outline_rounded,
                            value: '${controller.mentorOrders.length}',
                            label: 'Order aktif',
                            color: AppColors.greenColor,
                          ),
                          MentorMetricCard(
                            icon: Icons.forum_outlined,
                            value: '${chat.chatRoomCount.value}',
                            label: 'Percakapan',
                            color: AppColors.primary,
                          ),
                          MentorMetricCard(
                            icon: Icons.account_balance_wallet_outlined,
                            value: _formatCurrency(controller.saldo.value),
                            label: 'Saldo tersedia',
                            color: AppColors.primaryDark,
                          ),
                          MentorMetricCard(
                            icon: Icons.category_outlined,
                            value: '${controller.userLayanan.length}',
                            label: 'Layanan aktif',
                            color: AppColors.yellow2Color,
                          ),
                        ]),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: mentorMetricColumnCount(
                            viewport.maxWidth,
                          ),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 142,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
                      sliver: const SliverToBoxAdapter(
                        child: _SectionTitle(
                          title: 'Akses cepat',
                          subtitle:
                              'Lanjutkan pekerjaan yang paling sering digunakan.',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _QuickAction(
                              title: 'Buka percakapan',
                              subtitle:
                                  'Tanggapi pengguna yang sedang dibimbing.',
                              icon: Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                              onTap: () => dashboard.changeTab(1),
                            ),
                            _QuickAction(
                              title: 'Kuesioner',
                              subtitle:
                                  'Pantau aktivitas dan feedback kuesioner.',
                              icon: Icons.assignment_outlined,
                              color: AppColors.greenColor,
                              onTap: () => dashboard.changeTab(2),
                            ),
                            _QuickAction(
                              title: 'Profil mentor',
                              subtitle:
                                  'Kelola layanan, saldo, dan informasi akun.',
                              icon: Icons.person_outline_rounded,
                              color: AppColors.primaryDark,
                              onTap: () => dashboard.changeTab(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const Expanded(
                              child: _SectionTitle(
                                title: 'Order aktif terbaru',
                                subtitle:
                                    'Pengguna yang sedang membutuhkan pendampingan.',
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Muat ulang order',
                              onPressed: controller.isLoadingOrders.value
                                  ? null
                                  : controller.fetchMentorOrders,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.isLoadingOrders.value)
                      const SliverPadding(
                        padding: EdgeInsets.all(32),
                        sliver: SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (controller.mentorOrders.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 40),
                        sliver: const SliverToBoxAdapter(child: _EmptyOrders()),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 40),
                        sliver: SliverList.separated(
                          itemCount: controller.mentorOrders.take(4).length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => _MentorOrderTile(
                            order: controller.mentorOrders[index],
                            onOpenChat: () => dashboard.changeTab(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static String _specializationLabel(String value) {
    switch (value.toLowerCase()) {
      case 'complink':
        return 'Mentor Cermat Competition';
      case 'paperlink':
        return 'Mentor Cermat Paper';
      default:
        return 'Mentor Cermatify';
    }
  }

  static String _formatCurrency(int value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    }
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)} rb';
    return 'Rp $value';
  }
}

class MentorWelcomeHeader extends StatelessWidget {
  const MentorWelcomeHeader({
    super.key,
    required this.name,
    required this.specialization,
  });
  final String name;
  final String specialization;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 22 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.lightPrimaryColor.withValues(alpha: 0.34),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.lightPrimaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'MENTOR WORKSPACE',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selamat datang, $name',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: compact ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Kelola pendampingan dan komunikasi pengguna dari satu dashboard.',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: compact ? 12 : 13,
                  height: 1.5,
                ),
              ),
            ],
          );
          final status = Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.greenColor,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    specialization,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _style(11, FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 18), status],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              status,
            ],
          );
        },
      ),
    );
  }
}

class MentorMetricCard extends StatelessWidget {
  const MentorMetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _style(20, FontWeight.w800),
          ),
          Text(
            label,
            style: _style(10, FontWeight.w500, AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width >= 1100
          ? 360
          : width >= 700
          ? 320
          : double.infinity,
      child: Material(
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
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: _style(13, FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _style(
                          10,
                          FontWeight.w400,
                          AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MentorOrderTile extends StatelessWidget {
  const _MentorOrderTile({required this.order, required this.onOpenChat});
  final Map<String, dynamic> order;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final createdAt = order['createdAt'];
    final date = createdAt is Timestamp
        ? DateFormat('dd/MM/yyyy').format(createdAt.toDate())
        : 'Tanggal tidak tersedia';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.greenColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.greenColor,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customerName']?.toString() ?? 'Pengguna',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _style(13, FontWeight.w700),
                ),
                Text(
                  '${order['layananName'] ?? 'Layanan pendampingan'} • $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _style(10, FontWeight.w400, AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Buka percakapan',
            onPressed: onOpenChat,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.work_history_outlined,
            color: AppColors.textLight,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text('Belum ada order aktif', style: _style(14, FontWeight.w700)),
          const SizedBox(height: 3),
          Text(
            'Order yang sedang diproses akan tampil di sini.',
            textAlign: TextAlign.center,
            style: _style(11, FontWeight.w400, AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _style(18, FontWeight.w700)),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: _style(11, FontWeight.w400, AppColors.textSecondary),
        ),
      ],
    );
  }
}

TextStyle _style(double size, FontWeight weight, [Color? color]) =>
    GoogleFonts.poppins(
      color: color ?? AppColors.textPrimary,
      fontSize: size,
      fontWeight: weight,
    );
