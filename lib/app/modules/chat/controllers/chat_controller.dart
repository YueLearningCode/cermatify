import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/models/chat_model.dart';
import '../../home/controllers/home_controller.dart';

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
  final RxInt chatRoomCount = 0.obs;

  String get currentUserId => _auth.currentUser?.uid ?? 'u1';

  // Cache of userId -> display name
  final RxMap<String, String> userNames = <String, String>{}.obs;
  String getUserName(String userId) => userNames[userId] ?? 'Mentor';

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  String buildRoomId(String mentorId) {
    final List<String> ids = [currentUserId, mentorId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  void onInit() {
    super.onInit();
    // Make sure we have a unique user id for this device/session
    ensureSignedIn();
    loadChats();
    searchController.addListener(_filterChats);
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
    super.onClose();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _roomsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSubscription;

  // Check if current user is a mentor
  bool get isMentor {
    try {
      return Get.isRegistered<HomeController>() ? Get.find<HomeController>().isMentor.value : false;
    } catch (_) {
      return false;
    }
  }

  void loadChats() {
    if (isMentor) {
      // For mentors: load customers from orders in progress
      _loadMentorChats();
    } else {
      // For customers: load existing chat rooms
      _loadCustomerChats();
    }
  }

  void _loadCustomerChats() {
    _roomsSubscription?.cancel();
    _roomsSubscription = _firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final chats = snapshot.docs
              .map((doc) {
                final data = doc.data();
                final List<dynamic> users = (data['users'] as List<dynamic>? ?? []);
                final String lastSenderId = data['lastSenderId'] as String? ?? '';
                final String lastMessage = data['lastMessage'] as String? ?? '';
                final DateTime ts = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                // partner is the other user in the room
                final String partnerId = users
                    .map((e) => e.toString())
                    .firstWhere((id) => id != currentUserId, orElse: () => '');
                final String receiverId = lastSenderId == currentUserId ? partnerId : currentUserId;
                return ChatMessage(
                  id: doc.id,
                  senderId: lastSenderId.isNotEmpty ? lastSenderId : partnerId,
                  receiverId: receiverId,
                  message: lastMessage,
                  timestamp: ts,
                );
              })
              .where((c) => c.message.isNotEmpty)
              .toList();

          allChats.value = chats;
          chatRoomCount.value = chats.length;
          _hydratePartnerNames(chats);
          _applySearchFilter();
        });
  }

  void _loadMentorChats() {
    _ordersSubscription?.cancel();
    // Load orders for this mentor (filter status client-side to avoid composite index)
    _ordersSubscription = _firestore
        .collection('orders')
        .where('mentorId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) async {
          final Set<String> customerIds = {};
          final Map<String, DateTime> customerLastUpdate = {};
          final Map<String, String> customerOrderIds = {};

          // Get unique customer IDs from orders with status 'progress'
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final String status = data['status']?.toString() ?? '';
            // Filter for 'progress' status client-side
            if (status.toLowerCase() != 'progress' && status.toLowerCase() != 'approved') {
              continue;
            }
            final String customerId = data['userId']?.toString() ?? '';
            if (customerId.isNotEmpty && customerId != currentUserId) {
              customerIds.add(customerId);
              final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              if (!customerLastUpdate.containsKey(customerId) || updatedAt.isAfter(customerLastUpdate[customerId]!)) {
                customerLastUpdate[customerId] = updatedAt;
                customerOrderIds[customerId] = doc.id;
              }
            }
          }

          // Create ChatMessage objects for each customer
          final List<ChatMessage> chats = [];
          for (var customerId in customerIds) {
            // Try to get last message from chat room
            final String roomId = buildRoomId(customerId);
            final roomDoc = await _firestore.collection('chatRooms').doc(roomId).get();

            String lastMessage = '';
            String lastSenderId = '';
            DateTime timestamp = customerLastUpdate[customerId] ?? DateTime.now();

            if (roomDoc.exists) {
              final roomData = roomDoc.data();
              lastMessage = roomData?['lastMessage']?.toString() ?? '';
              lastSenderId = roomData?['lastSenderId']?.toString() ?? '';
              final roomUpdatedAt = (roomData?['updatedAt'] as Timestamp?)?.toDate();
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
              ),
            );
          }

          allChats.value = chats;
          chatRoomCount.value = chats.length;
          _hydratePartnerNames(chats);
          _applySearchFilter();
        });
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
          final String displayName = (data?['nama'] as String?) ?? (data?['name'] as String?) ?? 'Mentor';
          userNames[userId] = displayName;
        } else {
          userNames[userId] = 'Mentor';
        }
      } catch (_) {
        userNames[userId] = 'Mentor';
      }
    }
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
      final partnerId = chat.senderId == currentUserId ? chat.receiverId : chat.senderId;
      return chat.message.toLowerCase().contains(query) || partnerId.toLowerCase().contains(query);
    }).toList();
  }

  void loadMessages(String mentorId) {
    final String roomId = buildRoomId(mentorId);
    // Bind realtime stream from Firestore
    _firestore.collection('chatRooms').doc(roomId).collection('messages').orderBy('timestamp').snapshots().listen((
      snapshot,
    ) {
      final msgs = snapshot.docs.map((d) {
        final data = d.data();
        return ChatMessage(
          id: d.id,
          senderId: data['senderId'] as String? ?? '',
          receiverId: data['receiverId'] as String? ?? '',
          message: data['message'] as String? ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      chatMessages.value = msgs;
      scrollToBottom();
    });
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

  Future<void> sendMessage(String mentorId) async {
    if (messageController.text.trim().isEmpty) return;

    final messageText = messageController.text.trim();
    messageController.clear();

    isSending.value = true;

    final String roomId = buildRoomId(mentorId);
    final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('chatRooms').doc(roomId);
    // Ensure room exists
    await roomRef.set({
      'roomId': roomId,
      'users': [currentUserId, mentorId]..sort(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': messageText,
      'lastSenderId': currentUserId,
    }, SetOptions(merge: true));

    // Save message
    final msgRef = roomRef.collection('messages').doc();
    final DateTime now = DateTime.now();
    await msgRef.set({
      'senderId': currentUserId,
      'receiverId': mentorId,
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'localTime': now.toIso8601String(), // optional local for ordering fallback
    });

    // After successful send, rely on Firestore stream to update the UI
    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);

    isSending.value = false;
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

  Future<String> createOrGetChatRoom({required String mentorId}) async {
    await ensureSignedIn();
    final String userId = currentUserId;
    if (userId == mentorId) {
      // Prevent creating a room with identical participants
      // Developer note: ensure you are logged in as a different user than the mentor.
      return '${userId}_$mentorId';
    }
    // Create deterministic room id by sorting ids
    final List<String> ids = [userId, mentorId]..sort();
    final String roomId = '${ids[0]}_${ids[1]}';

    final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('chatRooms').doc(roomId);

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await roomRef.get();
    if (!snapshot.exists) {
      await roomRef.set({
        'roomId': roomId,
        'users': ids,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastSenderId': '',
      }, SetOptions(merge: true));
    } else {
      await roomRef.update({'updatedAt': FieldValue.serverTimestamp()});
    }

    return roomId;
  }
}
