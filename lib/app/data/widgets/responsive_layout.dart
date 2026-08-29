import 'package:cermatify/app/data/layout/app_breakpoints.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';

typedef ResponsiveLayoutBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

/// Selects a layout using the application's shared viewport breakpoints.
///
/// Only [mobile] is required. When a larger layout is omitted, the nearest
/// smaller layout is reused so a page can be migrated incrementally.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final ResponsiveLayoutBuilder mobile;
  final ResponsiveLayoutBuilder? tablet;
  final ResponsiveLayoutBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (AppBreakpoints.isDesktop(constraints.maxWidth)) {
          return (desktop ?? tablet ?? mobile)(context, constraints);
        }
        if (AppBreakpoints.isTablet(constraints.maxWidth)) {
          return (tablet ?? mobile)(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

/// Standard horizontal page spacing for mobile, tablet, and desktop.
class ResponsiveGutter extends StatelessWidget {
  const ResponsiveGutter({super.key, required this.child, this.vertical = 0});

  final Widget child;
  final double vertical;

  static double horizontalFor(double width) {
    if (width >= AppBreakpoints.desktop) return 32;
    if (width >= AppBreakpoints.mobile) return 24;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalFor(constraints.maxWidth),
          vertical: vertical,
        ),
        child: child,
      ),
    );
  }
}

/// A reusable one/two-pane layout. On mobile the secondary panel is placed
/// below the primary panel; on larger viewports both panels are side by side.
class ResponsiveSplitView extends StatelessWidget {
  const ResponsiveSplitView({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 3,
    this.secondaryFlex = 2,
    this.gap = 24,
    this.splitAt = AppBreakpoints.desktop,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double gap;
  final double splitAt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < splitAt) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              SizedBox(height: gap),
              secondary,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: primaryFlex, child: primary),
            SizedBox(width: gap),
            Expanded(flex: secondaryFlex, child: secondary),
          ],
        );
      },
    );
  }
}

/// Calculates a stable grid column count without hard-coding every viewport.
int responsiveColumnCount(
  double width, {
  double minItemWidth = 260,
  int min = 1,
  int max = 4,
  double spacing = 16,
}) {
  final count = ((width + spacing) / (minItemWidth + spacing)).floor();
  return count.clamp(min, max);
}

/// Shared responsive frame for login and registration pages.
class ResponsiveAuthShell extends StatelessWidget {
  const ResponsiveAuthShell({
    super.key,
    required this.form,
    required this.title,
    required this.description,
  });

  final Widget form;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    if (!AppBreakpoints.isDesktop(viewportWidth)) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: form,
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: viewportHeight.clamp(620, double.infinity),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _AuthVisualPanel(
                  key: const ValueKey('auth_visual_panel'),
                  title: title,
                  description: description,
                ),
              ),
              const SizedBox(width: 56),
              SizedBox(
                key: const ValueKey('auth_form_panel'),
                width: 480,
                child: form,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthVisualPanel extends StatelessWidget {
  const _AuthVisualPanel({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 620,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primaryColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -90,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(36),
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
                      child: Image.asset('assets/images/logo.jpeg'),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Cermatify',
                      style: TextStyle(
                        color: AppColors.black414,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/banner2.jpg',
                      fit: BoxFit.contain,
                      semanticLabel: 'Ilustrasi kolaborasi akademik',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.checkoutButtonColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Satu akun untuk semua perangkat',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.black414,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyTextSecondaryColor,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _AuthBadge(icon: Icons.verified_outlined, label: 'Mentor'),
                    _AuthBadge(
                      icon: Icons.devices_rounded,
                      label: 'Multi-device',
                    ),
                    _AuthBadge(icon: Icons.lock_outline, label: 'Aman'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBadge extends StatelessWidget {
  const _AuthBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
