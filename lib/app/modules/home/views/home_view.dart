import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/modules/home/controllers/home_controller.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.background,
    body: HomeContent(),
  );
}

class HomeContent extends GetView<HomeController> {
  const HomeContent({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, viewport) {
      final compact = viewport.maxWidth < 600;
      return RefreshIndicator(
        onRefresh: controller.refreshUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 28,
            compact ? 18 : 28,
            compact ? 16 : 28,
            compact ? 112 : 44,
          ),
          child: ResponsiveContent(
            maxWidth: 1200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => _WelcomeHeader(
                    name: controller.userName.value,
                    imageUrl: controller.userImage.value,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Mulai dari sini',
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 19 : 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pilih layanan yang sesuai dengan kebutuhan belajarmu.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                const _ActionGrid(),
                const SizedBox(height: 26),
                const _SupportBanner(),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name, required this.imageUrl});
  final String name;
  final String imageUrl;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 680;
      final avatar = CircleAvatar(
        radius: compact ? 31 : 36,
        backgroundColor: AppColors.surface,
        backgroundImage: imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : const AssetImage('assets/images/profile_dummy.jpg')
                  as ImageProvider,
      );
      final copy = Column(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'STUDENT WORKSPACE',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Selamat datang, $name',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: compact ? 22 : 28,
              height: 1.18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Temukan mentor, kelola pendampingan, dan pantau pesananmu.',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: compact ? 11 : 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 22 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withValues(alpha: .07),
              AppColors.lightPrimaryColor.withValues(alpha: .32),
            ],
          ),
          borderRadius: BorderRadius.circular(compact ? 24 : 28),
          border: Border.all(
            color: AppColors.lightPrimaryColor.withValues(alpha: .36),
          ),
        ),
        child: compact
            ? Column(children: [avatar, const SizedBox(height: 16), copy])
            : Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 28),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: avatar,
                  ),
                ],
              ),
      );
    },
  );
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();
  static const actions = [
    _Action(
      'Cermat Paper',
      'Bimbingan penyusunan paper',
      Icons.description_outlined,
      Routes.PAPERLINK,
    ),
    _Action(
      'Cermat Competition',
      'Kompetisi dan beasiswa',
      Icons.school_outlined,
      Routes.COMPLINK,
    ),
    _Action(
      'Cermat Kuesioner',
      'Publikasi kebutuhan responden',
      Icons.assignment_outlined,
      Routes.SOURCELINK,
    ),
    _Action(
      'Riwayat pesanan',
      'Pantau seluruh transaksimu',
      Icons.shopping_bag_outlined,
      Routes.ORDER_HISTORY,
    ),
  ];
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 960
          ? 4
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      const gap = 14.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: actions
            .map(
              (action) => SizedBox(
                width: width,
                height: 154,
                child: _ActionCard(action: action),
              ),
            )
            .toList(),
      );
    },
  );
}

class _Action {
  const _Action(this.title, this.subtitle, this.icon, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _Action action;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: () => Get.toNamed(action.route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: AppColors.primaryColor),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        action.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryColor,
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

class _SupportBanner extends StatelessWidget {
  const _SupportBanner();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
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
            color: AppColors.primaryColor.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.forum_outlined,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Butuh bantuan?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Buka menu Chat untuk melanjutkan diskusi dengan mentor.',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
