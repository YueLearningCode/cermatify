import 'dart:convert';
import 'dart:io';

import 'package:cermatify/app/modules/legal/views/legal_view.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  for (final name in ['privacy', 'terms', 'delete-account']) {
    testWidgets('$name works without Firebase/login and fits a narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: LegalView(document: name)));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Privasi dan akun'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test(
      '$name has matching standalone public content and no login requirement',
      () {
        final document =
            jsonDecode(File('assets/legal/$name.json').readAsStringSync())
                as Map;
        final html = File('web/legal/$name.html').readAsStringSync();
        expect(html, contains(document['title']));
        expect(html, contains('cermatifycompany@gmail.com'));
        expect(html, isNot(contains('<script')));
        final route = AppPages.routes.firstWhere(
          (page) => page.name == '/$name',
        );
        expect(route.middlewares ?? [], isEmpty);
      },
    );
  }

  testWidgets('privacy links open the public deletion route', (tester) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: PrivacyAccountLinks()),
        getPages: [
          GetPage(
            name: Routes.DELETE_ACCOUNT,
            page: () => const Scaffold(body: Text('Tujuan penghapusan akun')),
          ),
        ],
      ),
    );
    await tester.tap(find.text('Hapus akun dan data'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.DELETE_ACCOUNT);
    expect(find.text('Tujuan penghapusan akun'), findsOneWidget);
  });
}
