import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const double _mobileMaxWidth = 430;
const double _compactBreakpoint = 360;

bool _isCompact(BuildContext context) {
  return MediaQuery.sizeOf(context).width < _compactBreakpoint;
}

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _mobileMaxWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = 16.0;

                return CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _LandingHeaderDelegate(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          18,
                          horizontalPadding,
                          32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _HeroSection(),
                            const SizedBox(height: 24),
                            const _TrustBar(),
                            const SizedBox(height: 28),
                            const _VisualShowcase(),
                            const SizedBox(height: 30),
                            _SectionHeader(
                              title: 'Solusi Cermat untuk Kebutuhan Akademik',
                              subtitle:
                                  'Mulai dari konsultasi mentor, kuesioner, sampai bantuan riset dalam satu aplikasi.',
                            ),
                            const SizedBox(height: 16),
                            const _FeatureGrid(),
                            const SizedBox(height: 30),
                            _SectionHeader(
                              title: 'Cara Kerja Cermatify',
                              subtitle:
                                  'Alurnya dibuat sederhana agar pengguna bisa langsung mulai tanpa kebingungan.',
                            ),
                            const SizedBox(height: 16),
                            const _HowItWorks(),
                            const SizedBox(height: 30),
                            _SectionHeader(
                              title: 'Cerita Pengguna',
                              subtitle:
                                  'Beberapa alasan Cermatify jadi teman belajar yang praktis.',
                            ),
                            const SizedBox(height: 16),
                            const _Testimonials(),
                            const SizedBox(height: 30),
                            const _FinalCta(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  @override
  bool shouldRebuild(covariant _LandingHeaderDelegate oldDelegate) => false;
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

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
                Text(
                  'Belajar, riset, dan konsultasi jadi lebih terarah.',
                  style: GoogleFonts.poppins(
                    color: AppColors.black414,
                    fontSize: compact ? 18 : 20,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                _Pill(label: 'Platform pendamping akademik'),
                const SizedBox(height: 14),
                Text(
                  'Selamat Datang di Cermatify',
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.w900,
                    height: 1.14,
                    color: AppColors.black414,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Temukan mentor, kelola kebutuhan kuesioner, dan akses layanan pendukung akademik dengan pengalaman yang nyaman dari ponsel.',
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
                    onPressed: () => Get.toNamed(Routes.REGISTER),
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
                      'Mulai Sekarang',
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
                      'Saya Sudah Punya Akun',
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

class _TrustBar extends StatelessWidget {
  const _TrustBar();

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatCard(value: '3+', label: 'Layanan inti', compact: compact),
        _StatCard(value: '24/7', label: 'Akses web', compact: compact),
        _StatCard(value: '1', label: 'Aplikasi', compact: compact),
      ],
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
    return Column(
      children: const [
        _FeatureTile(
          icon: Icons.school_outlined,
          title: 'Paperlink',
          description: 'Cari mentor dan dukungan untuk kebutuhan akademik.',
          color: AppColors.primaryLight,
        ),
        SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.assignment_outlined,
          title: 'Kuesioner',
          description:
              'Buat dan kelola kebutuhan data responden dengan lebih rapi.',
          color: AppColors.primary,
        ),
        SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.groups_2_outlined,
          title: 'Sourcelink',
          description:
              'Temukan sumber dan komunitas pendukung dalam satu tempat.',
          color: AppColors.primaryDark,
        ),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
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
      ],
    );
  }
}

class _Testimonials extends StatelessWidget {
  const _Testimonials();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _QuoteCard(
          quote:
              'Cermatify membantu saya menemukan arahan riset tanpa harus bolak-balik tanya secara manual.',
          name: 'Mahasiswa',
          role: 'Pengguna Cermatify',
        ),
        SizedBox(height: 12),
        _QuoteCard(
          quote:
              'Alur layanan terasa praktis dan cocok dibuka dari ponsel saat sedang mengerjakan tugas.',
          name: 'Mentor',
          role: 'Pendamping Akademik',
        ),
      ],
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta();

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siap mulai lebih cermat?',
            style: GoogleFonts.poppins(
              fontSize: compact ? 20 : 22,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(Routes.REGISTER),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whiteColor,
                foregroundColor: AppColors.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Daftar Gratis',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

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
    final screenWidth = MediaQuery.sizeOf(
      context,
    ).width.clamp(320.0, _mobileMaxWidth).toDouble();
    final availableWidth = screenWidth - (compact ? 32 : 40);
    final cardWidth = compact
        ? (availableWidth - 10) / 2
        : (availableWidth - 20) / 3;

    return SizedBox(
      width: cardWidth,
      height: 86,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
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
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.9), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.surface),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.surface.withValues(alpha: 0.82),
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

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.name,
    required this.role,
  });

  final String quote;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.62,
              color: AppColors.blackF45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.checkoutButtonColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black414,
                      ),
                    ),
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.greyTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
