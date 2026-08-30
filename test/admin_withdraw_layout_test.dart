import 'package:cermatify/app/data/models/withdraw_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/admin_withdraw/controllers/admin_withdraw_controller.dart';
import 'package:cermatify/app/modules/admin_withdraw/views/admin_withdraw_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('withdraw pagination is limited to eight cards', () {
    expect(AdminWithdrawController.pageSize, 8);
  });

  for (final width in <double>[320, 620, 1100]) {
    testWidgets('admin withdraw header fits at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: AdminWithdrawHeader(
                loadedCount: 8,
                onBack: () {},
                onRefresh: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pengelolaan withdraw'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pending mobile withdraw card exposes both actions', (
    tester,
  ) async {
    var selectedStatus = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: AdminWithdrawCard(
                withdraw: _withdraw(status: 'pending'),
                statusColor: AppColors.yellow2Color,
                statusText: 'Menunggu',
                isUpdating: false,
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

  testWidgets('withdraw load more button responds to tap', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminWithdrawLoadMoreButton(
            hasMore: true,
            hasWithdraws: true,
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

WithdrawModel _withdraw({required String status}) {
  return WithdrawModel(
    id: 'withdraw-1',
    mentorId: 'mentor-1',
    mentorName: 'Mentor Cermatify',
    nominal: 150000,
    namaRekening: 'Mentor Cermatify',
    nomorRekening: '1234567890',
    status: status,
    createdAt: DateTime(2026, 8, 30, 10, 30),
  );
}
