import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';

class AdminOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final selectedStatusFilter = 'all'.obs; // 'all', 'waiting verification', 'progress', 'rejected', 'completed'

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      Query<Map<String, dynamic>> query = _firestore.collection('orders');

      // Apply status filter if not 'all'
      if (selectedStatusFilter.value != 'all') {
        query = query.where('status', isEqualTo: selectedStatusFilter.value);
      }

      try {
        // Try with orderBy first
        final querySnapshot = await query.orderBy('createdAt', descending: true).get();
        orders.value = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {'id': doc.id, ...data};
        }).toList();
      } catch (e) {
        // If orderBy fails, fetch without orderBy
        print('Error with orderBy, trying without: $e');
        final querySnapshot = await query.get();
        final ordersList = querySnapshot.docs.map((doc) {
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

        orders.value = ordersList;
      }

      // Fetch user, mentor and layanan names for each order
      final ordersWithNames = <Map<String, dynamic>>[];
      for (var order in orders) {
        final orderMap = Map<String, dynamic>.from(order);
        final userId = orderMap['userId']?.toString();
        final mentorId = orderMap['mentorId']?.toString();
        final layananId = orderMap['layananId']?.toString();

        // Fetch user name
        if (userId != null && userId.isNotEmpty) {
          try {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              orderMap['userName'] = userData?['nama'] ?? userData?['name'] ?? 'Unknown User';
            } else {
              orderMap['userName'] = 'Unknown User';
            }
          } catch (e) {
            print('Error fetching user name: $e');
            orderMap['userName'] = 'Unknown User';
          }
        } else {
          orderMap['userName'] = 'Unknown User';
        }

        // Fetch mentor name
        if (mentorId != null && mentorId.isNotEmpty) {
          try {
            final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
            if (mentorDoc.exists) {
              final mentorData = mentorDoc.data();
              orderMap['mentorName'] = mentorData?['nama'] ?? mentorData?['name'] ?? 'Unknown Mentor';
            } else {
              orderMap['mentorName'] = 'Unknown Mentor';
            }
          } catch (e) {
            print('Error fetching mentor name: $e');
            orderMap['mentorName'] = 'Unknown Mentor';
          }
        } else {
          orderMap['mentorName'] = 'Unknown Mentor';
        }

        // Fetch layanan name
        if (layananId != null && layananId.isNotEmpty) {
          try {
            final layananDoc = await _firestore.collection('layanan').doc(layananId).get();
            if (layananDoc.exists) {
              final layananData = layananDoc.data();
              orderMap['layananName'] = layananData?['name'] ?? 'Unknown Layanan';
            } else {
              orderMap['layananName'] = 'Unknown Layanan';
            }
          } catch (e) {
            print('Error fetching layanan name: $e');
            orderMap['layananName'] = 'Unknown Layanan';
          }
        } else {
          orderMap['layananName'] = 'Unknown Layanan';
        }

        ordersWithNames.add(orderMap);
      }

      orders.value = ordersWithNames;
      print('Fetched ${orders.length} orders'); // Debug
    } catch (e) {
      print('Error fetching orders: $e');
      orders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isUpdating.value = true;

      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh orders list
      await fetchOrders();

      CustomSnackbar.show(
        title: 'Success',
        message: 'Order status updated successfully',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to update order status: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void changeStatusFilter(String status) {
    selectedStatusFilter.value = status;
    fetchOrders();
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
      // Legacy support
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
      // Legacy support
      case 'pending':
        return 'Waiting Verification';
      case 'approved':
        return 'In Progress';
      default:
        return status;
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedStatusFilter.value == 'all') {
      return orders;
    }
    return orders
        .where((order) => order['status']?.toString().toLowerCase() == selectedStatusFilter.value.toLowerCase())
        .toList();
  }
}
