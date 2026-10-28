import 'package:cermatify/app/modules/landing/views/landing_view.dart';
import 'package:cermatify/app/modules/landing/widgets/landing_navigation.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  Future<void> pumpLanding(
    WidgetTester tester,
    double width, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const LandingView(),
        getPages: [
          GetPage(
            name: Routes.LOGIN,
            page: () => const Scaffold(body: Text('Formulir masuk')),
          ),
          GetPage(
            name: Routes.REGISTER,
            page: () => const Scaffold(body: Text('Formulir pendaftaran')),
          ),
        ],
      ),
    );
    await tester.pump();
  }

  // Review previews may animate indefinitely while visible.
  Future<void> finishNavigation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  Future<void> select(
    WidgetTester tester,
    LandingNavTarget target,
    String label,
  ) async {
    final menu = find.byKey(const ValueKey('landing-menu'));
    if (menu.evaluate().isNotEmpty && target != LandingNavTarget.login) {
      await tester.tap(menu);
      await finishNavigation(tester);
      await tester.tap(find.text(label));
    } else {
      await tester.tap(find.byKey(ValueKey('landing-nav-${target.name}')));
    }
    await finishNavigation(tester);
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    await Scrollable.ensureVisible(tester.element(target), alignment: .5);
    await finishNavigation(tester);
  }

  for (final width in <double>[375, 1366]) {
    testWidgets(
      'section navigation and brand work without login at $width px',
      (tester) async {
        await pumpLanding(tester, width);
        const sections = [
          (
            LandingNavTarget.services,
            'Layanan',
            'Pilih layanan sesuai kebutuhanmu',
          ),
          (LandingNavTarget.howItWorks, 'Cara Kerja', 'Cara Kerja Cermatify'),
          (LandingNavTarget.faq, 'FAQ', 'Pertanyaan yang sering diajukan'),
        ];
        for (final section in sections) {
          await select(tester, section.$1, section.$2);
          final heading = tester.getRect(find.text(section.$3));
          expect(heading.top, greaterThanOrEqualTo(72));
          expect(heading.top, lessThanOrEqualTo(96));
          expect(heading.bottom, lessThan(900));
          expect(Get.currentRoute, '/');
          expect(
            tester
                .widget<LandingNavigation>(find.byType(LandingNavigation))
                .activeTarget,
            section.$1,
            reason: 'Heading position after navigation: $heading',
          );
          expect(find.byType(PopupMenuItem<LandingNavTarget>), findsNothing);
        }

        await tester.tap(find.text('Apakah saya harus punya akun?'));
        await finishNavigation(tester);
        expect(find.textContaining('tanpa akun'), findsOneWidget);
        expect(Get.currentRoute, '/');

        await tester.tap(find.byKey(const ValueKey('landing-brand')));
        await finishNavigation(tester);
        final scroll = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
        expect(scroll.controller!.offset, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mentor action preserves the registration role at $width px', (
      tester,
    ) async {
      await pumpLanding(tester, width);
      await select(tester, LandingNavTarget.mentor, 'Jadi Mentor');
      expect(Get.currentRoute, Routes.REGISTER);
      expect(Get.arguments, 'mentor');
      expect(find.text('Formulir pendaftaran'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('user registration action opens the user form at $width px', (
      tester,
    ) async {
      await pumpLanding(tester, width);
      await select(
        tester,
        LandingNavTarget.register,
        'Daftar sebagai Pengguna',
      );
      expect(Get.currentRoute, Routes.REGISTER);
      expect(Get.arguments, isNull);
      expect(find.text('Formulir pendaftaran'), findsOneWidget);
    });

    testWidgets('login action opens login at $width px', (tester) async {
      await pumpLanding(tester, width);
      await select(tester, LandingNavTarget.login, 'Masuk');
      expect(Get.currentRoute, Routes.LOGIN);
      expect(find.text('Formulir masuk'), findsOneWidget);
    });

    for (final action in [
      ('user', Routes.REGISTER, null),
      ('mentor', Routes.REGISTER, 'mentor'),
      ('login', Routes.LOGIN, null),
    ]) {
      testWidgets(
        'closing CTA ${action.$1} opens the right form at $width px',
        (tester) async {
          await pumpLanding(tester, width);
          final button = find.byKey(ValueKey('landing-cta-${action.$1}'));
          await reveal(tester, button);
          await tester.tap(button);
          await finishNavigation(tester);
          expect(Get.currentRoute, action.$2);
          expect(Get.arguments, action.$3);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'footer links navigate within the public landing at $width px',
      (tester) async {
        await pumpLanding(tester, width);
        for (final section in [
          ('services', 'Pilih layanan sesuai kebutuhanmu'),
          ('howItWorks', 'Cara Kerja Cermatify'),
          ('faq', 'Pertanyaan yang sering diajukan'),
        ]) {
          final link = find.byKey(ValueKey('landing-footer-${section.$1}'));
          await reveal(tester, link);
          await tester.tap(link);
          await finishNavigation(tester);
          final heading = tester.getRect(find.text(section.$2));
          expect(heading.top, greaterThanOrEqualTo(72));
          expect(heading.top, lessThanOrEqualTo(96));
          expect(Get.currentRoute, '/');
        }
        final top = find.byKey(const ValueKey('landing-footer-top'));
        await reveal(tester, top);
        await tester.tap(top);
        await finishNavigation(tester);
        final scroll = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
        expect(scroll.controller!.offset, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('footer email opens the confirmed support address', (
    tester,
  ) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final launchedUrls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'launch') {
        launchedUrls.add((call.arguments as Map)['url'] as String);
      }
      return true;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await pumpLanding(tester, 375);
    final email = find.byKey(const ValueKey('landing-footer-email'));
    await reveal(tester, email);
    await tester.tap(email);
    await finishNavigation(tester);
    expect(launchedUrls, ['mailto:cermatifycompany@gmail.com']);
    expect(Get.currentRoute, '/');
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing CTA and footer fit at 320 px with text at 200 percent', (
    tester,
  ) async {
    await pumpLanding(tester, 320, textScale: 2);
    for (final key in [
      'landing-cta-user',
      'landing-cta-mentor',
      'landing-cta-login',
      'landing-footer-email',
      'landing-footer-top',
    ]) {
      final control = find.byKey(ValueKey(key));
      await reveal(tester, control);
      final bounds = tester.getRect(control);
      expect(bounds.left, greaterThanOrEqualTo(24));
      expect(bounds.right, lessThanOrEqualTo(296));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('desktop sections can be reached with the keyboard', (
    tester,
  ) async {
    await pumpLanding(tester, 1366);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await finishNavigation(tester);
    final heading = tester.getRect(find.text('Cara Kerja Cermatify'));
    expect(heading.top, greaterThanOrEqualTo(72));
    expect(heading.bottom, lessThan(900));
    expect(Get.currentRoute, '/');
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact menu supports Escape and text at 200 percent', (
    tester,
  ) async {
    await pumpLanding(tester, 320, textScale: 2);
    final menu = find.byKey(const ValueKey('landing-menu'));
    await tester.tap(menu);
    await finishNavigation(tester);
    expect(find.text('Layanan'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await finishNavigation(tester);
    expect(find.text('Layanan'), findsNothing);
    expect(Get.currentRoute, '/');

    await select(tester, LandingNavTarget.faq, 'FAQ');
    final heading = tester.getRect(
      find.text('Pertanyaan yang sering diajukan'),
    );
    expect(heading.top, greaterThanOrEqualTo(72));
    expect(heading.top, lessThan(900));
    expect(tester.takeException(), isNull);
  });
}
