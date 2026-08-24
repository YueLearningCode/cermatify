import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  test('formats Indonesian currency without decimal digits', () {
    expect(AppFormats.hargaPendek(125000), contains('125.000'));
  });

  test('formats nullable dates safely', () {
    expect(AppFormats.formatDate(null), isEmpty);
    expect(AppFormats.formatDate(DateTime(2026, 8, 24)), '24/08/2026');
  });

  test('returns not valid for unsupported date input', () {
    expect(AppFormats.edMy(42), 'not valid');
    expect(AppFormats.fulledMy(false), 'not valid');
  });
}
