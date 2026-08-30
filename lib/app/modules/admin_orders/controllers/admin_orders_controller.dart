import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminOrdersController extends GetxController {
  AdminOrdersController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const int pageSize = 20;

  final FirebaseFirestore _firestore;
  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isUpdating = false.obs;
  final hasMore = true.obs;
  final selectedStatusFilter = 'all'.obs;

  final Map<String, String> _userNameCache = {};
  final Map<String, String> _serviceNameCache = {};
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  int _requestGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final generation = ++_requestGeneration;
    isLoading.value = true;
    hasMore.value = true;
    _lastDocument = null;
    orders.clear();

    try {
      final result = await _fetchPage();
      if (generation != _requestGeneration) return;
      orders.assignAll(result);
    } catch (error) {
      if (generation != _requestGeneration) return;
      AppLogger.info('Error fetching orders: $error');
      orders.clear();
      hasMore.value = false;
    } finally {
      if (generation == _requestGeneration) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    final generation = _requestGeneration;
    isLoadingMore.value = true;

    try {
      final result = await _fetchPage();
      if (generation != _requestGeneration) return;
      orders.addAll(result);
    } catch (error) {
      AppLogger.info('Error loading more orders: $error');
      CustomSnackbar.show(
        title: 'Gagal memuat data',
        message: 'Order berikutnya tidak dapat dimuat. Silakan coba lagi.',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      if (generation == _requestGeneration) isLoadingMore.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPage() async {
    Query<Map<String, dynamic>> baseQuery = _firestore.collection('orders');
    if (selectedStatusFilter.value != 'all') {
      baseQuery = baseQuery.where(
        'status',
        whereIn: statusesForFilter(selectedStatusFilter.value),
      );
    }

    var pageQuery = selectedStatusFilter.value == 'all'
        ? baseQuery.orderBy('createdAt', descending: true).limit(pageSize)
        : baseQuery.limit(pageSize);
    if (_lastDocument != null) {
      pageQuery = pageQuery.startAfterDocument(_lastDocument!);
    }
    final snapshot = await pageQuery.get();
    if (snapshot.docs.isNotEmpty) _lastDocument = snapshot.docs.last;
    hasMore.value = snapshot.docs.length == pageSize;

    final page = snapshot.docs
        .map(
          (document) => <String, dynamic>{
            'id': document.id,
            ...document.data(),
          },
        )
        .toList();
    page.sort(_compareCreatedAtDescending);
    await _enrichOrders(page);
    AppLogger.info('Fetched ${page.length} orders in current page');
    return page;
  }

  int _compareCreatedAtDescending(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    final firstDate = first['createdAt'];
    final secondDate = second['createdAt'];
    if (firstDate is! Timestamp && secondDate is! Timestamp) return 0;
    if (firstDate is! Timestamp) return 1;
    if (secondDate is! Timestamp) return -1;
    return secondDate.compareTo(firstDate);
  }

  static List<String> statusesForFilter(String filter) {
    switch (filter) {
      case 'waiting verification':
        return const ['waiting verification', 'pending'];
      case 'progress':
        return const ['progress', 'approved'];
      default:
        return [filter];
    }
  }

  Future<void> _enrichOrders(List<Map<String, dynamic>> page) async {
    final userIds = <String>{};
    final serviceIds = <String>{};

    for (final order in page) {
      final userId = order['userId']?.toString() ?? '';
      final mentorId = order['mentorId']?.toString() ?? '';
      final serviceId = order['layananId']?.toString() ?? '';
      if (userId.isNotEmpty && !_userNameCache.containsKey(userId)) {
        userIds.add(userId);
      }
      if (mentorId.isNotEmpty && !_userNameCache.containsKey(mentorId)) {
        userIds.add(mentorId);
      }
      if (serviceId.isNotEmpty &&
          !_serviceNameCache.containsKey(serviceId) &&
          serviceId != 'kuesioner') {
        serviceIds.add(serviceId);
      }
    }

    await Future.wait([
      _fetchNames(
        collection: 'users',
        ids: userIds,
        cache: _userNameCache,
        fields: const ['nama', 'name'],
      ),
      _fetchNames(
        collection: 'layanan',
        ids: serviceIds,
        cache: _serviceNameCache,
        fields: const ['name'],
      ),
    ]);
    _serviceNameCache['kuesioner'] = 'Kuesioner';

    for (final order in page) {
      final userId = order['userId']?.toString() ?? '';
      final mentorId = order['mentorId']?.toString() ?? '';
      final serviceId = order['layananId']?.toString() ?? '';
      order['userName'] = _userNameCache[userId] ?? 'Pengguna tidak ditemukan';
      order['mentorName'] =
          _userNameCache[mentorId] ?? 'Mentor tidak ditemukan';
      order['layananName'] =
          _serviceNameCache[serviceId] ?? 'Layanan tidak ditemukan';
    }
  }

  Future<void> _fetchNames({
    required String collection,
    required Set<String> ids,
    required Map<String, String> cache,
    required List<String> fields,
  }) async {
    if (ids.isEmpty) return;
    final values = ids.toList();
    final chunks = <List<String>>[];
    for (var index = 0; index < values.length; index += 30) {
      final end = (index + 30).clamp(0, values.length);
      chunks.add(values.sublist(index, end));
    }

    final snapshots = await Future.wait(
      chunks.map(
        (chunk) => _firestore
            .collection(collection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get(),
      ),
    );

    for (final snapshot in snapshots) {
      for (final document in snapshot.docs) {
        final data = document.data();
        String? name;
        for (final field in fields) {
          final candidate = data[field]?.toString().trim();
          if (candidate != null && candidate.isNotEmpty) {
            name = candidate;
            break;
          }
        }
        cache[document.id] = name ?? '-';
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (isUpdating.value) return;
    try {
      isUpdating.value = true;
      final orderReference = _firestore.collection('orders').doc(orderId);
      final orderDocument = await orderReference.get();
      if (!orderDocument.exists) throw Exception('Order tidak ditemukan');

      final data = orderDocument.data()!;
      final currentStatus = data['status']?.toString().toLowerCase() ?? '';
      final mentorId = data['mentorId']?.toString() ?? '';
      final price = (data['price'] as num?)?.toInt() ?? 0;
      final isFirstApproval =
          (newStatus == 'progress' || newStatus == 'approved') &&
          currentStatus != 'progress' &&
          currentStatus != 'approved' &&
          mentorId.isNotEmpty &&
          price > 0;

      final batch = _firestore.batch();
      batch.update(orderReference, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (isFirstApproval) {
        batch.update(_firestore.collection('users').doc(mentorId), {
          'saldo': FieldValue.increment(price),
        });
      }
      await batch.commit();

      final index = orders.indexWhere((order) => order['id'] == orderId);
      if (index >= 0) {
        if (selectedStatusFilter.value != 'all' &&
            selectedStatusFilter.value != newStatus) {
          orders.removeAt(index);
        } else {
          orders[index] = {...orders[index], 'status': newStatus};
        }
      }

      CustomSnackbar.show(
        title: 'Berhasil',
        message: 'Status order berhasil diperbarui',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (error) {
      AppLogger.info('Error updating order status: $error');
      CustomSnackbar.show(
        title: 'Gagal',
        message: 'Status order tidak dapat diperbarui',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void changeStatusFilter(String status) {
    if (selectedStatusFilter.value == status) return;
    selectedStatusFilter.value = status;
    fetchOrders();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting verification':
      case 'pending':
        return AppColors.yellow2Color;
      case 'progress':
      case 'approved':
        return AppColors.greenColor;
      case 'rejected':
        return AppColors.redColor;
      case 'completed':
        return AppColors.primaryColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'waiting verification':
      case 'pending':
        return 'Menunggu verifikasi';
      case 'progress':
      case 'approved':
        return 'Sedang diproses';
      case 'rejected':
        return 'Ditolak';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    final filter = selectedStatusFilter.value;
    if (filter == 'all') return orders;
    return filterOrders(orders, filter);
  }

  static List<Map<String, dynamic>> filterOrders(
    Iterable<Map<String, dynamic>> source,
    String filter,
  ) {
    if (filter == 'all') return source.toList(growable: false);
    final statuses = statusesForFilter(filter);
    return source
        .where(
          (order) =>
              statuses.contains(order['status']?.toString().toLowerCase()),
        )
        .toList(growable: false);
  }
}
