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
