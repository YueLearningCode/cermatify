import 'package:cermatify/app/modules/users/controllers/users_controller.dart';
import 'package:cermatify/app/modules/users/views/users_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin users grid adapts to available width', () {
    expect(adminUsersColumnCount(420), 1);
    expect(adminUsersColumnCount(760), 2);
    expect(adminUsersColumnCount(1280), 3);
  });

  for (final width in <double>[280, 380, 520]) {
    testWidgets('user card has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                height: 112,
                child: AdminUserCard(
                  user: UserData(
                    id: 'user-1',
                    name: 'Pengguna dengan nama yang sangat panjang',
                    email: 'pengguna.dengan.email.panjang@example.com',
                    role: 'customer',
                  ),
                  isMentor: false,
                  isUpdating: false,
                  onToggleMentor: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pengguna'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mentor controls fit inside a narrow card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 126,
              child: AdminUserCard(
                user: UserData(
                  id: 'mentor-1',
                  name: 'Mentor Cermatify',
                  email: 'mentor@example.com',
                  role: 'mentor',
                  verificationStatus: 'verified',
                ),
                isMentor: true,
                isUpdating: false,
                onToggleMentor: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Terverifikasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
