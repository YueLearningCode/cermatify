import 'package:cermatify/app/data/layout/app_breakpoints.dart';
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
    return ResponsiveLayout(
      mobile: (context, constraints) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: form,
        ),
      ),
      desktop: (context, constraints) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 560),
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.55,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 56),
              SizedBox(width: 480, child: form),
            ],
          ),
        ),
      ),
    );
  }
}
