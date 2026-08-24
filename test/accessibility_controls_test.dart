import 'package:cermatify/app/data/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('custom button exposes semantics and works from keyboard', (
    tester,
  ) async {
    var activationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            onTap: () => activationCount++,
            height: 48,
            color: Colors.blue,
            widget: const Center(child: Text('Lanjutkan')),
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.text('Lanjutkan'));
    expect(semantics.flagsCollection.isButton, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activationCount, 1);
  });
}
