import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

bool orderMatchesStatus(Map<String, dynamic> order, String filter) {
  if (filter == 'all') return true;
  final status = order['status']?.toString().toLowerCase() ?? '';
  switch (filter) {
    case 'waiting':
      return status == 'waiting verification' || status == 'pending';
    case 'progress':
      return status == 'progress' || status == 'approved';
    case 'completed':
      return status == 'completed';
    case 'rejected':
      return status == 'rejected';
    default:
      return true;
  }
}

class OrderHistoryController extends GetxController {
  OrderHistoryController({this.autoLoad = true});

  static const int pageSize = 8;
  final bool autoLoad;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedStatus = 'all'.obs;
  final visibleCount = pageSize.obs;

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedStatus.value == 'all') return orders;
    return orders
        .where((order) => orderMatchesStatus(order, selectedStatus.value))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> get visibleOrders =>
      filteredOrders.take(visibleCount.value).toList(growable: false);

  bool get hasMore => visibleCount.value < filteredOrders.length;

  void setStatusFilter(String value) {
    selectedStatus.value = value;
    visibleCount.value = pageSize;
  }

  void showMore() {
    visibleCount.value += pageSize;
  }

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) fetchOrders();
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
        AppLogger.info('Error with orderBy, trying without: $e');
        final querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();

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

      // Hydrate referensi secara batch agar jumlah read tidak bertambah satu per
      // order (N+1). Firestore membatasi whereIn, sehingga ID dipotong per 30.
      final mentorIds = ordersList
          .map((order) => order['mentorId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final layananIds = ordersList
          .map((order) => order['layananId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final results = await Future.wait([
        _fetchNamesByIds(
          collection: 'users',
          ids: mentorIds,
          nameFields: const ['nama', 'name'],
        ),
        _fetchNamesByIds(
          collection: 'layanan',
          ids: layananIds,
          nameFields: const ['name'],
        ),
      ]);
      final mentorNames = results[0];
      final layananNames = results[1];

      for (final order in ordersList) {
        final mentorId = order['mentorId']?.toString() ?? '';
        final layananId = order['layananId']?.toString() ?? '';
        order['mentorName'] = mentorNames[mentorId] ?? 'Mentor Cermatify';
        order['layananName'] = layananNames[layananId] ?? 'Layanan Cermatify';
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
      visibleCount.value = pageSize;
      AppLogger.info('Fetched ${orders.length} orders'); // Debug
    } catch (e) {
      AppLogger.info('Error fetching orders: $e');
      orders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, String>> _fetchNamesByIds({
    required String collection,
    required Set<String> ids,
    required List<String> nameFields,
  }) async {
    if (ids.isEmpty) return {};
    final values = ids.toList(growable: false);
    final result = <String, String>{};
    for (var start = 0; start < values.length; start += 30) {
      final end = (start + 30).clamp(0, values.length);
      final chunk = values.sublist(start, end);
      try {
        final snapshot = await _firestore
            .collection(collection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final document in snapshot.docs) {
          final data = document.data();
          String? name;
          for (final field in nameFields) {
            final value = data[field]?.toString().trim();
            if (value != null && value.isNotEmpty) {
              name = value;
              break;
            }
          }
          if (name != null) result[document.id] = name;
        }
      } catch (error) {
        AppLogger.info('Gagal memuat referensi $collection: $error');
      }
    }
    return result;
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
          return validStatus &&
              orderLayananType.toLowerCase() == layananType.toLowerCase();
        }

        return validStatus;
      });

      return hasOrder;
    } catch (e) {
      AppLogger.info('Error checking progress order: $e');
      return false;
    }
  }

  // Get orderId from progress order for a mentor with specific layanan type
  // (returns the most recent one)
  // Only includes orders with status 'progress' or 'approved' (not 'waiting verification')
  Future<String?> getProgressOrderId(
    String mentorId, {
    String? layananType,
  }) async {
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
          return validStatus &&
              orderLayananType.toLowerCase() == layananType.toLowerCase();
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
      AppLogger.info('Error getting progress orderId: $e');
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
        return 'Menunggu verifikasi';
      case 'progress':
        return 'Sedang diproses';
      case 'rejected':
        return 'Ditolak';
      case 'completed':
        return 'Selesai';
      // Legacy support for old status names
      case 'pending':
        return 'Menunggu verifikasi';
      case 'approved':
        return 'Sedang diproses';
      default:
        return status;
    }
  }
}
