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
  final adminContacts = <ChatContact>[].obs;

  String get currentUserId => _auth.currentUser?.uid ?? 'u1';

  // Cache of userId -> display name
  final RxMap<String, String> userNames = <String, String>{}.obs;
  String getUserName(String userId) =>
      userNames[userId] ?? (isAdmin ? 'Pengguna Cermatify' : 'Mentor');

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
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
    unawaited(_initializeChats());
  }

  Future<void> _initializeChats() async {
    isLoadingChats.value = true;
    chatLoadError.value = '';
    try {
      await ensureSignedIn();
      if (isAdmin) await loadAdminContacts();
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
    super.onClose();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _roomsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _messagesSubscription;
  String? _activeRoomId;

  bool get isAdmin => SessionState.role == 'admin';

  // Check if current user is a mentor
  bool get isMentor {
    try {
      return Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().isMentor.value
          : false;
    } catch (_) {
      return false;
    }
  }

  void loadChats() {
    isLoadingChats.value = true;
    chatLoadError.value = '';
    if (isMentor) {
      // Mentors serve customers from orders in progress.
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

            allChats.value = chats;
            chatRoomCount.value = chats.length;
            isLoadingChats.value = false;
            _hydratePartnerNames(chats);
            _applySearchFilter();
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

  void _loadMentorChats() {
    _ordersSubscription?.cancel();
    // Load orders for this mentor (filter status client-side to avoid composite index)
    _ordersSubscription = _firestore
        .collection('orders')
        .where('mentorId', isEqualTo: currentUserId)
        .snapshots()
        .listen(
          (snapshot) async {
            final Set<String> customerIds = {};
            final Map<String, DateTime> customerLastUpdate = {};
            final Map<String, String> customerOrderIds = {};

            // Get unique customer IDs from orders with status 'progress'
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final String status = data['status']?.toString() ?? '';
              // Filter for 'progress' status client-side
              if (status.toLowerCase() != 'progress' &&
                  status.toLowerCase() != 'approved') {
                continue;
              }
              final String customerId = data['userId']?.toString() ?? '';
              if (customerId.isNotEmpty && customerId != currentUserId) {
                customerIds.add(customerId);
                final updatedAt =
                    (data['updatedAt'] as Timestamp?)?.toDate() ??
                    DateTime.now();
                if (!customerLastUpdate.containsKey(customerId) ||
                    updatedAt.isAfter(customerLastUpdate[customerId]!)) {
                  customerLastUpdate[customerId] = updatedAt;
                  customerOrderIds[customerId] = doc.id;
                }
              }
            }

            // Create ChatMessage objects for each customer
            final List<ChatMessage> chats = [];
            for (var customerId in customerIds) {
              // Try to get last message from chat room
              final orderId = customerOrderIds[customerId];
              final String roomId = buildRoomId(customerId, orderId: orderId);
              final roomDoc = await _firestore
                  .collection('chatRooms')
                  .doc(roomId)
                  .get();

              String lastMessage = '';
              String lastSenderId = '';
              DateTime timestamp =
                  customerLastUpdate[customerId] ?? DateTime.now();

              if (roomDoc.exists) {
                final roomData = roomDoc.data();
                lastMessage = roomData?['lastMessage']?.toString() ?? '';
                lastSenderId = roomData?['lastSenderId']?.toString() ?? '';
                final roomUpdatedAt = (roomData?['updatedAt'] as Timestamp?)
                    ?.toDate();
                if (roomUpdatedAt != null && roomUpdatedAt.isAfter(timestamp)) {
                  timestamp = roomUpdatedAt;
                }
              }

              // If no message yet, show default message
              if (lastMessage.isEmpty) {
                lastMessage = 'Order sedang berlangsung';
              }

              chats.add(
                ChatMessage(
                  id: customerOrderIds[customerId] ?? roomId,
                  senderId: lastSenderId.isNotEmpty ? lastSenderId : customerId,
                  receiverId: customerId,
                  message: lastMessage,
                  timestamp: timestamp,
                  orderId: orderId,
                ),
              );
            }

            allChats.value = chats;
            chatRoomCount.value = chats.length;
            isLoadingChats.value = false;
            _hydratePartnerNames(chats);
            _applySearchFilter();
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
    final String roomId = buildRoomId(mentorId, orderId: orderId);
    if (_activeRoomId == roomId &&
        _messagesSubscription != null &&
        messageLoadError.value.isEmpty) {
      return;
    }
    _activeRoomId = roomId;
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
              );
            }).toList();
            chatMessages.value = msgs;
            isLoadingMessages.value = false;
            scrollToBottom();
          },
          onError: (_) {
            isLoadingMessages.value = false;
            messageLoadError.value = 'Pesan belum dapat dimuat.';
          },
        );
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
    if (messageController.text.trim().isEmpty) return;

    final messageText = messageController.text.trim();
    messageController.clear();

    isSending.value = true;
    try {
      final String roomId = await createOrGetChatRoom(
        mentorId: mentorId,
        orderId: orderId,
      );
      final roomRef = _firestore.collection('chatRooms').doc(roomId);
      await roomRef.set({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': messageText,
        'lastSenderId': currentUserId,
      }, SetOptions(merge: true));

      final msgRef = roomRef.collection('messages').doc();
      final now = DateTime.now();
      await msgRef.set({
        'senderId': currentUserId,
        'receiverId': mentorId,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'localTime': now.toIso8601String(),
      });

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
    final String userId = currentUserId;
    final String roomId = buildRoomId(mentorId, orderId: orderId);

    final DocumentReference<Map<String, dynamic>> roomRef = _firestore
        .collection('chatRooms')
        .doc(roomId);

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await roomRef.get();
    final List<String> ids = [userId, mentorId]..sort();

    final roomData = {
      'roomId': roomId,
      'users': ids,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastSenderId': '',
    };

    // Add orderId to room data if provided
    if (orderId != null && orderId.isNotEmpty) {
      roomData['orderId'] = orderId;
    }

    if (!snapshot.exists) {
      await roomRef.set(roomData, SetOptions(merge: true));
    } else {
      // Update orderId if it wasn't set before
      if (orderId != null && orderId.isNotEmpty) {
        await roomRef.update({
          'orderId': orderId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await roomRef.update({'updatedAt': FieldValue.serverTimestamp()});
      }
    }

    return roomId;
  }
}
