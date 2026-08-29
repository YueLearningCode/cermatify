import 'package:cermatify/app/data/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildResponsiveLayout() {
    return const MaterialApp(
      home: Scaffold(
        body: ResponsiveLayout(
          mobile: _mobile,
          tablet: _tablet,
          desktop: _desktop,
        ),
      ),
    );
  }

  for (final testCase in <(double, String)>[
    (320, 'mobile'),
    (375, 'mobile'),
    (600, 'tablet'),
    (768, 'tablet'),
    (1024, 'desktop'),
    (1366, 'desktop'),
    (1440, 'desktop'),
    (1920, 'desktop'),
  ]) {
    testWidgets('selects ${testCase.$2} at ${testCase.$1.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(testCase.$1, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildResponsiveLayout());

      expect(find.text(testCase.$2), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('responsive column count stays within its configured bounds', () {
    expect(responsiveColumnCount(320), 1);
    expect(responsiveColumnCount(900), 3);
    expect(responsiveColumnCount(3000), 4);
  });
}

Widget _mobile(BuildContext context, BoxConstraints constraints) =>
    const Text('mobile');

Widget _tablet(BuildContext context, BoxConstraints constraints) =>
    const Text('tablet');

Widget _desktop(BuildContext context, BoxConstraints constraints) =>
    const Text('desktop');
