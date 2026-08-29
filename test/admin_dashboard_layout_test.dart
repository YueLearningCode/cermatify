import 'package:cermatify/app/modules/admin_home/views/admin_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin statistics use responsive column counts', () {
    expect(adminStatisticColumnCount(319), 1);
    expect(adminStatisticColumnCount(320), 2);
    expect(adminStatisticColumnCount(559), 2);
    expect(adminStatisticColumnCount(560), 2);
    expect(adminStatisticColumnCount(1039), 2);
    expect(adminStatisticColumnCount(1040), 4);
    expect(adminStatisticColumnCount(1920), 4);
  });

  test('admin cards become denser on narrow layouts', () {
    expect(adminStatisticCardExtent(320), 132);
    expect(adminStatisticCardExtent(559), 132);
    expect(adminStatisticCardExtent(560), 148);

    expect(adminActionCardExtent(375), 120);
    expect(adminActionCardExtent(619), 120);
    expect(adminActionCardExtent(620), 154);
  });

  test('admin quick actions use responsive column counts', () {
    expect(adminActionColumnCount(320), 1);
    expect(adminActionColumnCount(619), 1);
    expect(adminActionColumnCount(620), 2);
    expect(adminActionColumnCount(1039), 2);
    expect(adminActionColumnCount(1040), 3);
    expect(adminActionColumnCount(1920), 3);
  });

  testWidgets('compact admin statistic card has no overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 164,
              height: 132,
              child: AdminDashboardStatCard(
                title: 'Jumlah pengguna',
                value: '168',
                icon: Icons.people_outline,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('168'), findsOneWidget);
    expect(find.text('Jumlah pengguna'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
