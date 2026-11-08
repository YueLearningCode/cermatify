import 'package:cermatify/app/data/models/competition_catalog.dart';
import 'package:cermatify/app/data/widgets/searchable_dropdown_form_field.dart';
import 'package:cermatify/app/data/widgets/searchable_service_checklist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const services = [
    {
      'id': 'essay',
      'name': 'Esai',
      'type': 'complink',
      'competitionCategoryId': 'writing',
    },
    {
      'id': 'business',
      'name': 'Business Plan',
      'type': 'complink',
      'competitionCategoryId': 'business',
    },
    {'id': 'legacy', 'name': 'Lomba lama', 'type': 'complink'},
    {'id': 'paper', 'name': 'Metode penelitian', 'type': 'paperlink'},
  ];
  const choices = [
    DropdownMenuItem(value: 'essay-id', child: Text('Esai ilmiah')),
    DropdownMenuItem(value: 'business-id', child: Text('Business Plan')),
  ];

  test('categories narrow services without losing legacy entries in all', () {
    expect(competitionServicesForCategory(services, '').map((s) => s['id']), [
      'essay',
      'business',
      'legacy',
    ]);
    expect(
      competitionServicesForCategory(services, 'writing').single['id'],
      'essay',
    );
    expect(
      competitionServicesForCategory(
        services,
        uncategorizedCompetitionId,
      ).single['id'],
      'legacy',
    );
    expect(competitionServicesForCategory(services, 'unknown'), isEmpty);
    expect(services.last['type'], 'paperlink');
  });

  testWidgets(
    'search filters the list and returns the stored ID, not typed text',
    (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableDropdownFormField(
              items: choices,
              onChanged: (value) => result = value,
              decoration: const InputDecoration(labelText: 'Cabang lomba'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(SearchableDropdownFormField));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(2));
      await tester.enterText(find.byType(TextField), 'BUSINESS');
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      expect(result, isNull);
      await tester.tap(find.widgetWithText(ListTile, 'Business Plan'));
      await tester.pumpAndSettle();
      expect(result, 'business-id');
      expect(find.byType(Dialog), findsNothing);
    },
  );

  testWidgets('unmatched typing and cancellation do not modify the selection', (
    tester,
  ) async {
    var changed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableDropdownFormField(
            items: choices,
            initialValue: 'essay-id',
            onChanged: (_) => changed = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SearchableDropdownFormField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pump();
    expect(find.text('Tidak ada pilihan yang cocok.'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(changed, isFalse);
    expect(find.text('Esai ilmiah'), findsOneWidget);
  });

  testWidgets(
    'dependent field clears when parent selection and options change',
    (tester) async {
      Widget field(String? value, List<DropdownMenuItem<String>> items) =>
          MaterialApp(
            home: Scaffold(
              body: SearchableDropdownFormField(
                key: const ValueKey('dependent'),
                initialValue: value,
                items: items,
                onChanged: (_) {},
                validator: (value) => value == null ? 'Pilih cabang' : null,
              ),
            ),
          );
      await tester.pumpWidget(field('essay-id', choices));
      expect(find.text('Esai ilmiah'), findsOneWidget);
      await tester.pumpWidget(field(null, [choices.last]));
      final state = tester.state<FormFieldState<String>>(
        find.byType(SearchableDropdownFormField),
      );
      expect(state.value, isNull);
      expect(state.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pilih cabang'), findsOneWidget);
    },
  );

  testWidgets('disabled fields do not open an options dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableDropdownFormField(items: choices, onChanged: null),
        ),
      ),
    );
    await tester.tap(find.byType(SearchableDropdownFormField));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets(
    'service multi-select retains selection outside the search results',
    (tester) async {
      final selected = <String>{'essay'};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => SearchableServiceChecklist(
                services: services,
                selectedIds: selected,
                onToggle: (id) => update(
                  () => selected.contains(id)
                      ? selected.remove(id)
                      : selected.add(id),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Business');
      await tester.pump();
      expect(find.byType(CheckboxListTile), findsOneWidget);
      await tester.tap(find.text('Business Plan'));
      await tester.pump();
      expect(selected, {'essay', 'business'});
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(
        tester
            .widget<CheckboxListTile>(
              find.widgetWithText(CheckboxListTile, 'Esai'),
            )
            .value,
        isTrue,
      );
    },
  );

  testWidgets('search dialog fits narrow screen, enlarged text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            viewInsets: const EdgeInsets.only(bottom: 280),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: SearchableDropdownFormField(
            items: choices,
            onChanged: (_) {},
            decoration: const InputDecoration(labelText: 'Cabang lomba'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SearchableDropdownFormField));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
