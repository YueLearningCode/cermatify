import 'package:cermatify/app/data/layout/app_breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies mobile, tablet, and desktop boundaries', () {
    expect(AppBreakpoints.isMobile(599), isTrue);
    expect(AppBreakpoints.isMobile(600), isFalse);

    expect(AppBreakpoints.isTablet(600), isTrue);
    expect(AppBreakpoints.isTablet(1023), isTrue);
    expect(AppBreakpoints.isTablet(1024), isFalse);

    expect(AppBreakpoints.isDesktop(1024), isTrue);
  });
}
