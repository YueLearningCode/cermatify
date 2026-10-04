import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/modules/chat/views/chat_room_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage message({
  String sender = 'mentor',
  String receiver = 'customer',
  DateTime? readAt,
}) => ChatMessage(
  id: 'message',
  senderId: sender,
  receiverId: receiver,
  message:
      'Pesan panjang untuk memastikan bubble tetap berada dalam layar ponsel sempit.',
  timestamp: DateTime(2026, 10, 4),
  readAt: readAt,
);

void main() {
  test(
    'badge eligibility excludes outgoing, other recipients and read messages',
    () {
      expect(message().isUnreadFor('customer'), isTrue);
      expect(message().isUnreadFor('mentor'), isFalse);
      expect(message().isUnreadFor('other'), isFalse);
      expect(message().isUnreadFor(''), isFalse);
      expect(message(sender: 'customer').isUnreadFor('customer'), isFalse);
      expect(
        message(readAt: DateTime(2026, 10, 4)).isUnreadFor('customer'),
        isFalse,
      );
    },
  );

  test('read receipt survives model serialization', () {
    final original = message(readAt: DateTime(2026, 10, 4, 10));
    expect(ChatMessage.fromJson(original.toJson()).readAt, original.readAt);
    expect(
      ChatMessage.fromJson(message().toJson()).isUnreadFor('customer'),
      isTrue,
    );
  });

  for (final width in [160.0, 284.0, 664.0, 1064.0]) {
    testWidgets('incoming and outgoing bubbles fit $width available pixels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width + 36, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChatMessageBubble(
                      message: message(),
                      isMine: false,
                      partnerName: 'Mentor',
                    ),
                    ChatMessageBubble(
                      message: message(),
                      isMine: true,
                      partnerName: 'Mentor',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final bubbles = find.byType(ChatMessageBubble);
      expect(tester.getSize(bubbles.first).width, width);
      expect(tester.getSize(bubbles.last).width, width);
    });
  }

  for (final width in [320.0, 700.0, 1100.0]) {
    testWidgets('composer remains above keyboard at $width pixels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final textController = TextEditingController(text: 'Pesan');
      final focusNode = FocusNode();
      addTearDown(textController.dispose);
      addTearDown(focusNode.dispose);
      var sends = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  ChatRoomHeader(
                    displayName: 'Nama mentor yang panjang',
                    isAdmin: false,
                    onBack: () {},
                  ),
                  const Expanded(child: SizedBox()),
                  ChatMessageComposer(
                    textController: textController,
                    focusNode: focusNode,
                    compact: width < 600,
                    isSending: false,
                    onSend: () => sends++,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final send = find.byKey(const Key('send-chat-button'));
      expect(tester.getRect(send).bottom, lessThanOrEqualTo(440));
      expect(
        tester.getRect(find.byKey(const Key('chat-message-field'))).bottom,
        lessThanOrEqualTo(440),
      );
      await tester.tap(send);
      expect(sends, 1);
    });
  }
}
