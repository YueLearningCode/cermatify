import 'package:cermatify/app/modules/users/controllers/users_controller.dart';
import 'package:cermatify/app/modules/users/views/mentor_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mentor = UserData(
    id: 'mentor-1',
    name: 'Mentor Cermatify',
    email: 'mentor@example.com',
    role: 'mentor',
    verificationStatus: 'verified',
  );
  final user = UserData(
    id: 'user-1',
    name: 'Pengguna Cermatify',
    email: 'pengguna@example.com',
    role: 'customer',
  );

  Widget buildContent({
    required double width,
    required UserData account,
    required bool isMentor,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: AdminAccountDetailContent(
              account: account,
              data: const {
                'noTelp': '081234567890',
                'kampus': 'Universitas Cermatify',
                'jurusan': 'Teknologi Informasi',
                'semester': '6',
                'status': 'active',
                'mentorRole': 'paperlink',
                'layanan': ['Konsultasi', 'Pendampingan'],
                'linkedin': 'linkedin.com/in/mentor-cermatify',
              },
              isMentor: isMentor,
              isUpdating: false,
              onToggleVerification: () {},
              onOpenLinkedin: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  for (final width in <double>[360, 1100]) {
    testWidgets('mentor detail has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildContent(width: width, account: mentor, isMentor: true),
      );

      expect(find.text('Informasi mentor'), findsOneWidget);
      expect(find.text('Mentor terverifikasi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('regular user detail excludes mentor controls', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildContent(width: 390, account: user, isMentor: false),
    );

    expect(find.text('Akun pengguna'), findsOneWidget);
    expect(find.text('Informasi mentor'), findsNothing);
    expect(find.text('Verifikasi mentor'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
