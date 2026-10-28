import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/link.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key, required this.onSelected});

  final ValueChanged<LandingNavTarget> onSelected;

  static const supportEmail = 'cermatifycompany@gmail.com';

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.poppins(
      fontSize: 12,
      height: 1.7,
      color: AppColors.textSecondary,
    );
    final linkStyle = TextButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      alignment: Alignment.centerLeft,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(vertical: 10),
      textStyle: GoogleFonts.poppins(fontSize: 13),
    );

    return Container(
      padding: const EdgeInsets.only(top: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= 850 &&
                  MediaQuery.textScalerOf(context).scale(13) <= 18;
              final brand = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // EDIT LOGO FOOTER — ukuran, warna bingkai dan radius sudut.
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Cermatify',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pendampingan karya ilmiah, persiapan kompetisi, dan kebutuhan responden penelitian.',
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belajar, berdiskusi, dan mengembangkan karya sendiri.',
                    style: bodyStyle,
                  ),
                ],
              );
              final explore = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading('Jelajahi'),
                  const SizedBox(height: 8),
                  for (final link in const {
                    LandingNavTarget.services: 'Lihat layanan',
                    LandingNavTarget.howItWorks: 'Cara kerja layanan',
                    LandingNavTarget.faq: 'Pertanyaan umum',
                  }.entries)
                    TextButton(
                      key: ValueKey('landing-footer-${link.key.name}'),
                      onPressed: () => onSelected(link.key),
                      style: linkStyle,
                      child: Text(link.value),
                    ),
                ],
              );
              final support = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading('Hubungi kami'),
                  const SizedBox(height: 8),
                  Link(
                    uri: Uri(scheme: 'mailto', path: supportEmail),
                    builder: (context, followLink) => TextButton(
                      key: const ValueKey('landing-footer-email'),
                      onPressed: followLink,
                      style: linkStyle.copyWith(
                        textStyle: WidgetStatePropertyAll(
                          GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                      child: const Text(supportEmail),
                    ),
                  ),
                  Text('Senin–Sabtu · 09.00–17.00 WIB', style: bodyStyle),
                  const SizedBox(height: 8),
                  Text('Target respons awal: 1 hari kerja.', style: bodyStyle),
                ],
              );
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: brand),
                    const SizedBox(width: 48),
                    Expanded(child: explore),
                    const SizedBox(width: 48),
                    Expanded(flex: 2, child: support),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  brand,
                  const SizedBox(height: 28),
                  explore,
                  const SizedBox(height: 28),
                  support,
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Wrap(
            spacing: 32,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('© ${DateTime.now().year} Cermatify.', style: bodyStyle),
              TextButton.icon(
                key: const ValueKey('landing-footer-top'),
                onPressed: () => onSelected(LandingNavTarget.home),
                style: linkStyle,
                icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                label: const Text('Kembali ke atas'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}
