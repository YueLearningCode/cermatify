import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/faq/views/faq_view.dart';
import 'package:cermatify/app/modules/kuesioner/views/data_user_kuesioner_view.dart';
import 'package:cermatify/app/modules/kuesioner/views/kuesioner_detail_view.dart';
import 'package:cermatify/app/modules/kuesioner/views/kuesioner_view.dart';
import 'package:cermatify/app/modules/mentor_home/views/mentor_home_view.dart';
import 'package:cermatify/app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mentor workspace breakpoints adapt across phone and desktop', () {
    expect(mentorMetricColumnCount(320), 1);
    expect(mentorMetricColumnCount(700), 2);
    expect(mentorMetricColumnCount(1200), 4);
    expect(faqColumnCount(700), 1);
    expect(faqColumnCount(1000), 2);
    expect(kuesionerColumnCount(700), 1);
    expect(kuesionerColumnCount(1100), 2);
    expect(kuesionerDetailColumnCount(700), 1);
    expect(kuesionerDetailColumnCount(1000), 2);
    expect(respondentFormColumnCount(700), 1);
    expect(respondentFormColumnCount(1000), 2);
  });

  for (final width in <double>[320, 620, 1100]) {
    testWidgets('mentor headers fit at ${width.toInt()} px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MentorWelcomeHeader(
                      name: 'Mentor Cermatify',
                      specialization: 'Mentor Cermat Paper',
                    ),
                    const SizedBox(height: 8),
                    const FaqHeader(questionCount: 5),
                    const SizedBox(height: 8),
                    KuesionerHeader(
                      itemCount: 4,
                      hasProfileData: true,
                      onRefresh: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Mentor Cermatify'), findsOneWidget);
      expect(find.text('Pusat bantuan mentor'), findsOneWidget);
      expect(find.text('Kuesioner'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mentor metric and profile balance fit narrow cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 142,
                  child: MentorMetricCard(
                    icon: Icons.work_outline,
                    value: '12',
                    label: 'Order aktif',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                MentorBalanceCard(balance: 250000, onWithdraw: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('questionnaire cards use natural height on desktop', (
    tester,
  ) async {
    final item = Kuesioner(
      id: 'q-1',
      createdAt: DateTime(2026, 8, 31),
      answers: [QuestionAnswer(question: 'Pertanyaan', answer: 'Jawaban')],
      status: 'approved',
      rentangUsia: '18-25 tahun',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 500,
              child: KuesionerUserCard(index: 0, item: item, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Kuesioner 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
