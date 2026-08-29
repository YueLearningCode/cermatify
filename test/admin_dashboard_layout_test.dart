import 'package:cermatify/app/modules/admin_home/views/admin_home_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin statistics use responsive column counts', () {
    expect(adminStatisticColumnCount(320), 1);
    expect(adminStatisticColumnCount(559), 1);
    expect(adminStatisticColumnCount(560), 2);
    expect(adminStatisticColumnCount(1039), 2);
    expect(adminStatisticColumnCount(1040), 4);
    expect(adminStatisticColumnCount(1920), 4);
  });

  test('admin quick actions use responsive column counts', () {
    expect(adminActionColumnCount(320), 1);
    expect(adminActionColumnCount(619), 1);
    expect(adminActionColumnCount(620), 2);
    expect(adminActionColumnCount(1039), 2);
    expect(adminActionColumnCount(1040), 3);
    expect(adminActionColumnCount(1920), 3);
  });
}
