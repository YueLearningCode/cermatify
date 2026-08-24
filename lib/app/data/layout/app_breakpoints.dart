abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double desktop = 1024;
  static const double expandedNavigation = 1280;
  static const double maxContentWidth = 1440;

  static bool isMobile(double width) => width < mobile;

  static bool isTablet(double width) => width >= mobile && width < desktop;

  static bool isDesktop(double width) => width >= desktop;
}
