import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingCta extends StatelessWidget {
  const LandingCta({super.key, required this.onSelected});

  final ValueChanged<LandingNavTarget> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final stacked =
            constraints.maxWidth < 650 ||
            MediaQuery.textScalerOf(context).scale(14) > 18;
        final userAction = ElevatedButton.icon(
          key: const ValueKey('landing-cta-user'),
          onPressed: () => onSelected(LandingNavTarget.register),
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: const Text('Mulai sebagai Pengguna'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.whiteColor,
            foregroundColor: AppColors.primaryDark,
            elevation: 0,
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        final mentorAction = OutlinedButton.icon(
          key: const ValueKey('landing-cta-mentor'),
          onPressed: () => onSelected(LandingNavTarget.mentor),
          icon: const Icon(Icons.school_outlined, size: 20),
          label: const Text('Daftar sebagai Mentor'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.whiteColor,
            side: BorderSide(color: AppColors.whiteColor.withValues(alpha: .7)),
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(wide ? 40 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, Color(0xFF114A91)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siap menentukan langkah berikutnya?',
                style: GoogleFonts.poppins(
                  fontSize: wide ? 30 : 23,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: AppColors.whiteColor,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'Mulai sebagai pengguna untuk mendapatkan pendampingan atau mengajukan kebutuhan responden penelitian. Ingin berbagi keahlian? Daftarkan dirimu sebagai mentor.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColors.whiteColor.withValues(alpha: .9),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (stacked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    userAction,
                    const SizedBox(height: 12),
                    mentorAction,
                  ],
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [userAction, mentorAction],
                ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                children: [
                  Text(
                    'Sudah punya akun?',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.whiteColor.withValues(alpha: .9),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('landing-cta-login'),
                    onPressed: () => onSelected(LandingNavTarget.login),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.whiteColor,
                      minimumSize: const Size(48, 48),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    child: const Text('Masuk di sini'),
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
