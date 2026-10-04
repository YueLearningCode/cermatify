import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/data/services/session_state.dart';
import '../../home/controllers/home_controller.dart';

class ChatContact {
  const ChatContact({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? imageUrl;
}

class ChatController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final allChats = <ChatMessage>[].obs;
  final filteredChats = <ChatMessage>[].obs;
  final chatMessages = <ChatMessage>[].obs;
  final isSearching = false.obs;
  final isTyping = false.obs;
  final isSending = false.obs;
  final isLoadingChats = true.obs;
  final isLoadingContacts = false.obs;
  final isLoadingMessages = false.obs;
  final chatLoadError = ''.obs;
  final messageLoadError = ''.obs;
  final RxInt chatRoomCount = 0.obs;
  final unreadMessageCount = 0.obs;
  final readStatusError = ''.obs;
  final adminContacts = <ChatContact>[].obs;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Cache of userId -> display name
  final RxMap<String, String> userNames = <String, String>{}.obs;
  String getUserName(String userId) =>
      userNames[userId] ?? (isAdmin ? 'Pengguna Cermatify' : 'Mentor');

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      throw StateError('Silakan login kembali.');
    }
  }

  String buildRoomId(String mentorId, {String? orderId}) {
    if (orderId != null && orderId.isNotEmpty) {
      // Chat room based on orderId: userId_mentorId_orderId
      final List<String> ids = [currentUserId, mentorId]..sort();
      return '${ids[0]}_${ids[1]}_$orderId';
    }
    // Legacy: Chat room without orderId (for backward compatibility)
    final List<String> ids = [currentUserId, mentorId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterChats);
    _chatUserId = currentUserId;
    _authSubscription = _auth.authStateChanges().listen((user) {
      final userId = user?.uid ?? '';
      if (_chatUserId == userId) return;
      _chatUserId = userId;
      _roomsSubscription?.cancel();
      _ordersSubscription?.cancel();
      _badgeRoomsSubscription?.cancel();
      for (final subscription in _unreadSubscriptions.values) {
        subscription.cancel();
      }
      _unreadSubscriptions.clear();
      _unreadCounts.clear();
      unreadMessageCount.value = 0;
      chatRoomCount.value = 0;
      allChats.clear();
      filteredChats.clear();
      _roomChats.clear();
      _mentorOrderChats.clear();
      userNames.clear();
      adminContacts.clear();
      closeMessages();
      if (user != null) unawaited(_initializeChats());
    });
    unawaited(_initializeChats());
  }

  Future<void> _initializeChats() async {
    final userId = currentUserId;
    isLoadingChats.value = true;
    chatLoadError.value = '';
    try {
      await ensureSignedIn();
      if (isClosed || currentUserId != userId) return;
      _watchUnreadMessages();
      if (isAdmin) await loadAdminContacts();
      if (isClosed || currentUserId != userId) return;
      loadChats();
    } catch (_) {
      isLoadingChats.value = false;
      chatLoadError.value = 'Percakapan belum dapat dimuat.';
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_filterChats);
    searchController.dispose();
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _roomsSubscription?.cancel();
    _ordersSubscription?.cancel();
    _messagesSubscription?.cancel();
    _badgeRoomsSubscription?.cancel();
    _authSubscription?.cancel();
    for (final subscription in _unreadSubscriptions.values) {
      subscription.cancel();
    }
    super.onClose();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _roomsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _messagesSubscription;
  String? _activeRoomId;
  String _chatUserId = '';
  StreamSubscription<User?>? _authSubscription;
  bool _roomVisible = false;
  bool _markingRead = false;
  final _readMessageIds = <String>{};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _badgeRoomsSubscription;
  final _unreadSubscriptions =
      <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
  final _unreadCounts = <String, int>{};

  // Query each participant room, including legacy messages without readAt.
  // This uses existing member permissions and needs no collection-group index.
  void _watchUnreadMessages() {
    final userId = currentUserId;
    _badgeRoomsSubscription = _firestore
        .collection('chatRooms')
        .where('users', arrayContains: userId)
        .snapshots()
        .listen(
          (snapshot) {
            if (currentUserId != userId || isClosed) return;
            final roomIds = snapshot.docs.map((doc) => doc.id).toSet();
            for (final id in _unreadSubscriptions.keys.toList()) {
              if (!roomIds.contains(id)) {
                _unreadSubscriptions.remove(id)?.cancel();
                _unreadCounts.remove(id);
              }
            }
            for (final id in roomIds) {
              if (_unreadSubscriptions.containsKey(id)) continue;
              _unreadSubscriptions[id] = _firestore
                  .collection('chatRooms')
                  .doc(id)
                  .collection('messages')
                  .where('receiverId', isEqualTo: userId)
                  .snapshots()
                  .listen(
                    (messages) {
                      if (currentUserId != userId || isClosed) return;
                      _unreadCounts[id] = messages.docs.where((doc) {
                        final data = doc.data();
                        return data['senderId'] != userId &&
                            data['readAt'] == null;
                      }).length;
                      unreadMessageCount.value = _unreadCounts.values.fold(
                        0,
                        (total, unread) => total + unread,
                      );
                    },
                    onError: (_) {
                      chatLoadError.value = 'Status pesan belum dapat dimuat.';
                    },
                  );
            }
            unreadMessageCount.value = _unreadCounts.values.fold(
              0,
              (total, unread) => total + unread,
            );
          },
          onError: (_) {
            chatLoadError.value = 'Status pesan belum dapat dimuat.';
          },
        );
  }

  void closeMessages() {
    _roomVisible = false;
    _activeRoomId = null;
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    chatMessages.clear();
    _readMessageIds.clear();
  }

  void setRoomVisible(bool visible) {
    _roomVisible = visible;
    if (visible) unawaited(markMessagesRead());
  }

  Future<void> markMessagesRead() async {
    final roomId = _activeRoomId;
    if (!_roomVisible || roomId == null || _markingRead) return;
    final incoming = chatMessages
        .where(
          (message) =>
              message.isUnreadFor(currentUserId) &&
              !_readMessageIds.contains(message.id),
        )
        .toList();
    if (incoming.isEmpty) return;
    _markingRead = true;
    readStatusError.value = '';
    try {
      // Stay below Firestore's batch limit; never update outgoing messages.
      for (var start = 0; start < incoming.length; start += 400) {
        final references = incoming
            .skip(start)
            .take(400)
            .map(
              (message) => _firestore
                  .collection('chatRooms')
                  .doc(roomId)
                  .collection('messages')
                  .doc(message.id),
            )
            .toList();
        await _firestore.runTransaction((transaction) async {
          final snapshots = await Future.wait(references.map(transaction.get));
          for (final snapshot in snapshots) {
            final data = snapshot.data();
            if (data != null &&
                data['receiverId'] == currentUserId &&
                data['senderId'] != currentUserId &&
                data['readAt'] == null) {
              transaction.update(snapshot.reference, {
                'readAt': FieldValue.serverTimestamp(),
              });
            }
          }
        });
        if (_activeRoomId == roomId) {
          _readMessageIds.addAll(
            incoming.skip(start).take(400).map((message) => message.id),
          );
        }
      }
    } catch (_) {
      readStatusError.value =
          'Status baca gagal disimpan. Ketuk untuk mencoba lagi.';
    } finally {
      _markingRead = false;
      if (readStatusError.value.isEmpty) unawaited(markMessagesRead());
    }
  }

  bool get isAdmin => SessionState.role == 'admin';

  // Check if current user is a mentor
  bool get isMentor {
    try {
      return SessionState.role == 'mentor' ||
          (Get.isRegistered<HomeController>() &&
              Get.find<HomeController>().isMentor.value);
    } catch (_) {
      return false;
    }
  }

  void loadChats() {
    isLoadingChats.value = true;
    chatLoadError.value = '';
    if (isMentor) {
      // Mentors serve customers from orders in progress.
      _loadCustomerChats(includeEmptyRooms: true);
      _loadMentorChats();
    } else if (isAdmin) {
      // Admin support rooms are rooms where the admin is a participant.
      _loadCustomerChats(includeEmptyRooms: true);
    } else {
      // For customers: load existing chat rooms
      _loadCustomerChats();
    }
  }

  void _loadCustomerChats({bool includeEmptyRooms = false}) {
    _roomsSubscription?.cancel();
    _roomsSubscription = _firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .listen(
          (snapshot) {
            final chats = snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  final List<dynamic> users =
                      (data['users'] as List<dynamic>? ?? []);
                  final String lastSenderId =
                      data['lastSenderId'] as String? ?? '';
                  final String storedMessage =
                      data['lastMessage'] as String? ?? '';
                  final String lastMessage = storedMessage.isNotEmpty
                      ? storedMessage
                      : 'Percakapan baru';
                  final DateTime ts =
                      (data['updatedAt'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  // partner is the other user in the room
                  final String partnerId = users
                      .map((e) => e.toString())
                      .firstWhere(
                        (id) => id != currentUserId,
                        orElse: () => '',
                      );
                  final String receiverId = lastSenderId == currentUserId
                      ? partnerId
                      : currentUserId;
                  final String? orderId = data['orderId'] as String?;
                  return ChatMessage(
                    id: doc.id,
                    senderId: lastSenderId.isNotEmpty
                        ? lastSenderId
                        : partnerId,
                    receiverId: receiverId,
                    message: lastMessage,
                    timestamp: ts,
                    orderId: orderId,
                  );
                })
                .where(
                  (chat) =>
                      includeEmptyRooms || chat.message != 'Percakapan baru',
                )
                .toList();

            chats.sort(
              (first, second) => second.timestamp.compareTo(first.timestamp),
            );

            _roomChats
              ..clear()
              ..addAll(chats);
            _publishChats();
            isLoadingChats.value = false;
          },
          onError: (_) {
            isLoadingChats.value = false;
            chatLoadError.value = 'Percakapan belum dapat dimuat.';
          },
        );
  }

  Future<void> loadAdminContacts() async {
    if (!isAdmin || isLoadingContacts.value) return;
    isLoadingContacts.value = true;
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .get();
      final contacts =
          snapshot.docs.map((document) {
            final data = document.data();
            final name =
                data['nama']?.toString() ??
                data['namaLengkap']?.toString() ??
                'Pengguna Cermatify';
            return ChatContact(
              id: document.id,
              name: name,
              email: data['email']?.toString() ?? '',
              imageUrl: (data['image'] ?? data['foto'])?.toString(),
            );
          }).toList()..sort(
            (first, second) =>
                first.name.toLowerCase().compareTo(second.name.toLowerCase()),
          );
      adminContacts.assignAll(contacts);
      for (final contact in contacts) {
        userNames[contact.id] = contact.name;
      }
    } catch (_) {
      adminContacts.clear();
    } finally {
      isLoadingContacts.value = false;
    }
  }

  final _mentorOrderChats = <ChatMessage>[];
  final _roomChats = <ChatMessage>[];

  void _publishChats() {
    final byRoom = {for (final chat in _mentorOrderChats) chat.id: chat};
    // Existing rooms win over order placeholders, including finished orders.
    for (final chat in _roomChats) {
      byRoom[chat.id] = chat;
    }
    final chats = byRoom.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    allChats.assignAll(chats);
    chatRoomCount.value = chats.length;
    _hydratePartnerNames(chats);
    _applySearchFilter();
  }

  void _loadMentorChats() {
    _ordersSubscription?.cancel();
    _ordersSubscription = _firestore
        .collection('orders')
        .where('mentorId', isEqualTo: currentUserId)
        .snapshots()
        .listen(
          (snapshot) {
            _mentorOrderChats.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              if (![
                'progress',
                'approved',
              ].contains(data['status']?.toString().toLowerCase())) {
                continue;
              }
              final customerId = data['userId']?.toString() ?? '';
              if (customerId.isEmpty || customerId == currentUserId) continue;
              _mentorOrderChats.add(
                ChatMessage(
                  id: buildRoomId(customerId, orderId: doc.id),
                  senderId: customerId,
                  receiverId: currentUserId,
                  message: 'Order sedang berlangsung',
                  timestamp:
                      (data['updatedAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                  orderId: doc.id,
                ),
              );
            }
            _publishChats();
            isLoadingChats.value = false;
          },
          onError: (_) {
            isLoadingChats.value = false;
            chatLoadError.value = 'Percakapan belum dapat dimuat.';
          },
        );
  }

  void _filterChats() {
    _applySearchFilter();
  }

  Future<void> _hydratePartnerNames(List<ChatMessage> chats) async {
    final Set<String> idsToFetch = chats
        .map((c) => c.senderId == currentUserId ? c.receiverId : c.senderId)
        .where((id) => id.isNotEmpty && !userNames.containsKey(id))
        .toSet();
    for (final userId in idsToFetch) {
      try {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data();
          final String displayName =
              (data?['nama'] as String?) ??
              (data?['name'] as String?) ??
              (isAdmin ? 'Pengguna Cermatify' : 'Mentor');
          userNames[userId] = displayName;
        } else {
          userNames[userId] = isAdmin ? 'Pengguna Cermatify' : 'Mentor';
        }
      } catch (_) {
        userNames[userId] = isAdmin ? 'Pengguna Cermatify' : 'Mentor';
      }
    }
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      isSearching.value = false;
      filteredChats.value = List<ChatMessage>.from(allChats);
      return;
    }
    isSearching.value = true;
    filteredChats.value = allChats.where((chat) {
      final partnerId = chat.senderId == currentUserId
          ? chat.receiverId
          : chat.senderId;
      final partnerName = getUserName(partnerId).toLowerCase();
      return chat.message.toLowerCase().contains(query) ||
          partnerId.toLowerCase().contains(query) ||
          partnerName.contains(query);
    }).toList();
  }

  void loadMessages(String mentorId, {String? orderId}) {
    _roomVisible = true;
    final userId = currentUserId;
    final String roomId = buildRoomId(mentorId, orderId: orderId);
    if (_activeRoomId == roomId &&
        _messagesSubscription != null &&
        messageLoadError.value.isEmpty) {
      return;
    }
    _activeRoomId = roomId;
    _readMessageIds.clear();
    isLoadingMessages.value = true;
    messageLoadError.value = '';
    chatMessages.clear();
    // Bind realtime stream from Firestore
    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen(
          (snapshot) {
            if (isClosed || _activeRoomId != roomId || currentUserId != userId) {
              return;
            }
            final msgs = snapshot.docs.map((d) {
              final data = d.data();
              return ChatMessage(
                id: d.id,
                senderId: data['senderId'] as String? ?? '',
                receiverId: data['receiverId'] as String? ?? '',
                message: data['message'] as String? ?? '',
                timestamp:
                    (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                readAt: (data['readAt'] as Timestamp?)?.toDate(),
              );
            }).toList();
            chatMessages.value = msgs;
            isLoadingMessages.value = false;
            scrollToBottom();
            unawaited(markMessagesRead());
          },
          onError: (_) {
            isLoadingMessages.value = false;
            messageLoadError.value = 'Pesan belum dapat dimuat.';
          },
        );
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void simulateTypingIndicator() {
    isTyping.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isRegistered<ChatController>()) {
        isTyping.value = false;
      }
    });
  }

  Future<void> sendMessage(String mentorId, {String? orderId}) async {
    if (isSending.value || messageController.text.trim().isEmpty) return;
    if (mentorId.isEmpty ||
        mentorId == currentUserId ||
        currentUserId.isEmpty) {
      return;
    }

    final messageText = messageController.text.trim();
    messageController.clear();

    isSending.value = true;
    try {
      final String roomId = await createOrGetChatRoom(
        mentorId: mentorId,
        orderId: orderId,
      );
      final roomRef = _firestore.collection('chatRooms').doc(roomId);
      final batch = _firestore.batch();
      batch.set(roomRef, {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': messageText,
        'lastSenderId': currentUserId,
      }, SetOptions(merge: true));

      final msgRef = roomRef.collection('messages').doc();
      final now = DateTime.now();
      batch.set(msgRef, {
        'senderId': currentUserId,
        'receiverId': mentorId,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'localTime': now.toIso8601String(),
        'readAt': null,
      });
      await batch.commit();

      Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
    } catch (_) {
      if (messageController.text.isEmpty) {
        messageController.text = messageText;
      }
      Get.snackbar(
        'Pesan gagal dikirim',
        'Periksa koneksi lalu coba kembali.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  // No auto-response: all messages should come from real users

  void toggleSearch() {
    if (isSearching.value) {
      searchController.clear();
      isSearching.value = false;
    } else {
      isSearching.value = true;
    }
  }

  Future<String> createOrGetChatRoom({
    required String mentorId,
    String? orderId,
  }) async {
    await ensureSignedIn();
    if (mentorId.isEmpty || mentorId == currentUserId) {
      throw StateError('Penerima chat tidak valid.');
    }
    final String userId = currentUserId;
    final String roomId = buildRoomId(mentorId, orderId: orderId);

    final DocumentReference<Map<String, dynamic>> roomRef = _firestore
        .collection('chatRooms')
        .doc(roomId);

    final List<String> ids = [userId, mentorId]..sort();

    final roomData = {
      'roomId': roomId,
      'users': ids,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Add orderId to room data if provided
    if (orderId != null && orderId.isNotEmpty) {
      roomData['orderId'] = orderId;
    }

    // Reading an absent room is denied by member-only rules. Merge identity
    // first, without resetting any existing messages or preview metadata.
    await roomRef.set(roomData, SetOptions(merge: true));

    return roomId;
  }
}
