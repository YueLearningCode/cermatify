import 'package:cermatify/app/modules/master_data/controllers/master_data_controller.dart';
import 'package:cermatify/app/modules/master_data/views/master_data_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('competition service card displays its specific category', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 108,
            child: AdminMasterDataCard(
              item: MasterDataItem(
                id: 'ux',
                name: 'UI/UX Design Competition',
                type: 'complink',
                harga: 20000,
              ),
              tabIndex: 2,
              kampusName: '',
              competitionCategoryName: 'Desain & Media Kreatif',
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    expect(
      find.text('Cermat Competition · Desain & Media Kreatif'),
      findsOneWidget,
    );
    expect(find.textContaining('Rp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'category tab remains usable on a narrow screen with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: AdminMasterDataTabs(
              selectedIndex: 0,
              onSelected: (index) => selected = index,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Kategori lomba'));
      await tester.pump();
      expect(selected, 3);
      expect(tester.takeException(), isNull);
    },
  );

  test('master data grid adapts to available content width', () {
    expect(adminMasterDataColumnCount(600), 1);
    expect(adminMasterDataColumnCount(899), 1);
    expect(adminMasterDataColumnCount(900), 2);
    expect(adminMasterDataColumnCount(1280), 2);
  });

  for (final width in <double>[280, 380, 620]) {
    testWidgets('master data card has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                height: 108,
                child: AdminMasterDataCard(
                  item: MasterDataItem(
                    id: 'layanan-1',
                    name: 'Layanan dengan nama yang sangat panjang',
                    type: 'complink',
                    harga: 500000,
                  ),
                  tabIndex: 2,
                  kampusName: '',
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byTooltip('Edit data'), findsOneWidget);
      expect(find.byTooltip('Hapus data'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('campus card opens majors without hijacking edit action', (
    tester,
  ) async {
    var opened = 0;
    var edited = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              height: 108,
              child: AdminMasterDataCard(
                item: MasterDataItem(
                  id: 'kampus-1',
                  name: 'Universitas Cermatify',
                ),
                tabIndex: 0,
                kampusName: '',
                onOpen: () => opened++,
                onEdit: () => edited++,
                onDelete: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Universitas Cermatify'));
    expect(opened, 1);

    await tester.tap(find.byTooltip('Edit data'));
    expect(edited, 1);
    expect(opened, 1);
    expect(tester.takeException(), isNull);
  });
}
