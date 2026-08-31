import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/admin_kuesioner/controllers/admin_kuesioner_controller.dart';
import 'package:cermatify/app/modules/admin_kuesioner/views/admin_kuesioner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kuesioner pagination is limited to eight cards', () {
    expect(AdminKuesionerController.pageSize, 8);
  });

  test('waiting filter supports legacy pending status', () {
    expect(AdminKuesionerController.statusesForFilter('waiting verification'), [
      'waiting verification',
      'pending',
    ]);
  });

  for (final width in <double>[320, 620, 1100]) {
    testWidgets('admin kuesioner header fits at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: AdminKuesionerHeader(
                loadedCount: 8,
                onBack: () {},
                onRefresh: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pengelolaan kuesioner'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('waiting kuesioner actions fit and respond at 320 px', (
    tester,
  ) async {
    var selectedStatus = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: AdminKuesionerCard(
                item: _item(status: 'waiting verification'),
                statusColor: AppColors.yellow2Color,
                statusText: 'Menunggu verifikasi',
                isUpdating: false,
                onViewDetail: () {},
                onStatusChanged: (value) => selectedStatus = value,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Setujui'));
    expect(selectedStatus, 'approved');
    expect(tester.takeException(), isNull);
  });

  testWidgets('kuesioner card fits desktop grid extent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 390,
            child: AdminKuesionerCard(
              item: _item(status: 'waiting verification'),
              statusColor: AppColors.yellow2Color,
              statusText: 'Menunggu verifikasi',
              isUpdating: false,
              onViewDetail: () {},
              onStatusChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop detail button stays close to questionnaire criteria', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 390,
            child: AdminKuesionerCard(
              item: _item(status: 'approved'),
              statusColor: AppColors.greenColor,
              statusText: 'Disetujui',
              isUpdating: false,
              onViewDetail: () {},
              onStatusChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final criteriaBottom = tester.getBottomRight(find.text('S1/D4')).dy;
    final detailTop = tester.getTopLeft(find.text('Lihat detail')).dy;
    expect(detailTop - criteriaBottom, lessThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail dialog fits a narrow viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminKuesionerDetailDialog(item: _item(status: 'approved')),
        ),
      ),
    );

    expect(find.text('Detail kuesioner'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('load more button responds to tap', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminKuesionerLoadMoreButton(
            hasMore: true,
            hasItems: true,
            isLoading: false,
            onLoadMore: () => calls++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tampilkan lebih banyak'));
    expect(calls, 1);
  });
}

AdminKuesionerItem _item({required String status}) {
  return AdminKuesionerItem(
    kuesioner: Kuesioner(
      id: 'kuesioner-123456789',
      createdAt: DateTime(2026, 8, 31, 10, 30),
      answers: const [],
      status: status,
      userId: 'user-1',
      orderId: 'order-1',
      link: 'https://forms.example.com/kuesioner-yang-panjang',
      rentangUsia: '18-25 tahun',
      jenisKelamin: 'Perempuan',
      tingkatPenghasilan: 'Rp 2.000.000 - Rp 5.000.000',
      pendidikanTerakhir: 'S1/D4',
    ),
    userName: 'Pengguna dengan nama yang sangat panjang',
    respondentCount: 128,
  );
}
