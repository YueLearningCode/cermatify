import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cermatify/app/modules/landing/views/landing_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  test('all named routes are unique and use absolute paths', () {
    final names = AppPages.routes.map((page) => page.name).toList();

    expect(names.toSet(), hasLength(names.length));
    expect(names, everyElement(startsWith('/')));
  });

  test('unknown route points to the not-found page', () {
    expect(AppPages.unknownRoute.name, Routes.NOT_FOUND);
  });

  test('admin and account actions have stable named routes', () {
    expect(Routes.ADMIN_ORDERS, '/admin/orders');
    expect(Routes.ADMIN_WITHDRAW, '/admin/withdraw');
    expect(Routes.EDIT_PROFILE, '/profile/edit');
    expect(Routes.CHANGE_PASSWORD, '/profile/change-password');
    expect(Routes.adminUserDetail('user 1'), '/admin/users/user%201');
    expect(Routes.adminMentorDetail('mentor/1'), '/admin/mentors/mentor%2F1');
    expect(Routes.chatRoom('user/1'), '/chat/user%2F1');
    expect(Routes.kuesionerDetail('kuesioner 1'), '/kuesioner/kuesioner%201');
  });

  test('all private routes declare middleware', () {
    const publicRoutes = {
      Routes.LANDING,
      Routes.LEGACY_LANDING,
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.SPLASH,
      Routes.PRIVACY,
      Routes.TERMS,
      Routes.DELETE_ACCOUNT,
    };
    final privatePages = AppPages.routes.where(
      (page) => !publicRoutes.contains(page.name),
    );

    expect(privatePages, isNotEmpty);
    for (final page in privatePages) {
      expect(
        page.middlewares,
        isNotEmpty,
        reason: '${page.name} tidak memiliki route guard',
      );
    }
  });

  for (final initialRoute in [Routes.LANDING, Routes.LEGACY_LANDING]) {
    testWidgets('opens the public landing at root from $initialRoute', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          unknownRoute: AppPages.unknownRoute,
        ),
      );
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/');
      expect(find.byType(LandingView), findsOneWidget);
      expect(find.text('Lihat Layanan'), findsOneWidget);
      expect(AppPages.INITIAL, '/');
      expect(tester.takeException(), isNull);
    });
  }
}
