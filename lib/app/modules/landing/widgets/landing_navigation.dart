import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LandingNavTarget {
  home,
  services,
  howItWorks,
  mentor,
  faq,
  login,
  register,
}

const _sectionLinks = {
  LandingNavTarget.services: 'Layanan',
  LandingNavTarget.howItWorks: 'Cara Kerja',
  LandingNavTarget.mentor: 'Jadi Mentor',
  LandingNavTarget.faq: 'FAQ',
};

class LandingNavigation extends StatelessWidget {
  const LandingNavigation({
    super.key,
    required this.onSelected,
    this.activeTarget,
  });

  final ValueChanged<LandingNavTarget> onSelected;
  final LandingNavTarget? activeTarget;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final expanded =
                    constraints.maxWidth >= 900 &&
                    MediaQuery.textScalerOf(context).scale(13) <= 18;
                return Row(
                  children: [
                    Expanded(child: _brand()),
                    if (expanded)
                      for (final link in _sectionLinks.entries)
                        Semantics(
                          selected: activeTarget == link.key,
                          child: TextButton(
                            key: ValueKey('landing-nav-${link.key.name}'),
                            onPressed: () => onSelected(link.key),
                            style: TextButton.styleFrom(
                              foregroundColor: activeTarget == link.key
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimary,
                              backgroundColor: activeTarget == link.key
                                  ? AppColors.primaryColor.withValues(
                                      alpha: .08,
                                    )
                                  : null,
                              minimumSize: const Size(48, 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: activeTarget == link.key
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            child: Text(link.value),
                          ),
                        ),
                    if (expanded) const SizedBox(width: 12),
                    TextButton(
                      key: const ValueKey('landing-nav-login'),
                      onPressed: () => onSelected(LandingNavTarget.login),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Masuk'),
                    ),
                    if (expanded) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        key: const ValueKey('landing-nav-register'),
                        onPressed: () => onSelected(LandingNavTarget.register),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.whiteColor,
                          elevation: 0,
                          minimumSize: const Size(80, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Daftar'),
                      ),
                    ] else
                      PopupMenuButton<LandingNavTarget>(
                        key: const ValueKey('landing-menu'),
                        tooltip: 'Buka menu navigasi',
                        icon: const Icon(Icons.menu_rounded),
                        color: AppColors.surface,
                        onSelected: onSelected,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: LandingNavTarget.home,
                            child: Text('Beranda'),
                          ),
                          for (final link in _sectionLinks.entries)
                            PopupMenuItem(
                              value: link.key,
                              child: Text(link.value),
                            ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: LandingNavTarget.register,
                            child: Text('Daftar sebagai Pengguna'),
                          ),
                        ],
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

  Widget _brand() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: 'Kembali ke awal Cermatify',
        child: InkWell(
          key: const ValueKey('landing-brand'),
          onTap: () => onSelected(LandingNavTarget.home),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Image.asset('assets/images/logo.jpeg'),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Cermatify',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
