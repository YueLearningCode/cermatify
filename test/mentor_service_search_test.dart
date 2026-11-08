import 'package:cermatify/app/data/models/mentor_service_options.dart';
import 'package:cermatify/app/data/widgets/searchable_service_checklist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const services = [
    {'id': 'essay', 'name': 'Essai Competition', 'type': 'complink'},
    {'id': 'ux', 'name': 'UI/UX Design Competition', 'type': 'complink'},
    {'id': 'paper', 'name': 'Artikel', 'type': 'paperlink'},
  ];

  test('mentors can browse both fields before choosing their role', () {
    final source = [
      ...services,
      {'id': 'invalid', 'name': 'Invalid', 'type': 'admin'},
      {'id': '', 'name': 'No ID', 'type': 'complink'},
    ];
    expect(availableMentorServices(source, '').map((item) => item['id']), [
      'essay',
      'ux',
      'paper',
    ]);
    expect(availableMentorServices(source, 'paperlink').single['id'], 'paper');
    expect(availableMentorServices(source, 'complink').length, 2);
    expect(availableMentorServices(source, 'unknown'), isEmpty);
  });

  test(
    'the first valid service determines role; later selections cannot cross roles',
    () {
      expect(mentorRoleForServiceSelection(services, 'ux', ''), 'complink');
      expect(mentorRoleForServiceSelection(services, 'paper', ''), 'paperlink');
      expect(
        mentorRoleForServiceSelection(services, 'paper', 'complink'),
        isNull,
      );
      expect(mentorRoleForServiceSelection(services, 'missing', ''), isNull);
    },
  );

  Future<void> pumpList(
    WidgetTester tester, {
    List<Map<String, String>> options = services,
    bool loading = false,
    String error = '',
    VoidCallback? retry,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SearchableServiceChecklist(
            services: options,
            selectedIds: const {},
            onToggle: (_) {},
            isLoading: loading,
            errorMessage: error,
            onRetry: retry,
          ),
        ),
      ),
    ),
  );

  testWidgets(
    'clicking the empty search shows actual service choices without typing',
    (tester) async {
      await pumpList(tester);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.text('Layanan tersedia (3)'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(find.text('Essai Competition'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Tidak ada layanan yang cocok.'), findsNothing);
    },
  );

  testWidgets(
    'clear search restores all choices and retains the checked service',
    (tester) async {
      final selected = <String>{'paper'};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableServiceChecklist(
              services: services,
              selectedIds: selected,
              onToggle: (_) {},
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'UI/UX');
      await tester.pump();
      expect(find.byType(CheckboxListTile), findsOneWidget);
      await tester.tap(find.byTooltip('Tampilkan semua layanan'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(
        tester
            .widget<CheckboxListTile>(
              find.widgetWithText(CheckboxListTile, 'Artikel'),
            )
            .value,
        isTrue,
      );
    },
  );

  testWidgets('catalog empty state differs from an unmatched query', (
    tester,
  ) async {
    await pumpList(tester, options: []);
    expect(
      find.text('Belum ada layanan tersedia untuk bidang ini.'),
      findsOneWidget,
    );
    expect(find.text('Tidak ada layanan yang cocok.'), findsNothing);
    await pumpList(tester);
    await tester.enterText(find.byType(TextField), 'tidak ditemukan');
    await tester.pump();
    expect(find.text('Tidak ada layanan yang cocok.'), findsOneWidget);
  });

  testWidgets(
    'loading is not presented as a missing service or failed search',
    (tester) async {
      await pumpList(tester, options: [], loading: true);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Tidak ada layanan yang cocok.'), findsNothing);
      expect(
        find.text('Belum ada layanan tersedia untuk bidang ini.'),
        findsNothing,
      );
      await pumpList(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Layanan tersedia (3)'), findsOneWidget);
    },
  );

  testWidgets('failed loading offers a real retry rather than sample choices', (
    tester,
  ) async {
    var retries = 0;
    await pumpList(
      tester,
      error: 'Layanan belum dapat dimuat.',
      retry: () => retries++,
    );
    expect(find.text('Layanan belum dapat dimuat.'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.text('Muat ulang layanan'));
    expect(retries, 1);
  });

  testWidgets('service list fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SearchableServiceChecklist(
                services: services,
                selectedIds: const {},
                onToggle: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
