import 'package:cermatify/app/modules/landing/widgets/review_preview_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPreview(
    WidgetTester tester, {
    double width = 960,
    bool reduceMotion = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: ReviewPreviewSection()),
        ),
      ),
    );
    await tester.pump();
  }

  ScrollController controller(WidgetTester tester, int row) {
    final scroll = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: find.byKey(ValueKey('review-row-$row')),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    return scroll.controller!;
  }

  testWidgets('two rows move in opposite directions and stay paused', (
    tester,
  ) async {
    await pumpPreview(tester);
    await tester.pump(const Duration(seconds: 1));
    final first = controller(tester, 0);
    final second = controller(tester, 1);
    final firstBefore = first.offset;
    final secondBefore = second.offset;
    await tester.pump(const Duration(seconds: 1));
    expect(first.offset, greaterThan(firstBefore));
    expect(second.offset, lessThan(secondBefore));

    await tester.tap(find.text('Jeda animasi'));
    await tester.pump();
    final firstPaused = first.offset;
    final secondPaused = second.offset;
    await tester.pump(const Duration(seconds: 3));
    expect(first.offset, firstPaused);
    expect(second.offset, secondPaused);
    expect(find.text('Lanjutkan animasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reduced motion uses twelve labeled examples and allows swiping',
    (tester) async {
      await pumpPreview(tester, width: 320, reduceMotion: true, textScale: 2);
      await tester.pumpAndSettle();

      expect(find.text('Contoh fiktif'), findsNWidgets(12));
      expect(
        find.textContaining('seluruh kutipan, rating, nama'),
        findsOneWidget,
      );
      expect(find.text('Jeda animasi'), findsNothing);
      final first = controller(tester, 0);
      expect(first.offset, 0);
      final row = find.byKey(const ValueKey('review-row-0'));
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.dragFrom(
        tester.getTopLeft(row) + const Offset(100, 40),
        const Offset(-160, 0),
      );
      await tester.pumpAndSettle();
      expect(first.offset, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );
}
