import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/data/widgets/workspace_page_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

int discoveryColumnCount(double width) => width >= 900 ? 2 : 1;

class MentorDiscoveryPage extends StatelessWidget {
  const MentorDiscoveryPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.guideTitle,
    required this.guideDescription,
    required this.guideIcon,
    required this.form,
    required this.onBack,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String guideTitle;
  final String guideDescription;
  final IconData guideIcon;
  final Widget form;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ResponsiveContent(
            maxWidth: 1180,
            child: Column(
              children: [
                WorkspacePageHeader(
                  eyebrow: eyebrow,
                  title: title,
                  subtitle: subtitle,
                  onBack: onBack,
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide =
                        discoveryColumnCount(constraints.maxWidth) == 2;
                    final guide = _DiscoveryGuide(
                      title: guideTitle,
                      description: guideDescription,
                      icon: guideIcon,
                    );
                    if (!wide) {
                      return Column(
                        children: [guide, const SizedBox(height: 14), form],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 330, child: guide),
                        const SizedBox(width: 18),
                        Expanded(child: form),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiscoveryFormCard extends StatelessWidget {
  const DiscoveryFormCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onSubmit,
    this.loading = false,
    this.errorMessage = '',
    this.onRetry,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onSubmit;
  final bool loading;
  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 18 : 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.055),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 44),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            )
          else if (errorMessage.isNotEmpty)
            _DiscoveryError(message: errorMessage, onRetry: onRetry)
          else ...[
            ...children,
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('find-mentor-button'),
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(
                'Temukan mentor',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DiscoverySelectField extends StatelessWidget {
  const DiscoverySelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20),
          filled: true,
          fillColor: enabled ? AppColors.background : AppColors.disabledColor,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoveryGuide extends StatelessWidget {
  const _DiscoveryGuide({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkPrimaryColor, AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.surface, size: 26),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.surface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: GoogleFonts.poppins(
              color: AppColors.surface.withValues(alpha: 0.82),
              fontSize: 11,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          const _GuideStep(number: '1', text: 'Pilih kebutuhan layanan'),
          const SizedBox(height: 12),
          const _GuideStep(
            number: '2',
            text: 'Bandingkan mentor terverifikasi',
          ),
          const SizedBox(height: 12),
          const _GuideStep(number: '3', text: 'Mulai order dan pendampingan'),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.poppins(
              color: AppColors.surface,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: AppColors.surface,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoveryError extends StatelessWidget {
  const _DiscoveryError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
          ],
        ],
      ),
    );
  }
}
