import 'package:cermatify/app/data/content/help_content.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/link.dart';

/// Recruitment information uses the existing blue auth palette and assets.
class MentorRecruitmentPanel extends StatelessWidget {
  const MentorRecruitmentPanel({super.key, this.compact = false});
  final bool compact;

  static const benefits = [
    (
      Icons.auto_awesome_outlined,
      'Beri dampak lewat keahlianmu',
      'Bantu mahasiswa memahami konsep, mengembangkan karya, dan mempersiapkan kompetisi.',
    ),
    (
      Icons.workspace_premium_outlined,
      'Bangun pengalaman membimbing',
      'Perkuat cara menjelaskan, memberi masukan, dan mendampingi kebutuhan akademik yang beragam.',
    ),
    (
      Icons.payments_outlined,
      'Peluang pendapatan dari mentoring',
      'Tawarkan pendampingan berbayar sesuai bidang dan ketentuan layanan. Jumlah sesi dan pendapatan tidak dijamin.',
    ),
  ];

  static const requirements = [
    (
      'Berusia 18 tahun atau lebih',
      'Pendaftaran rilis pertama tersedia untuk pengguna dewasa.',
    ),
    (
      'Kompeten di bidang yang dipilih',
      'Siapkan pengalaman atau karya relevan. Semester 5 menjadi acuan bagi mahasiswa, bukan syarat mutlak.',
    ),
    (
      'Profil yang dapat ditinjau',
      'Lengkapi bidang layanan dan LinkedIn. Siapkan minimal satu bukti kompetensi: karya, portofolio, publikasi, sertifikat, atau pengalaman.',
    ),
    (
      'Bersedia mengikuti seleksi',
      'Peninjauan profil dan interview menilai penguasaan bidang, cara menjelaskan, komunikasi, dan integritas akademik.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final benefitContent = Column(
      children: [
        for (final item in benefits)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _InformationRow(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            ),
          ),
      ],
    );
    final requirementContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in requirements)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InformationRow(
              icon: Icons.check_rounded,
              title: item.$1,
              description: item.$2,
              small: true,
            ),
          ),
        _IntegrityNote(),
        const SizedBox(height: 12),
        Text(
          'Lulusan, pengajar, atau praktisi? Hubungi tim untuk arahan jika formulir belum sesuai dengan latar belakangmu.',
          style: _body(12),
        ),
        Link(
          uri: Uri(
            scheme: 'mailto',
            path: HelpContent.supportEmail,
            queryParameters: {
              'subject': 'Informasi pendaftaran mentor Cermatify',
            },
          ),
          builder: (context, followLink) => TextButton.icon(
            onPressed: followLink,
            icon: const Icon(Icons.mail_outline_rounded, size: 18),
            label: const Text('Tanya tim Cermatify'),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.primaryDark,
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
      ],
    );

    return Container(
      key: ValueKey(compact ? 'mentor-intro-mobile' : 'mentor-intro-desktop'),
      padding: EdgeInsets.all(compact ? 20 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 24 : 32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primaryColor.withValues(alpha: .10),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: .14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: .07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.border),
                ),
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cermatify',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.checkoutButtonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'RUANG UNTUK BERBAGI ILMU',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Keahlianmu berarti.\nBantu langkah mereka.',
            style: GoogleFonts.poppins(
              fontSize: compact ? 25 : 32,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jadilah teman diskusi yang membantu mahasiswa tumbuh melalui Cermat Paper dan Cermat Competition.',
            style: _body(14),
          ),
          if (!compact) ...[
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 174,
                child: ColoredBox(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/banner2.jpg',
                    fit: BoxFit.contain,
                    semanticLabel: 'Ilustrasi kolaborasi mentor dan mahasiswa',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            _PanelHeading(title: 'Mengapa menjadi mentor?'),
            const SizedBox(height: 18),
            benefitContent,
            const Divider(height: 28, color: AppColors.border),
            _PanelHeading(title: 'Yang perlu kamu siapkan'),
            const SizedBox(height: 18),
            requirementContent,
          ] else ...[
            const SizedBox(height: 18),
            _CompactInformation(
              title: 'Manfaat menjadi mentor',
              icon: Icons.auto_awesome_outlined,
              content: benefitContent,
            ),
            const SizedBox(height: 8),
            _CompactInformation(
              title: 'Persyaratan & seleksi',
              icon: Icons.fact_check_outlined,
              content: requirementContent,
            ),
          ],
        ],
      ),
    );
  }
}

class MentorRegistrationFormSurface extends StatelessWidget {
  const MentorRegistrationFormSurface({
    super.key,
    required this.enabled,
    required this.child,
  });
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => !enabled
      ? child
      : Container(
          key: const ValueKey('mentor-registration-form'),
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 28,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: .04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        );
}

class MentorSubmissionButton extends StatelessWidget {
  const MentorSubmissionButton({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: isLoading ? null : onSubmit,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.surface,
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(
        isLoading ? 'Memproses...' : 'Kirim pengajuan mentor',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class MentorRegistrationHeader extends StatelessWidget {
  const MentorRegistrationHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'MULAI PERJALANANMU',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
          color: AppColors.primaryDark,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Daftar sebagai mentor',
        style: GoogleFonts.poppins(
          fontSize: 26,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Ceritakan siapa dirimu dan bidang yang ingin kamu dampingi. Tim Cermatify akan meninjau pengajuanmu.',
        style: _body(13),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.checkoutButtonColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '1. Lengkapi profil   2. Peninjauan & interview   3. Persetujuan mentor',
          style: GoogleFonts.poppins(
            fontSize: 11,
            height: 1.7,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

class MentorFormSection extends StatelessWidget {
  const MentorFormSection({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.checkoutButtonColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(description, style: _body(11)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
  );
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.title,
    required this.description,
    this.small = false,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool small;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: small ? 24 : 38,
        height: small ? 24 : 38,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .8),
          borderRadius: BorderRadius.circular(small ? 8 : 12),
        ),
        child: Icon(icon, size: small ? 17 : 21, color: AppColors.primaryDark),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(description, style: _body(12)),
          ],
        ),
      ),
    ],
  );
}

class _IntegrityNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: .8),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      'Mendampingi, bukan mengerjakan. Mentor membantu pengguna belajar dan mengembangkan karya sendiri, tanpa joki tugas, manipulasi data, atau janji hasil akademik.',
      style: _body(12),
    ),
  );
}

class _CompactInformation extends StatelessWidget {
  const _CompactInformation({
    required this.title,
    required this.icon,
    required this.content,
  });
  final String title;
  final IconData icon;
  final Widget content;
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 10),
      leading: Icon(icon, color: AppColors.primaryDark, size: 21),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      children: [content],
    ),
  );
}

TextStyle _body(double size) => GoogleFonts.poppins(
  fontSize: size,
  height: 1.65,
  color: AppColors.textSecondary,
);
