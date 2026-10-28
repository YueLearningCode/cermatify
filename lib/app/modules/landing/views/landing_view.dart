import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_layout.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cermatify/app/modules/landing/widgets/review_preview_section.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_navigation.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_faq.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_cta.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const double _landingMaxWidth = 1180;
const double _compactBreakpoint = 360;
const double _landingHeaderHeight = 72;
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
  final _howItWorksKey = GlobalKey();
  final _faqKey = GlobalKey();
  LandingNavTarget _activeTarget = LandingNavTarget.home;
  bool _activeUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scheduleActiveTargetUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleActiveTargetUpdate();
  }

  void _scheduleActiveTargetUpdate() {
    if (_activeUpdateScheduled) return;
    _activeUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activeUpdateScheduled = false;
      if (mounted) _updateActiveTarget();
    });
  }

  void _updateActiveTarget() {
    if (!mounted || !_scrollController.hasClients) return;
    var active = LandingNavTarget.home;
    final top = MediaQuery.paddingOf(context).top + _landingHeaderHeight + 24;
    final anchors = {
      LandingNavTarget.services: _servicesKey,
      LandingNavTarget.howItWorks: _howItWorksKey,
      LandingNavTarget.faq: _faqKey,
    };
    for (final anchor in anchors.entries) {
      final box = anchor.value.currentContext?.findRenderObject();
      if (box is RenderBox &&
          box.hasSize &&
          box.localToGlobal(Offset.zero).dy <= top) {
        active = anchor.key;
      }
    }
    final position = _scrollController.position;
    final faq = _faqKey.currentContext?.findRenderObject();
    if (position.pixels > 0 &&
        position.extentAfter < 1 &&
        faq is RenderBox &&
        faq.hasSize &&
        faq.localToGlobal(Offset.zero).dy < MediaQuery.sizeOf(context).height) {
      active = LandingNavTarget.faq;
    }
    if (active != _activeTarget) setState(() => _activeTarget = active);
  }

  void _navigate(LandingNavTarget target) {
    switch (target) {
      case LandingNavTarget.home:
        _scrollToOffset(0);
      case LandingNavTarget.services:
        _showServices();
      case LandingNavTarget.howItWorks:
        _showSection(_howItWorksKey);
      case LandingNavTarget.faq:
        _showSection(_faqKey);
      case LandingNavTarget.mentor:
        Get.toNamed(Routes.REGISTER, arguments: 'mentor');
      case LandingNavTarget.login:
        Get.toNamed(Routes.LOGIN);
      case LandingNavTarget.register:
        Get.toNamed(Routes.REGISTER);
    }
  }

  void _showServices() => _showSection(_servicesKey);

  void _showSection(GlobalKey key) {
    final target = key.currentContext?.findRenderObject();
    if (target == null || !_scrollController.hasClients) return;

    // The viewport already accounts for the pinned header when revealing a box.
    final offset =
        RenderAbstractViewport.of(target).getOffsetToReveal(target, 0).offset -
        16;
    _scrollToOffset(offset);
  }

  void _scrollToOffset(double offset) {
    if (!_scrollController.hasClients) return;
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
    _scrollController.removeListener(_scheduleActiveTargetUpdate);
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
              delegate: _LandingHeaderDelegate(
                activeTarget: _activeTarget,
                onSelected: _navigate,
              ),
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
                          textAlign: TextAlign.start,
                          title: 'Pilih layanan sesuai kebutuhanmu',
                          subtitle:
                              'Kenali langkah awal menggunakan layanan Cermatify.',
                        ),
                        const SizedBox(height: 16),
                        const _FeatureGrid(),
                        // EDIT CARA KERJA — jarak dari bagian layanan di atas.
                        const SizedBox(height: 72),
                        // EDIT CARA KERJA — judul dan subjudul bagian ini.
                        // Style teksnya ada di _SectionHeader (dipakai juga oleh bagian lain).
                        _SectionHeader(
                          key: _howItWorksKey,
                          textAlign: TextAlign.start,
                          title: 'Cara Kerja Cermatify',
                          subtitle:
                              'Alurnya dibuat sederhana agar pengguna bisa langsung mulai tanpa kebingungan.',
                        ),
                        const SizedBox(height: 16),
                        const _HowItWorks(),
                        const ReviewPreviewSection(),
                        const SizedBox(height: 72),
                        _SectionHeader(
                          key: _faqKey,
                          title: 'Pertanyaan yang sering diajukan',
                          subtitle:
                              'Kenali layanan dan langkah awal menggunakan Cermatify.',
                        ),
                        const SizedBox(height: 16),
                        const LandingFaq(),
                        const SizedBox(height: 72),
                        LandingCta(onSelected: _navigate),
                        const SizedBox(height: 56),
                        LandingFooter(onSelected: _navigate),
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
  _LandingHeaderDelegate({
    required this.activeTarget,
    required this.onSelected,
  });

  final LandingNavTarget activeTarget;
  final ValueChanged<LandingNavTarget> onSelected;

  @override
  double get minExtent => _landingHeaderHeight;

  @override
  double get maxExtent => _landingHeaderHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return LandingNavigation(
      activeTarget: activeTarget,
      onSelected: onSelected,
    );
  }

  @override
  bool shouldRebuild(covariant _LandingHeaderDelegate oldDelegate) =>
      activeTarget != oldDelegate.activeTarget ||
      onSelected != oldDelegate.onSelected;
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
        title: 'Tentukan kebutuhanmu',
        description:
            'Pilih pendampingan karya ilmiah, persiapan kompetisi, atau kebutuhan responden penilitian.',
      ),
      _StepTile(
        number: '3',
        title: 'Ajukan Layanan',
        description:
            'Pilih mentor yang sesuai atau kirim tautan kuisioner beserta kriteria responden.',
      ),
      _StepTile(
        number: '4',
        title: 'Tinjau dan Lanjutkan',
        description:
            'Ikuti petunjuk pembayaran dan tunggu konfirmasi dari mentor atau tim Cermatify. ENJOY!',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 1;
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.start,
  });

  final String title;
  final String subtitle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    // EDIT ALIGNMENT — judul bagian memakai lebar penuh agar bisa rata tengah.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: GoogleFonts.poppins(
            // EDIT CARA KERJA — ukuran judul bagian: layar kecil / layar besar.
            fontSize: compact ? 19 : 21,
            fontWeight: FontWeight.w900,
            height: 1.24,
            color: AppColors.black414,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: textAlign,
          style: GoogleFonts.poppins(
            // EDIT CARA KERJA — ukuran subjudul dan jarak antar barisnya.
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
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
              ),
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
        // EDIT LAYANAN — posisi ikon dan seluruh isi kartu.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            benefit,
            textAlign: TextAlign.center,
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
            textAlign: TextAlign.center,
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

// EDIT CARA KERJA — STYLE SATU LANGKAH (berlaku untuk semua nomor).
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
      // EDIT CARA KERJA — jarak bawah setiap langkah.
      padding: const EdgeInsets.only(bottom: 12),
      // EDIT CARA KERJA — Column menempatkan nomor di atas teks.
      child: Column(
        // EDIT CARA KERJA — posisi lingkaran nomor di tengah kolom.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // EDIT CARA KERJA — ukuran lingkaran nomor.
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // EDIT CARA KERJA — warna latar lingkaran.
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              // EDIT CARA KERJA — font, warna dan ketebalan angka.
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // EDIT CARA KERJA — jarak vertikal nomor ke judul.
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            // EDIT CARA KERJA — jarak teks ke garis bawah, lalu style garis.
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  // EDIT CARA KERJA — fontSize, fontWeight dan color judul langkah.
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black414,
                  ),
                ),
                // EDIT CARA KERJA — jarak judul langkah ke deskripsi.
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  // EDIT CARA KERJA — fontSize, height (jarak baris) dan color deskripsi.
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.greyTextSecondaryColor,
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
