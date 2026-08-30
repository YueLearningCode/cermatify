import 'package:cermatify/app/data/widgets/responsive_navigation_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildShell() {
    return MaterialApp(
      home: ResponsiveNavigationScaffold(
        body: const Text('Content'),
        selectedIndex: 0,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
        onDestinationSelected: (_) {},
        mobileNavigation: BottomNavigationBar(
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  testWidgets('uses bottom navigation on mobile', (tester) async {
    tester.view.physicalSize = const Size(599, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildShell());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses navigation rail from tablet breakpoint', (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildShell());

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('desktop scrollable reaches the viewport right edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveNavigationScaffold(
          body: const SingleChildScrollView(
            child: SizedBox(height: 1600, child: Text('Scrollable content')),
          ),
          selectedIndex: 0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('Profile'),
            ),
          ],
          onDestinationSelected: (_) {},
          mobileNavigation: const SizedBox.shrink(),
        ),
      ),
    );

    final scrollableRect = tester.getRect(find.byType(SingleChildScrollView));
    expect(scrollableRect.right, closeTo(1920, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('extra actions only appear on expanded desktop sidebar', (
    tester,
  ) async {
    var selectedAction = -1;
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget buildDesktopShell() {
      return MaterialApp(
        home: ResponsiveNavigationScaffold(
          body: const Text('Content'),
          selectedIndex: 0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              label: Text('Profile'),
            ),
          ],
          desktopDestinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              label: Text('Orders'),
            ),
          ],
          onDestinationSelected: (_) {},
          onDesktopDestinationSelected: (index) => selectedAction = index,
          mobileNavigation: const SizedBox.shrink(),
        ),
      );
    }

    await tester.pumpWidget(buildDesktopShell());
    expect(find.text('Orders'), findsNothing);

    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpWidget(buildDesktopShell());
    expect(find.text('Orders'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    expect(selectedAction, 0);
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[320, 375, 768, 1024, 1366, 1920]) {
    testWidgets('lays out without exceptions at ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildShell());

      expect(tester.takeException(), isNull);
    });
  }
}
