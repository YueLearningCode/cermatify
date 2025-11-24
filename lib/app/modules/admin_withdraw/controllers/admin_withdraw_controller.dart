import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/models/withdraw_model.dart';
import 'package:cermatify/app/data/models/chat_model.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class AdminWithdrawController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final withdraws = <WithdrawModel>[].obs;
  final isLoading = false.obs;
  final selectedStatusFilter = 'all'.obs; // 'all', 'pending', 'approved', 'rejected', 'completed'

  // Chat from users (mentors and regular users)
  final mentorChats = <ChatMessage>[].obs;
  final isLoadingChats = false.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatRoomsSubscription;
  final RxMap<String, String> userNames = <String, String>{}.obs;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchWithdraws();
    _loadMentorChats();
  }

  @override
  void onClose() {
    _chatRoomsSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchWithdraws() async {
    try {
      isLoading.value = true;

      Query<Map<String, dynamic>> query = _firestore.collection('withdraws');

      // Apply status filter if not 'all'
      if (selectedStatusFilter.value != 'all') {
        query = query.where('status', isEqualTo: selectedStatusFilter.value);
      }

      try {
        final querySnapshot = await query.orderBy('createdAt', descending: true).get();
        withdraws.value = querySnapshot.docs.map((doc) {
          return WithdrawModel.fromJson(doc.data(), doc.id);
        }).toList();
      } catch (e) {
        // If orderBy fails, fetch without orderBy
        print('Error with orderBy, trying without: $e');
        final querySnapshot = await query.get();
        final withdrawsList = querySnapshot.docs.map((doc) {
          return WithdrawModel.fromJson(doc.data(), doc.id);
        }).toList();

        // Sort manually by createdAt
        withdrawsList.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt); // Descending
        });

        withdraws.value = withdrawsList;
      }
    } catch (e) {
      print('Error fetching withdraws: $e');
      withdraws.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWithdrawStatus(String withdrawId, String newStatus, {String? notes}) async {
    try {
      isLoading.value = true;

      // Get current withdraw data to check previous status
      final withdrawDoc = await _firestore.collection('withdraws').doc(withdrawId).get();
      if (!withdrawDoc.exists) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Withdraw tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      final withdrawData = withdrawDoc.data();
      final oldStatus = (withdrawData?['status'] as String?) ?? 'pending';
      final mentorId = withdrawData?['mentorId']?.toString();
      final nominal = (withdrawData?['nominal'] as int?) ?? 0;

      // Handle saldo changes based on status transition
      if (mentorId != null && mentorId.isNotEmpty && nominal > 0) {
        final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
        if (!mentorDoc.exists) {
          CustomSnackbar.show(
            title: 'Error',
            message: 'Mentor tidak ditemukan',
            backgroundColor: AppColors.redColor,
            isNav: false,
          );
          return;
        }

        final mentorData = mentorDoc.data();
        final currentSaldo = (mentorData?['saldo'] as int?) ?? 0;
        int newSaldo = currentSaldo;

        // Case 1: Changing from approved to rejected -> return saldo
        if (oldStatus == 'approved' && newStatus == 'rejected') {
          newSaldo = currentSaldo + nominal;
        }
        // Case 2: Changing to approved (from pending or rejected) -> deduct saldo
        else if (newStatus == 'approved' && oldStatus != 'approved') {
          newSaldo = currentSaldo - nominal;

          if (newSaldo < 0) {
            CustomSnackbar.show(
              title: 'Error',
              message: 'Saldo mentor tidak mencukupi',
              backgroundColor: AppColors.redColor,
              isNav: false,
            );
            return;
          }
        }
        // Case 3: If already approved and changing to approved again, or rejected to rejected -> no change
        // Case 4: If pending to rejected -> no change (saldo was never deducted)

        // Update mentor saldo if it changed
        if (newSaldo != currentSaldo) {
          await _firestore.collection('users').doc(mentorId).update({'saldo': newSaldo});
        }
      }

      // Update withdraw status
      final updateData = {'status': newStatus, 'updatedAt': FieldValue.serverTimestamp(), 'adminId': currentUserId};

      if (notes != null && notes.isNotEmpty) {
        updateData['notes'] = notes;
      }

      await _firestore.collection('withdraws').doc(withdrawId).update(updateData);

      // Refresh withdraws list
      await fetchWithdraws();

      CustomSnackbar.show(
        title: 'Success',
        message: 'Status withdraw berhasil diupdate',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal update status withdraw: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeStatusFilter(String status) {
    selectedStatusFilter.value = status;
    fetchWithdraws();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.yellow2Color;
      case 'approved':
        return AppColors.greenColor;
      case 'rejected':
        return AppColors.redColor;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  List<WithdrawModel> get filteredWithdraws {
    if (selectedStatusFilter.value == 'all') {
      return withdraws;
    }
    return withdraws
        .where((withdraw) => withdraw.status.toLowerCase() == selectedStatusFilter.value.toLowerCase())
        .toList();
  }

  void _loadMentorChats() {
    _chatRoomsSubscription?.cancel();
    isLoadingChats.value = true;

    // Load chat rooms where admin is one of the users
    _chatRoomsSubscription = _firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          final List<ChatMessage> chats = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final List<dynamic> users = (data['users'] as List<dynamic>? ?? []);
            final String lastSenderId = data['lastSenderId'] as String? ?? '';
            final String lastMessage = data['lastMessage'] as String? ?? '';
            final DateTime ts = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final String? orderId = data['orderId'] as String?;

            // Get partner ID (the other user in the room, should be a mentor)
            final String partnerId = users
                .map((e) => e.toString())
                .firstWhere((id) => id != currentUserId, orElse: () => '');

            if (partnerId.isEmpty) continue;

            // Get partner user data (mentor or regular user)
            try {
              final partnerDoc = await _firestore.collection('users').doc(partnerId).get();
              if (partnerDoc.exists) {
                final partnerData = partnerDoc.data();

                // Show chats from all users (mentors and regular users)
                final String receiverId = lastSenderId == currentUserId ? partnerId : currentUserId;
                chats.add(
                  ChatMessage(
                    id: doc.id,
                    senderId: lastSenderId.isNotEmpty ? lastSenderId : partnerId,
                    receiverId: receiverId,
                    message: lastMessage,
                    timestamp: ts,
                    orderId: orderId,
                  ),
                );

                // Cache user name
                if (!userNames.containsKey(partnerId)) {
                  final userName = partnerData?['nama'] ?? partnerData?['name'] ?? 'User';
                  userNames[partnerId] = userName;
                }
              }
            } catch (e) {
              print('Error getting partner data: $e');
            }
          }

          mentorChats.value = chats.where((c) => c.message.isNotEmpty).toList();
          isLoadingChats.value = false;
        });
  }

  String getMentorName(String userId) {
    return userNames[userId] ?? 'User';
  }

  Future<void> refreshChats() async {
    _loadMentorChats();
  }
}
