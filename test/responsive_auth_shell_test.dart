import 'package:cermatify/app/data/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAuthShell(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ResponsiveAuthShell(
              title: 'Kolaborasi akademik',
              description: 'Deskripsi autentikasi',
              form: SizedBox(height: 520, child: Text('Form login')),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('centers the auth composition vertically on desktop', (
    tester,
  ) async {
    await pumpAuthShell(tester, 1440);

    final panel = find.byKey(const ValueKey('auth_visual_panel'));
    final rect = tester.getRect(panel);
    expect(rect.center.dy, closeTo(450, 1));
    expect(
      find.bySemanticsLabel('Ilustrasi kolaborasi akademik'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the form-only composition below desktop', (tester) async {
    await pumpAuthShell(tester, 768);

    expect(find.byKey(const ValueKey('auth_visual_panel')), findsNothing);
    expect(find.text('Form login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[1024, 1366, 1920]) {
    testWidgets('desktop auth has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await pumpAuthShell(tester, width);

      expect(find.byKey(const ValueKey('auth_visual_panel')), findsOneWidget);
      expect(find.byKey(const ValueKey('auth_form_panel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
