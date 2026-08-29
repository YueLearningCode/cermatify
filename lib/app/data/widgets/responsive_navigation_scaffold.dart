import 'package:cermatify/app/data/layout/app_breakpoints.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ResponsiveNavigationScaffold extends StatelessWidget {
  const ResponsiveNavigationScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.mobileNavigation,
    this.appBar,
  });

  final Widget body;
  final int selectedIndex;
  final List<NavigationRailDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget mobileNavigation;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);

        if (isMobile) {
          return Scaffold(
            appBar: appBar,
            body: body,
            bottomNavigationBar: mobileNavigation,
          );
        }

        final isExpanded =
            constraints.maxWidth >= AppBreakpoints.expandedNavigation;

        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              SafeArea(
                right: false,
                child: NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  extended: isExpanded,
                  labelType: isExpanded
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  minExtendedWidth: 220,
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primaryColor.withValues(
                    alpha: 0.12,
                  ),
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.primaryColor,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: isExpanded
                        ? const Text(
                            'Cermatify',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : const Icon(
                            Icons.school_rounded,
                            color: AppColors.primaryColor,
                            size: 30,
                          ),
                  ),
                  destinations: destinations,
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppBreakpoints.maxContentWidth,
                      ),
                      child: SizedBox.expand(child: body),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
