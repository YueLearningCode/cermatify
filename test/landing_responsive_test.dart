import 'package:cermatify/app/modules/landing/views/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Future<void> pumpLanding(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GetMaterialApp(home: LandingView()));
    await tester.pump();
  }

  testWidgets('scroll view fills the desktop viewport', (tester) async {
    await pumpLanding(tester, 1440);

    final scrollView = tester.getSize(find.byType(CustomScrollView));
    expect(scrollView.width, 1440);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the horizontal desktop hero', (tester) async {
    await pumpLanding(tester, 1366);

    expect(
      find.text('Belajar lebih terarah,\nbertumbuh lebih percaya diri.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the compact hero on mobile', (tester) async {
    await pumpLanding(tester, 375);

    expect(find.text('Selamat Datang di Cermatify'), findsOneWidget);
    expect(
      find.text('Belajar lebih terarah,\nbertumbuh lebih percaya diri.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[320, 600, 768, 1024, 1920]) {
    testWidgets('has no layout overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await pumpLanding(tester, width);

      expect(tester.takeException(), isNull);
    });
  }
}
