import 'package:cermatify/app/data/layout/app_breakpoints.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    right: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.8),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.035),
                      blurRadius: 18,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  right: false,
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    extended: isExpanded,
                    groupAlignment: -0.48,
                    labelType: isExpanded
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.selected,
                    minWidth: 84,
                    minExtendedWidth: 264,
                    backgroundColor: Colors.transparent,
                    indicatorColor: AppColors.primaryColor.withValues(
                      alpha: 0.12,
                    ),
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.primaryColor,
                      size: 23,
                    ),
                    selectedLabelTextStyle: GoogleFonts.poppins(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                      size: 22,
                    ),
                    unselectedLabelTextStyle: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 36),
                      child: isExpanded
                          ? SizedBox(
                              width: 232,
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
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (brandSubtitle != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            brandSubtitle!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textSecondary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
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
              ),
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
