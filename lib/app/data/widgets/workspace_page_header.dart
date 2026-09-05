import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header konsisten untuk halaman workspace yang dibuka di luar tab utama.
class WorkspacePageHeader extends StatelessWidget {
  const WorkspacePageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    this.onBack,
    this.trailing,
    this.icon = Icons.arrow_back_rounded,
  });

  final String title;
  final String subtitle;
  final String eyebrow;
  final VoidCallback? onBack;
  final Widget? trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final copy = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  eyebrow.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: compact ? 21 : 26,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: compact ? 11 : 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 18 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.07),
                AppColors.lightPrimaryColor.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(compact ? 22 : 26),
            border: Border.all(
              color: AppColors.lightPrimaryColor.withValues(alpha: 0.32),
            ),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onBack != null) ...[
                          _HeaderButton(icon: icon, onPressed: onBack!),
                          const SizedBox(width: 12),
                        ],
                        copy,
                      ],
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 16),
                      Align(alignment: Alignment.centerLeft, child: trailing!),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onBack != null) ...[
                      _HeaderButton(icon: icon, onPressed: onBack!),
                      const SizedBox(width: 14),
                    ],
                    copy,
                    if (trailing != null) ...[
                      const SizedBox(width: 20),
                      trailing!,
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.84),
      borderRadius: BorderRadius.circular(14),
      child: IconButton(
        tooltip: 'Kembali',
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primaryColor),
      ),
    );
  }
}
