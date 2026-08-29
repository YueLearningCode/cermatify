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
    this.brandTitle = 'Cermatify',
    this.brandSubtitle,
  });

  final Widget body;
  final int selectedIndex;
  final List<NavigationRailDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget mobileNavigation;
  final PreferredSizeWidget? appBar;
  final String brandTitle;
  final String? brandSubtitle;

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
                  groupAlignment: -0.72,
                  labelType: isExpanded
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  minExtendedWidth: 240,
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
                  unselectedIconTheme: IconThemeData(
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                    child: isExpanded
                        ? SizedBox(
                            width: 216,
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.checkoutButtonColor,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: AppColors.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        brandTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (brandSubtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          brandSubtitle!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.checkoutButtonColor,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.primaryColor,
                              size: 25,
                            ),
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
