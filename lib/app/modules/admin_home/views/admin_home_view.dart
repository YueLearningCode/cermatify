import 'package:cermatify/app/data/layout/app_breakpoints.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:cermatify/app/modules/admin_kuesioner/bindings/admin_kuesioner_binding.dart';
import 'package:cermatify/app/modules/admin_kuesioner/views/admin_kuesioner_view.dart';
import 'package:cermatify/app/modules/admin_orders/bindings/admin_orders_binding.dart';
import 'package:cermatify/app/modules/admin_orders/views/admin_orders_view.dart';
import 'package:cermatify/app/modules/admin_withdraw/bindings/admin_withdraw_binding.dart';
import 'package:cermatify/app/modules/admin_withdraw/views/admin_withdraw_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/admin_home_controller.dart';

int adminStatisticColumnCount(double width) {
  if (width >= 1040) return 4;
  if (width >= 560) return 2;
  if (width >= 320) return 2;
  return 1;
}

int adminActionColumnCount(double width) {
  if (width >= 1040) return 3;
  if (width >= 620) return 2;
  return 1;
}

double adminStatisticCardExtent(double width) => width < 560 ? 132 : 148;

double adminActionCardExtent(double width) => width < 620 ? 120 : 154;

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, viewport) {
                  final horizontalPadding = viewport.maxWidth >= 1024
                      ? 32.0
                      : viewport.maxWidth >= 600
                      ? 24.0
                      : 16.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      28,
                      horizontalPadding,
                      viewport.maxWidth < AppBreakpoints.mobile ? 112 : 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(viewport.maxWidth),
                            SizedBox(height: viewport.maxWidth < 600 ? 26 : 32),
                            const _SectionHeading(
                              title: 'Ringkasan aktivitas',
                              subtitle:
                                  'Pantau kondisi akun dan data utama Cermatify.',
                            ),
                            const SizedBox(height: 16),
                            _buildStatistics(),
                            SizedBox(height: viewport.maxWidth < 600 ? 30 : 36),
                            const _SectionHeading(
                              title: 'Akses cepat',
                              subtitle:
                                  'Kelola area administrasi yang paling sering digunakan.',
                            ),
                            const SizedBox(height: 16),
                            _buildQuickActions(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildWelcomeHeader(double viewportWidth) {
    final compact = viewportWidth < AppBreakpoints.mobile;
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.18),
            ),
          ),
          child: CircleAvatar(
            radius: compact ? 22 : 25,
            backgroundColor: AppColors.surface,
            backgroundImage: controller.userImage.value.isNotEmpty
                ? NetworkImage(controller.userImage.value) as ImageProvider
                : const AssetImage('assets/images/profile_dummy.jpg'),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_done_rounded,
                size: 16,
                color: AppColors.greenColor,
              ),
              SizedBox(width: 7),
              Text(
                'Sistem online',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 20 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.12),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primaryColor.withValues(alpha: 0.07),
          ],
        ),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCopy(compact: true),
                const SizedBox(height: 18),
                identity,
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildWelcomeCopy(compact: false)),
                const SizedBox(width: 24),
                identity,
              ],
            ),
    );
  }

  Widget _buildWelcomeCopy({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.checkoutButtonColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ADMIN WORKSPACE',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Selamat datang, ${controller.userName.value}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: compact ? 22 : 30,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola pengguna, transaksi, dan layanan Cermatify dari satu dashboard.',
          style: GoogleFonts.poppins(
            fontSize: compact ? 12.5 : 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final items = [
      AdminDashboardStatCard(
        title: 'Jumlah pengguna',
        value: controller.totalUsers.value.toString(),
        icon: Icons.people_alt_outlined,
        color: AppColors.primaryColor,
      ),
      AdminDashboardStatCard(
        title: 'Master data',
        value: controller.totalMasterData.value.toString(),
        icon: Icons.dataset_outlined,
        color: AppColors.greenColor,
      ),
      const AdminDashboardStatCard(
        title: 'Status layanan',
        value: '100%',
        icon: Icons.verified_outlined,
        color: AppColors.greenColor,
      ),
      const AdminDashboardStatCard(
        title: 'Kondisi sistem',
        value: 'Online',
        icon: Icons.cloud_done_outlined,
        color: AppColors.primaryColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = adminStatisticColumnCount(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: adminStatisticCardExtent(constraints.maxWidth),
          ),
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _AdminAction(
        title: 'Kelola pengguna',
        subtitle: 'Lihat, verifikasi, dan perbarui akun.',
        icon: Icons.manage_accounts_outlined,
        color: AppColors.primaryColor,
        onTap: () {
          if (Get.isRegistered<AdminDashboardController>()) {
            Get.find<AdminDashboardController>().changeTab(1);
          }
        },
      ),
      _AdminAction(
        title: 'Master data',
        subtitle: 'Kelola kategori dan data referensi.',
        icon: Icons.storage_outlined,
        color: AppColors.greenColor,
        onTap: () {
          if (Get.isRegistered<AdminDashboardController>()) {
            Get.find<AdminDashboardController>().changeTab(2);
          }
        },
      ),
      _AdminAction(
        title: 'Orders',
        subtitle: 'Periksa dan kelola seluruh pesanan.',
        icon: Icons.shopping_bag_outlined,
        color: AppColors.orangeColor,
        onTap: () => Get.to(
          () => const AdminOrdersView(),
          binding: AdminOrdersBinding(),
        ),
      ),
      _AdminAction(
        title: 'Withdraw',
        subtitle: 'Tinjau permintaan pencairan dana.',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.primaryDark,
        onTap: () => Get.to(
          () => const AdminWithdrawView(),
          binding: AdminWithdrawBinding(),
        ),
      ),
      _AdminAction(
        title: 'Kuesioner',
        subtitle: 'Pantau dan kelola layanan kuesioner.',
        icon: Icons.assignment_outlined,
        color: AppColors.yellow2Color,
        onTap: () => Get.to(
          () => const AdminKuesionerView(),
          binding: AdminKuesionerBinding(),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = adminActionColumnCount(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: adminActionCardExtent(constraints.maxWidth),
          ),
          itemBuilder: (context, index) => actions[index],
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class AdminDashboardStatCard extends StatelessWidget {
  const AdminDashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 190;
        final valueStyle = GoogleFonts.poppins(
          fontSize: compact ? 21 : 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        );
        final titleStyle = GoogleFonts.poppins(
          fontSize: compact ? 10 : 11,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        );

        return Container(
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 7 : 9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: compact ? 18 : 21),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({
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
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: color.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, size: 20, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
