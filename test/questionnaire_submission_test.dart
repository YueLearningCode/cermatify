import 'package:cermatify/app/modules/kuesioner/views/kuesioner_detail_view.dart';
import 'package:cermatify/app/modules/kuesioner/views/questionnaire_link_step.dart';
import 'package:cermatify/app/modules/paperlink/views/detail_mentor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('survey links reject empty, insecure and credential-bearing URLs', () {
    for (final invalid in [
      '',
      'forms.example/survey',
      'http://forms.example/survey',
      'javascript:alert(1)',
      'https://',
      'https://name:password@forms.example/survey',
      'https://forms.example/sur vey',
      'https://forms.example/${'a' * 2048}',
    ]) {
      expect(validateQuestionnaireLink(invalid), isNotNull, reason: invalid);
    }
    expect(
      validateQuestionnaireLink(' https://forms.example/survey?id=123 '),
      isNull,
    );
  });

  testWidgets('checkout cannot continue before a valid survey URL is entered', (
    tester,
  ) async {
    final submitted = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuestionnaireLinkStep(
              initialLink: '',
              onContinue: submitted.add,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Lanjut ke pembayaran'));
    await tester.pump();
    expect(submitted, isEmpty);
    expect(find.text('Masukkan tautan kuesioner.'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField),
      'http://forms.example/survey',
    );
    await tester.tap(find.text('Lanjut ke pembayaran'));
    await tester.pump();
    expect(submitted, isEmpty);
    await tester.enterText(
      find.byType(TextFormField),
      ' https://forms.example/survey ',
    );
    await tester.tap(find.text('Lanjut ke pembayaran'));
    await tester.pump();
    expect(submitted, ['https://forms.example/survey']);
  });

  testWidgets('new respondents cannot enroll or claim unverified funds', (
    tester,
  ) async {
    var copied = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KuesionerAccessCard(
            link: 'https://forms.example/survey',
            isCreator: false,
            alreadySigned: false,
            respondentCount: 5,
            onCopy: (_) => copied = true,
          ),
        ),
      ),
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text('Salin tautan'), findsNothing);
    expect(find.text('Reward belum tersedia'), findsOneWidget);
    expect(find.text('5 pendaftaran tercatat'), findsOneWidget);
    await tester.tap(find.text('Pendaftaran belum tersedia'));
    expect(copied, isFalse);
  });

  for (final owner in [true, false]) {
    testWidgets(
      'existing ${owner ? 'owner' : 'participant'} retains copy-only access',
      (tester) async {
        String? copied;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KuesionerAccessCard(
                link: 'https://forms.example/survey',
                isCreator: owner,
                alreadySigned: !owner,
                respondentCount: 1,
                onCopy: (link) => copied = link,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Salin tautan'));
        expect(copied, 'https://forms.example/survey');
        expect(find.text('Reward belum tersedia'), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
      },
    );
  }

  testWidgets('an existing participant cannot copy an absent link', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KuesionerAccessCard(
            link: '',
            isCreator: false,
            alreadySigned: true,
            respondentCount: 1,
            onCopy: (_) => fail('No URL should be copied'),
          ),
        ),
      ),
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
  });

  for (final width in [320.0, 1024.0]) {
    testWidgets('survey and meeting information fit $width px at 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  KuesionerAccessCard(
                    link: '',
                    isCreator: false,
                    alreadySigned: false,
                    respondentCount: 0,
                    onCopy: (_) {},
                  ),
                  const MentorMeetingNotice(),
                  QuestionnaireLinkStep(initialLink: '', onContinue: (_) {}),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
