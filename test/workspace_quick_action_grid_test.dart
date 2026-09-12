import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/workspace_quick_action_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quick action grid selects columns from content width', () {
    expect(workspaceQuickActionColumnCount(320, 4), 1);
    expect(workspaceQuickActionColumnCount(639, 4), 1);
    expect(workspaceQuickActionColumnCount(640, 4), 2);
    expect(workspaceQuickActionColumnCount(1039, 6), 2);
    expect(workspaceQuickActionColumnCount(1040, 6), 3);
    expect(workspaceQuickActionColumnCount(1040, 4), 4);
  });

  for (final width in <double>[320, 640, 1040, 1200]) {
    testWidgets('quick action cards fit at ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorkspaceQuickActionGrid(
                actions: List.generate(
                  6,
                  (index) => WorkspaceQuickActionData(
                    title: 'Aksi $index',
                    subtitle: 'Deskripsi aksi yang tetap terbaca dengan rapi.',
                    icon: Icons.dashboard_outlined,
                    color: AppColors.primaryColor,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(WorkspaceQuickActionCard), findsNWidgets(6));
    });
  }
}
