import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class OrderHistoryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user == null) {
        orders.value = [];
        return;
      }

      List<Map<String, dynamic>> ordersList;

      try {
        // Try with orderBy first
        final querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

        ordersList = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {'id': doc.id, ...data};
        }).toList();
      } catch (e) {
        // If orderBy fails (might need composite index), fetch without orderBy
        print('Error with orderBy, trying without: $e');
        final querySnapshot = await _firestore.collection('orders').where('userId', isEqualTo: user.uid).get();

        ordersList = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {'id': doc.id, ...data};
        }).toList();

        // Sort manually by createdAt
        ordersList.sort((a, b) {
          final aTime = a['createdAt'];
          final bTime = b['createdAt'];
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime); // Descending
          }
          return 0;
        });
      }

      // Fetch mentor and layanan names for each order
      for (var order in ordersList) {
        final mentorId = order['mentorId']?.toString();
        final layananId = order['layananId']?.toString();

        // Fetch mentor name
        if (mentorId != null && mentorId.isNotEmpty) {
          try {
            final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
            if (mentorDoc.exists) {
              final mentorData = mentorDoc.data();
              order['mentorName'] = mentorData?['nama'] ?? mentorData?['name'] ?? 'Unknown Mentor';
            } else {
              order['mentorName'] = 'Unknown Mentor';
            }
          } catch (e) {
            print('Error fetching mentor name: $e');
            order['mentorName'] = 'Unknown Mentor';
          }
        } else {
          order['mentorName'] = 'Unknown Mentor';
        }

        // Fetch layanan name
        if (layananId != null && layananId.isNotEmpty) {
          try {
            final layananDoc = await _firestore.collection('layanan').doc(layananId).get();
            if (layananDoc.exists) {
              final layananData = layananDoc.data();
              order['layananName'] = layananData?['name'] ?? 'Unknown Layanan';
            } else {
              order['layananName'] = 'Unknown Layanan';
            }
          } catch (e) {
            print('Error fetching layanan name: $e');
            order['layananName'] = 'Unknown Layanan';
          }
        } else {
          order['layananName'] = 'Unknown Layanan';
        }
      }

      // Sort by newest (most recent first) after fetching all data
      ordersList.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime); // Descending (newest first)
        }
        return 0;
      });

      orders.value = ordersList;
      print('Fetched ${orders.length} orders'); // Debug
    } catch (e) {
      print('Error fetching orders: $e');
      orders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user has order in progress for a mentor with specific layanan type
  // Only checks for 'progress' or 'approved' status (not 'waiting verification')
  Future<bool> hasProgressOrder(String mentorId, {String? layananType}) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      // Check for orders with status 'progress' or 'approved' only
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('mentorId', isEqualTo: mentorId)
          .get();

      // Filter client-side for status and layanan type
      final hasOrder = querySnapshot.docs.any((doc) {
        final data = doc.data();
        final status = data['status']?.toString().toLowerCase() ?? '';
        final orderLayananType = data['layananType']?.toString() ?? '';

        // Check status - only 'progress' or 'approved' (not 'waiting verification')
        final validStatus = status == 'progress' || status == 'approved';

        // If layananType is provided, also check if it matches
        if (layananType != null && layananType.isNotEmpty) {
          return validStatus && orderLayananType.toLowerCase() == layananType.toLowerCase();
        }

        return validStatus;
      });

      return hasOrder;
    } catch (e) {
      print('Error checking progress order: $e');
      return false;
    }
  }

  // Get orderId from progress order for a mentor with specific layanan type
  // (returns the most recent one)
  // Only includes orders with status 'progress' or 'approved' (not 'waiting verification')
  Future<String?> getProgressOrderId(String mentorId, {String? layananType}) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      // Get all orders for this mentor
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('mentorId', isEqualTo: mentorId)
          .get();

      // Filter for valid statuses and layanan type, then sort by createdAt
      final validOrders = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final status = data['status']?.toString().toLowerCase() ?? '';
        final orderLayananType = data['layananType']?.toString() ?? '';

        // Check status - only 'progress' or 'approved' (not 'waiting verification')
        final validStatus = status == 'progress' || status == 'approved';

        // If layananType is provided, also check if it matches
        if (layananType != null && layananType.isNotEmpty) {
          return validStatus && orderLayananType.toLowerCase() == layananType.toLowerCase();
        }

        return validStatus;
      }).toList();

      if (validOrders.isEmpty) return null;

      // Sort by createdAt descending (most recent first)
      validOrders.sort((a, b) {
        final aTime = a.data()['createdAt'];
        final bTime = b.data()['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime); // Descending
        }
        return 0;
      });

      return validOrders.first.id;
    } catch (e) {
      print('Error getting progress orderId: $e');
      return null;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting verification':
        return AppColors.yellow2Color;
      case 'progress':
        return AppColors.greenColor;
      case 'rejected':
        return AppColors.redColor;
      case 'completed':
        return AppColors.primary;
      // Legacy support for old status names
      case 'pending':
        return AppColors.yellow2Color;
      case 'approved':
        return AppColors.greenColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'waiting verification':
        return 'Waiting Verification';
      case 'progress':
        return 'In Progress';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      // Legacy support for old status names
      case 'pending':
        return 'Waiting Verification';
      case 'approved':
        return 'In Progress';
      default:
        return status;
    }
  }
}
