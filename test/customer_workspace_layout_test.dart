import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/mentor_discovery_layout.dart';
import 'package:cermatify/app/data/widgets/payment_checkout_widgets.dart';
import 'package:cermatify/app/data/widgets/workspace_page_header.dart';
import 'package:cermatify/app/modules/order/controllers/order_history_controller.dart';
import 'package:cermatify/app/modules/order/views/order_history_view.dart';
import 'package:cermatify/app/modules/paperlink/views/detail_mentor_view.dart';
import 'package:cermatify/app/modules/paperlink/views/list_mentor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('customer workspace chooses responsive columns', () {
    expect(discoveryColumnCount(700), 1);
    expect(discoveryColumnCount(1000), 2);
    expect(orderHistoryColumnCount(700), 1);
    expect(orderHistoryColumnCount(1000), 2);
    expect(mentorResultColumnCount(500), 1);
    expect(mentorResultColumnCount(800), 2);
    expect(mentorResultColumnCount(1200), 3);
    expect(mentorDetailColumnCount(700), 1);
    expect(mentorDetailColumnCount(1000), 2);
  });

  test('order status filter handles current and legacy values', () {
    expect(orderMatchesStatus({'status': 'pending'}, 'waiting'), isTrue);
    expect(orderMatchesStatus({'status': 'approved'}, 'progress'), isTrue);
    expect(orderMatchesStatus({'status': 'completed'}, 'rejected'), isFalse);
    expect(orderMatchesStatus({'status': 'anything'}, 'all'), isTrue);
  });

  for (final width in <double>[320, 760, 1100]) {
    testWidgets('shared workspace header fits at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: WorkspacePageHeader(
                  eyebrow: 'Layanan akademik',
                  title: 'Temukan mentor',
                  subtitle: 'Pilih layanan yang paling sesuai.',
                  onBack: () {},
                  trailing: const Icon(Icons.refresh_rounded),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Temukan mentor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('customer cards fit a narrow mobile viewport', (tester) async {
    final mentor = Mentor(
      id: 'mentor-1',
      name: 'Mentor Cermatify',
      kampus: 'Universitas Riau',
      jurusan: 'Sistem Informasi',
      layanan: 'Pendampingan karya ilmiah',
      image: '',
      email: 'mentor@example.com',
      bio: '',
      rating: 4.8,
      totalSessions: 12,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: MentorResultCard(mentor: mentor, onTap: () {}),
                  ),
                  const SizedBox(height: 10),
                  OrderHistoryCard(
                    order: const {
                      'id': 'order-123456789',
                      'price': 25000,
                      'mentorName': 'Mentor Cermatify',
                      'layananName': 'Pendampingan',
                    },
                    statusLabel: 'Menunggu verifikasi',
                    statusColor: AppColors.yellow2Color,
                    onProof: () {},
                  ),
                  const SizedBox(height: 10),
                  PaymentProofPanel(
                    bytes: null,
                    onGallery: () {},
                    onRemove: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Mentor Cermatify'), findsWidgets);
    expect(find.text('Bukti pembayaran'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
