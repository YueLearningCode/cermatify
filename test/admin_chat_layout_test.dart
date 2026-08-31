import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/modules/chat/views/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 620, 1100]) {
    testWidgets('admin chat header fits at ${width.toInt()} px', (
      tester,
    ) async {
      final searchController = TextEditingController();
      addTearDown(searchController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: ChatPageHeader(
                  isAdmin: true,
                  conversationCount: 12,
                  searchController: searchController,
                  onBack: () {},
                  onRefresh: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pesan dari pengguna'), findsOneWidget);
      expect(find.byKey(const Key('chat-search-field')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('conversation card remains compact and responds to tap', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: ChatConversationCard(
              chat: ChatMessage(
                id: 'room-1',
                senderId: 'user-1',
                receiverId: 'admin-1',
                message:
                    'Saya memerlukan bantuan terkait layanan Cermatify ini.',
                timestamp: DateTime(2026, 8, 31, 10),
                orderId: 'order-1',
              ),
              partnerName: 'Pengguna dengan nama yang panjang',
              isAdmin: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('chat-conversation-card')));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin empty state uses admin-specific guidance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 520,
            child: ChatEmptyState(
              isAdmin: true,
              isSearchResult: false,
              onRefresh: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Pesan bantuan dari pengguna akan tampil di halaman ini.'),
      findsOneWidget,
    );
    expect(find.textContaining('mentor'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
