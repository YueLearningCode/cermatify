import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_layout.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cermatify/app/modules/landing/widgets/review_preview_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const double _landingMaxWidth = 1180;
const double _compactBreakpoint = 360;
const String _heroHeadline =
    'Karya ilmiah, kompetisi, dan riset lebih terarah.';
const String _heroDescription =
    'Temukan pendampingan karya ilmiah dan persiapan kompetisi, serta ajukan kebutuhan responden penelitian melalui Cermatify. Pilih layanan yang sesuai dengan kebutuhanmu dan pahami prosesnya sebelum memulai.';

bool _isCompact(BuildContext context) {
  return MediaQuery.sizeOf(context).width < _compactBreakpoint;
}

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final _scrollController = ScrollController();
  final _servicesKey = GlobalKey();

  void _showServices() {
    final target = _servicesKey.currentContext?.findRenderObject();
    if (target == null || !_scrollController.hasClients) return;

    final offset =
        RenderAbstractViewport.of(target).getOffsetToReveal(target, 0).offset -
        88;
    final destination = offset
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();
    if (MediaQuery.of(context).disableAnimations) {
      _scrollController.jumpTo(destination);
    } else {
      _scrollController.animateTo(
        destination,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _LandingHeaderDelegate(),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _landingMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LandingIntro(onShowServices: _showServices),
                        const SizedBox(height: 72),
                        _SectionHeader(
                          key: _servicesKey,
                          title: 'Pilih layanan sesuai kebutuhanmu',
                          subtitle:
                              'Pendampingan karya ilmiah, persiapan kompetisi, dan kebutuhan responden penelitian dalam satu aplikasi.',
                        ),
                        const SizedBox(height: 16),
                        const _FeatureGrid(),
                        const SizedBox(height: 72),
                        _SectionHeader(
                          title: 'Cara Kerja Cermatify',
                          subtitle:
                              'Alurnya dibuat sederhana agar pengguna bisa langsung mulai tanpa kebingungan.',
                        ),
                        const SizedBox(height: 16),
                        const _HowItWorks(),
                        const ReviewPreviewSection(),
                        const SizedBox(height: 72),
                        const _FinalCta(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final compact = _isCompact(context);
    final logoSize = compact ? 38.0 : 42.0;

    return SizedBox.expand(
      child: ColoredBox(
        color: AppColors.background.withValues(alpha: 0.96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _landingMaxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cermatify',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black414,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.LOGIN),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _LandingHeaderDelegate oldDelegate) => false;
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onShowServices});

  final VoidCallback onShowServices;

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.whiteColor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Image.asset(
                      'assets/images/banner1.jpg',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      semanticLabel: 'Ilustrasi pendampingan akademik',
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.whiteColor.withValues(alpha: 0),
                          AppColors.primaryColor.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 16 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Pill(label: 'Pendampingan akademik untuk mahasiswa'),
                const SizedBox(height: 14),
                Text(
                  _heroHeadline,
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.w900,
                    height: 1.14,
                    color: AppColors.black414,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _heroDescription,
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 13 : 14,
                    height: 1.65,
                    color: AppColors.greyTextSecondaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onShowServices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.whiteColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Lihat Layanan',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.LOGIN),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingIntro extends StatelessWidget {
  const _LandingIntro({required this.onShowServices});

  final VoidCallback onShowServices;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: (context, constraints) => Column(
        children: [
          _HeroSection(onShowServices: onShowServices),
          const SizedBox(height: 24),
          const _TrustBar(),
          const SizedBox(height: 28),
          const _VisualShowcase(),
        ],
      ),
      desktop: (context, constraints) => Column(
        children: [
          _DesktopHeroSection(onShowServices: onShowServices),
          const SizedBox(height: 28),
          const _TrustBar(),
        ],
      ),
    );
  }
}

class _DesktopHeroSection extends StatelessWidget {
  const _DesktopHeroSection({required this.onShowServices});

  final VoidCallback onShowServices;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primaryColor.withValues(alpha: 0.08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 52, 30, 52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Pill(label: 'Pendampingan akademik untuk mahasiswa'),
                  const SizedBox(height: 24),
                  Text(
                    _heroHeadline,
                    style: GoogleFonts.poppins(
                      fontSize: 44,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black414,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _heroDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.7,
                      color: AppColors.greyTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onShowServices,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Lihat Layanan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.whiteColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.toNamed(Routes.LOGIN),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Masuk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 26, 28, 26),
              child: Container(
                height: 380,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: .82),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: .92),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/images/banner1.jpg',
                          fit: BoxFit.contain,
                          semanticLabel: 'Ilustrasi pendampingan akademik',
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: .96),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(
                              alpha: .08,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: AppColors.primaryColor,
                              size: 21,
                            ),
                            SizedBox(width: 8),
                            Text('Pendampingan akademik'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBar extends StatelessWidget {
  const _TrustBar();

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 520 ? 2 : 3;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                value: '3',
                label: 'Layanan inti',
                compact: compact,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                value: '24/7',
                label: 'Akses web',
                compact: compact,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                value: '1',
                label: 'Aplikasi terpadu',
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VisualShowcase extends StatelessWidget {
  const _VisualShowcase();

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: compact ? 16 / 10 : 16 / 8.8,
              child: Image.asset(
                'assets/images/banner2.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pendamping akademik dalam genggaman',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.black414,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Konsultasi, pemetaan kebutuhan, dan layanan pendukung dibuat ringkas agar nyaman dipakai dari ponsel.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.55,
              color: AppColors.greyTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(icon: Icons.verified_user_outlined, label: 'Mentor'),
              _MiniBadge(icon: Icons.fact_check_outlined, label: 'Kuesioner'),
              _MiniBadge(icon: Icons.chat_bubble_outline, label: 'Konsultasi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FeatureTile(
        icon: Icons.school_outlined,
        title: 'Cermat Paper',
        benefit: 'Temukan arah untuk karya ilmiahmu',
        description:
            'Konsultasikan kebutuhan penelitian dan penulisan dengan mentor sesuai bidang. Dapatkan arahan serta masukan untuk mengembangkan karyamu sendiri.',
        color: AppColors.primaryLight,
      ),
      _FeatureTile(
        icon: Icons.emoji_events_outlined,
        title: 'Cermat Competition',
        benefit: 'Siapkan ide dan strategi kompetisimu',
        description:
            'Pilih pendampingan sesuai kategori kompetisi untuk mendiskusikan ide, pengembangan karya, dan persiapan partisipasimu.',
        color: AppColors.primary,
      ),
      _FeatureTile(
        icon: Icons.groups_2_outlined,
        title: 'Cermat Kuesioner',
        benefit: 'Ajukan kebutuhan responden penelitian',
        description:
            'Masukkan tautan kuesioner dan kriteria responden untuk ditinjau tim Cermatify sebelum ditampilkan pada layanan kuesioner.',
        color: AppColors.primaryDark,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 900 ? 3 : 1;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items) SizedBox(width: width, child: item),
          ],
        );
      },
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const items = [
      _StepTile(
        number: '1',
        title: 'Daftar Akun',
        description: 'Pilih peran pengguna dan lengkapi data dasar.',
      ),
      _StepTile(
        number: '2',
        title: 'Pilih Layanan',
        description: 'Masuk ke fitur yang sesuai dengan kebutuhanmu.',
      ),
      _StepTile(
        number: '3',
        title: 'Mulai Proses',
        description: 'Ikuti alur aplikasi sampai kebutuhan akademik selesai.',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 1;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items) SizedBox(width: width, child: item),
          ],
        );
      },
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta();

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Siap mulai lebih cermat?',
          style: GoogleFonts.poppins(
            fontSize: compact ? 20 : 28,
            fontWeight: FontWeight.w900,
            color: AppColors.whiteColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Masuk atau daftar untuk menggunakan seluruh layanan Cermatify.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.55,
            color: AppColors.whiteColor.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
    final action = ElevatedButton(
      onPressed: () => Get.toNamed(Routes.REGISTER),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        'Daftar Gratis',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(constraints.maxWidth >= 700 ? 40 : 20),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.24),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: constraints.maxWidth >= 700
            ? Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 32),
                  action,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [copy, const SizedBox(height: 20), action],
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: compact ? 19 : 21,
            fontWeight: FontWeight.w900,
            height: 1.24,
            color: AppColors.black414,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.58,
            color: AppColors.greyTextSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.checkoutButtonColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.checkoutButtonColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.compact,
  });

  final String value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 86),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: compact ? 18 : 19,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: compact ? 9.5 : 10,
                fontWeight: FontWeight.w600,
                color: AppColors.greyTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.benefit,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String benefit;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            benefit,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black414,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.greyTextSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
