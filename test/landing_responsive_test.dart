import 'package:cermatify/app/modules/landing/views/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  const headline = 'Karya ilmiah, kompetisi, dan riset lebih terarah.';
  const servicesTitle = 'Pilih layanan sesuai kebutuhanmu';

  Future<void> pumpLanding(
    WidgetTester tester,
    double width, {
    bool disableAnimations = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: const LandingView(),
      ),
    );
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

    final copy = tester.getRect(find.text(headline));
    final illustration = tester.getRect(
      find.image(const AssetImage('assets/images/banner1.jpg')),
    );
    expect(copy.right, lessThan(illustration.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the compact hero on mobile', (tester) async {
    await pumpLanding(tester, 375);

    final copy = tester.getRect(find.text(headline));
    final illustration = tester.getRect(
      find.image(const AssetImage('assets/images/banner1.jpg')),
    );
    expect(illustration.bottom, lessThan(copy.top));
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[320, 600, 768, 1024, 1920]) {
    testWidgets('has no layout overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await pumpLanding(tester, width);

      final scroll = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );
      scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }

  for (final width in <double>[320, 375, 1366]) {
    testWidgets('service CTA scrolls below the pinned header at $width px', (
      tester,
    ) async {
      await pumpLanding(tester, width);
      await tester.ensureVisible(find.text('Lihat Layanan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat Layanan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final title = tester.getRect(find.text(servicesTitle));
      expect(title.top, greaterThanOrEqualTo(72));
      expect(title.bottom, lessThan(900));
      expect(Get.currentRoute, '/');
      expect(find.text('Cermat Paper'), findsOneWidget);
      expect(find.text('Cermat Competition'), findsOneWidget);
      expect(find.text('Cermat Kuesioner'), findsOneWidget);
      expect(find.text('Cerita Pengguna'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('service CTA respects reduced motion and enlarged text', (
    tester,
  ) async {
    await pumpLanding(tester, 375, disableAnimations: true, textScale: 2);
    await tester.ensureVisible(find.text('Lihat Layanan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Layanan'));
    await tester.pump();

    final title = tester.getRect(find.text(servicesTitle));
    expect(title.top, greaterThanOrEqualTo(72));
    expect(title.top, lessThan(900));
    final scroll = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView),
    );
    expect(scroll.controller!.position.isScrollingNotifier.value, isFalse);
    expect(tester.takeException(), isNull);
  });
}
