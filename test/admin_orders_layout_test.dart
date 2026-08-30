import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/admin_orders/views/admin_orders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 620, 1100]) {
    testWidgets('admin orders header fits at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: AdminOrdersHeader(
                loadedCount: 20,
                onBack: () {},
                onRefresh: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pengelolaan order'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('waiting order actions fit on a narrow card', (tester) async {
    var selectedStatus = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 420,
            child: AdminOrderCard(
              order: const {
                'id': '1234567890',
                'status': 'waiting verification',
                'price': 25000,
                'userName': 'Pengguna dengan nama yang sangat panjang',
                'mentorName': 'Mentor Cermatify',
                'layananName': 'Pendampingan akademik',
                'paymentProofUrl': 'https://example.com/proof.jpg',
              },
              statusColor: AppColors.yellow2Color,
              statusText: 'Menunggu verifikasi',
              isUpdating: false,
              onViewPayment: () {},
              onStatusChanged: (value) => selectedStatus = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Verifikasi'));
    expect(selectedStatus, 'progress');
    expect(tester.takeException(), isNull);
  });

  testWidgets('progress order exposes complete action', (tester) async {
    var selectedStatus = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 338,
            child: AdminOrderCard(
              order: const {
                'id': 'abcdefghij',
                'status': 'progress',
                'price': 25000,
                'userName': 'Pengguna',
                'mentorName': 'Mentor',
                'layananName': 'Kuesioner',
              },
              statusColor: AppColors.greenColor,
              statusText: 'Sedang diproses',
              isUpdating: false,
              onStatusChanged: (value) => selectedStatus = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tandai selesai'));
    expect(selectedStatus, 'completed');
    expect(tester.takeException(), isNull);
  });
}
