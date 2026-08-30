import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[340, 720, 1100]) {
    testWidgets('admin profile hero has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: AdminProfileHero(
                name: 'Admin Cermatify dengan Nama Panjang',
                email: 'admin.cermatify@example.com',
                imageUrl: '',
                campus: 'Universitas Cermatify Indonesia',
                onChangePhoto: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Administrator aktif'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('profile information grid and account actions are responsive', (
    tester,
  ) async {
    var edited = 0;
    var changedPassword = 0;
    var loggedOut = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(
                children: [
                  const AdminProfileInfoGrid(
                    items: [
                      AdminProfileInfo(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: 'admin@example.com',
                        color: AppColors.primaryColor,
                      ),
                      AdminProfileInfo(
                        icon: Icons.verified_user_outlined,
                        label: 'Status akun',
                        value: 'Aktif',
                        color: AppColors.greenColor,
                      ),
                    ],
                  ),
                  AdminProfileActions(
                    onEdit: () => edited++,
                    onChangePassword: () => changedPassword++,
                    onLogout: () => loggedOut++,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit profil'));
    await tester.tap(find.text('Ubah kata sandi'));
    await tester.tap(find.text('Logout'));
    expect(edited, 1);
    expect(changedPassword, 1);
    expect(loggedOut, 1);
    expect(tester.takeException(), isNull);
  });
}
