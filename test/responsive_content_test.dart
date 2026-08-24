import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const contentKey = Key('content');

  Widget buildContent() {
    return const MaterialApp(
      home: Scaffold(
        body: ResponsiveContent(
          maxWidth: 900,
          child: ColoredBox(key: contentKey, color: Colors.white),
        ),
      ),
    );
  }

  testWidgets('fills a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildContent());

    expect(tester.getSize(find.byKey(contentKey)).width, 500);
  });

  testWidgets('limits content width on a wide viewport', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildContent());

    expect(tester.getSize(find.byKey(contentKey)).width, 900);
  });

  testWidgets('supports a column with expanded content', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            child: Column(
              children: [Expanded(child: ColoredBox(color: Colors.white))],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
