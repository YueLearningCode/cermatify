import 'package:cermatify/app/modules/profile/views/change_password_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('change password uses one column on phone and tablet', () {
    expect(changePasswordColumnCount(320), 1);
    expect(changePasswordColumnCount(700), 1);
  });

  test('change password uses guide and form columns on desktop', () {
    expect(changePasswordColumnCount(900), 2);
    expect(changePasswordColumnCount(1440), 2);
  });
}
