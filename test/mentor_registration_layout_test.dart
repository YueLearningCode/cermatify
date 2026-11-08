import 'package:cermatify/app/data/widgets/responsive_layout.dart';
import 'package:cermatify/app/modules/register/widgets/mentor_registration_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mentor submission is disabled while loading', (tester) async {
    var submissions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentorSubmissionButton(
            isLoading: true,
            onSubmit: () => submissions++,
          ),
        ),
      ),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Memproses...'));
    expect(submissions, 0);
  });

  Future<void> pumpPage(
    WidgetTester tester,
    double width, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ResponsiveAuthShell(
              title: 'Mentor Cermatify',
              description: 'Pendaftaran mentor',
              alignTop: true,
              visualPanel: const MentorRecruitmentPanel(),
              mobileIntroduction: const MentorRecruitmentPanel(compact: true),
              form: MentorRegistrationFormSurface(
                enabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const MentorRegistrationHeader(),
                    const MentorFormSection(
                      number: '01',
                      title: 'Informasi akun',
                      description: 'Gunakan email aktif.',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                      ),
                    ),
                    const SizedBox(height: 1000),
                    MentorSubmissionButton(isLoading: false, onSubmit: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 375.0, 768.0, 1024.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'mentor recruitment layout fits $width px with text scale $scale',
        (tester) async {
          await pumpPage(tester, width, textScale: scale);
          expect(find.text('Daftar sebagai mentor'), findsOneWidget);
          expect(
            find.byKey(
              ValueKey(
                width >= 1024 ? 'mentor-intro-desktop' : 'mentor-intro-mobile',
              ),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'desktop information and form start together even when form is long',
    (tester) async {
      await pumpPage(tester, 1440);
      final panel = tester.getRect(
        find.byKey(const ValueKey('mentor-intro-desktop')),
      );
      final form = tester.getRect(
        find.byKey(const ValueKey('mentor-registration-form')),
      );
      expect(panel.top, closeTo(form.top, 1));
      expect(panel.top, lessThan(40));
      expect(find.text('Peluang pendapatan dari mentoring'), findsOneWidget);
      expect(find.textContaining('tidak dijamin'), findsOneWidget);
    },
  );

  testWidgets(
    'mobile requirements expand without hiding the registration form',
    (tester) async {
      await pumpPage(tester, 375, textScale: 2);
      final requirements = find.text('Persyaratan & seleksi');
      await tester.ensureVisible(requirements);
      await tester.tap(requirements);
      await tester.pumpAndSettle();
      expect(find.text('Berusia 18 tahun atau lebih'), findsOneWidget);
      expect(find.textContaining('Semester 5 menjadi acuan'), findsOneWidget);
      expect(find.textContaining('tanpa joki tugas'), findsOneWidget);
      expect(find.text('Daftar sebagai mentor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
