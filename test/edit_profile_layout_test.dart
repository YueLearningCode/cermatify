import 'package:cermatify/app/modules/profile/views/edit_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 600, 1048]) {
    testWidgets('edit profile header has no overflow at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: EditProfileHeader(onBack: () {}),
            ),
          ),
        ),
      );

      expect(find.text('Edit profil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('edit profile fields switch between one and two columns', (
    tester,
  ) async {
    Future<void> pumpGrid(double width) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: const EditProfileFieldGrid(
                children: [
                  SizedBox(key: Key('first-field'), height: 50),
                  SizedBox(key: Key('second-field'), height: 50),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await pumpGrid(360);
    final mobileFirst = tester.getRect(find.byKey(const Key('first-field')));
    final mobileSecond = tester.getRect(find.byKey(const Key('second-field')));
    expect(mobileSecond.top, greaterThan(mobileFirst.bottom));

    await pumpGrid(900);
    final desktopFirst = tester.getRect(find.byKey(const Key('first-field')));
    final desktopSecond = tester.getRect(find.byKey(const Key('second-field')));
    expect(desktopSecond.left, greaterThan(desktopFirst.right));
    expect(desktopSecond.top, desktopFirst.top);
    expect(tester.takeException(), isNull);
  });
}
