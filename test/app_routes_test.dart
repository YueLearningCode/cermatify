import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      Routes.LOGIN,
      Routes.REGISTER,
      Routes.SPLASH,
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
}
