import 'dart:async';
import 'package:cermatify/app/data/services/account_policy.dart';
import 'package:cermatify/app/data/widgets/account_policy_gate.dart';
import 'package:cermatify/app/modules/chat/views/chat_safety_controls.dart';
import 'package:cermatify/app/modules/moderation/views/admin_moderation_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'account eligibility fails closed for either disabled flag and unverified mentors',
    () {
      expect(AccountPolicy.canUseAccount(null), isFalse);
      expect(
        AccountPolicy.canUseAccount({'status': 'active', 'role': 'customer'}),
        isTrue,
      );
      expect(
        AccountPolicy.canUseAccount({
          'status': 'inactive',
          'accountStatus': 'active',
        }),
        isFalse,
      );
      expect(
        AccountPolicy.canUseAccount({
          'status': 'active',
          'accountStatus': 'disabled',
        }),
        isFalse,
      );
      for (final verification in [null, 'pending', 'rejected', 'unknown']) {
        expect(
          AccountPolicy.canUseAccount({
            'status': 'active',
            'role': 'mentor',
            'verificationStatus': verification,
          }),
          isFalse,
        );
      }
      expect(
        AccountPolicy.canUseAccount({
          'status': 'active',
          'role': 'mentor',
          'verificationStatus': 'verified',
        }),
        isTrue,
      );
    },
  );

  test('legacy accounts need explicit current-version adult consent', () {
    expect(AccountPolicy.hasConsent({}), isFalse);
    expect(
      AccountPolicy.hasConsent({
        'adultConfirmed': true,
        'termsVersion': 'old',
        'termsAcceptedAt': DateTime.now(),
      }),
      isFalse,
    );
    expect(
      AccountPolicy.hasConsent({
        'adultConfirmed': true,
        'termsVersion': AccountPolicy.version,
        'termsAcceptedAt': DateTime.now(),
      }),
      isTrue,
    );
  });

  testWidgets(
    'consent requires two unchecked declarations and keeps failures retryable',
    (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PolicyConsentForm(
              accept: () async {
                attempts++;
                if (attempts == 1) throw StateError('offline');
              },
              leave: () {},
              openTerms: () {},
              openPrivacy: () {},
            ),
          ),
        ),
      );
      FilledButton button() => tester.widget(
        find.widgetWithText(FilledButton, 'Setuju dan lanjutkan'),
      );
      expect(button().onPressed, isNull);
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.tap(find.byType(CheckboxListTile).last);
      await tester.pump();
      expect(button().onPressed, isNotNull);
      await tester.tap(find.text('Setuju dan lanjutkan'));
      await tester.pumpAndSettle();
      expect(
        find.text('Persetujuan belum tersimpan. Silakan coba lagi.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Setuju dan lanjutkan'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
    },
  );

  testWidgets(
    'report waits for server success, blocks double send and retains input on failure',
    (tester) async {
      var attempts = 0;
      var pending = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Open'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ChatReportDialog(
                    submit: (reason, details) {
                      attempts++;
                      expect(details, 'Bukti untuk admin');
                      return pending.future;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bukti untuk admin');
      await tester.tap(find.text('Kirim laporan'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Mengirim...'),
            )
            .onPressed,
        isNull,
      );
      expect(attempts, 1);
      pending.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(
        find.text('Laporan belum terkirim. Periksa koneksi dan coba lagi.'),
        findsOneWidget,
      );
      expect(find.text('Bukti untuk admin'), findsOneWidget);
      pending = Completer<void>();
      await tester.tap(find.text('Kirim laporan'));
      await tester.pump();
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ChatReportDialog), findsNothing);
      expect(attempts, 2);
    },
  );

  for (final width in [320.0, 800.0]) {
    testWidgets('safety controls and moderation evidence fit width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var blocked = false;
      var reported = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ChatSafetyControls(
                    blocked: false,
                    onBlock: () => blocked = true,
                    onReport: () => reported = true,
                  ),
                  ModerationReportCard(
                    id: 'report-id',
                    data: const {
                      'reason': 'Pelecehan atau ancaman',
                      'status': 'dismissed',
                      'reporterId': 'reporter',
                      'targetId': 'target',
                      'details':
                          'Laporan dengan penjelasan yang perlu diperiksa admin.',
                    },
                    onReview: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Blokir pengguna'));
      await tester.tap(find.text('Laporkan pengguna'));
      expect(blocked && reported, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
