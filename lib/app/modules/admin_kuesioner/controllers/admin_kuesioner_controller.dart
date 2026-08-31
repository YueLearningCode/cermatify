import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminKuesionerItem {
  const AdminKuesionerItem({
    required this.kuesioner,
    required this.userName,
    required this.respondentCount,
  });

  final Kuesioner kuesioner;
  final String userName;
  final int respondentCount;

  AdminKuesionerItem copyWith({Kuesioner? kuesioner}) {
    return AdminKuesionerItem(
      kuesioner: kuesioner ?? this.kuesioner,
      userName: userName,
      respondentCount: respondentCount,
    );
  }
}

class AdminKuesionerController extends GetxController {
  AdminKuesionerController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  static const int pageSize = 8;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final kuesioners = <AdminKuesionerItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isUpdating = false.obs;
  final hasMore = true.obs;
  final selectedStatusFilter = 'all'.obs;
  final loadError = ''.obs;

  final Map<String, String> _userNameCache = {};
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  int _requestGeneration = 0;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchKuesioners();
  }

  Future<void> fetchKuesioners() async {
    final generation = ++_requestGeneration;
    isLoading.value = true;
    loadError.value = '';
    hasMore.value = true;
    _lastDocument = null;
    kuesioners.clear();

    try {
      final page = await _fetchPage();
      if (generation != _requestGeneration) return;
      kuesioners.assignAll(page);
    } catch (error) {
      if (generation != _requestGeneration) return;
      AppLogger.info('Error fetching kuesioners: $error');
      hasMore.value = false;
      loadError.value = 'Data kuesioner belum dapat dimuat.';
    } finally {
      if (generation == _requestGeneration) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    final generation = _requestGeneration;
    isLoadingMore.value = true;
    try {
      final page = await _fetchPage();
      if (generation != _requestGeneration) return;
      kuesioners.addAll(page);
    } catch (error) {
      AppLogger.info('Error loading more kuesioners: $error');
      CustomSnackbar.show(
        title: 'Gagal memuat data',
        message: 'Kuesioner berikutnya belum dapat dimuat.',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      if (generation == _requestGeneration) isLoadingMore.value = false;
    }
  }

  Future<List<AdminKuesionerItem>> _fetchPage() async {
    Query<Map<String, dynamic>> query = _firestore.collection('kuesioners');
    if (selectedStatusFilter.value != 'all') {
      query = query.where(
        'status',
        whereIn: statusesForFilter(selectedStatusFilter.value),
      );
    }

    var pageQuery = selectedStatusFilter.value == 'all'
        ? query.orderBy('createdAt', descending: true).limit(pageSize)
        : query.limit(pageSize);
    if (_lastDocument != null) {
      pageQuery = pageQuery.startAfterDocument(_lastDocument!);
    }

    final snapshot = await pageQuery.get();
    if (snapshot.docs.isNotEmpty) _lastDocument = snapshot.docs.last;
    hasMore.value = snapshot.docs.length == pageSize;

    final entries = snapshot.docs.map((document) {
      final data = document.data();
      final signedBy = data['signedBy'] as List<dynamic>? ?? const [];
      return (
        kuesioner: Kuesioner.fromJson(data, document.id),
        respondentCount: signedBy.length,
      );
    }).toList();
    entries.sort(
      (first, second) =>
          second.kuesioner.createdAt.compareTo(first.kuesioner.createdAt),
    );

    final userIds = entries
        .map((entry) => entry.kuesioner.userId ?? '')
        .where((id) => id.isNotEmpty && !_userNameCache.containsKey(id))
        .toSet();
    await _hydrateUserNames(userIds);

    return entries
        .map(
          (entry) => AdminKuesionerItem(
            kuesioner: entry.kuesioner,
            userName:
                _userNameCache[entry.kuesioner.userId] ??
                'Pengguna tidak ditemukan',
            respondentCount: entry.respondentCount,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _hydrateUserNames(Set<String> ids) async {
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
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get(),
      ),
    );
    for (final snapshot in snapshots) {
      for (final document in snapshot.docs) {
        final data = document.data();
        _userNameCache[document.id] =
            data['nama']?.toString() ??
            data['name']?.toString() ??
            'Pengguna Cermatify';
      }
    }
  }

  Future<void> updateKuesionerStatus(
    String kuesionerId,
    String newStatus,
  ) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final reference = _firestore.collection('kuesioners').doc(kuesionerId);
      final document = await reference.get();
      if (!document.exists) throw StateError('Kuesioner tidak ditemukan');

      final orderId = document.data()?['orderId']?.toString() ?? '';
      final batch = _firestore.batch();
      batch.update(reference, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'adminId': currentUserId,
      });
      if (orderId.isNotEmpty) {
        batch.update(_firestore.collection('orders').doc(orderId), {
          'status': newStatus == 'approved' ? 'progress' : 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      final index = kuesioners.indexWhere(
        (item) => item.kuesioner.id == kuesionerId,
      );
      if (index >= 0) {
        if (selectedStatusFilter.value != 'all' &&
            !statusesForFilter(
              selectedStatusFilter.value,
            ).contains(newStatus)) {
          kuesioners.removeAt(index);
        } else {
          final old = kuesioners[index];
          kuesioners[index] = old.copyWith(
            kuesioner: _copyWithStatus(old.kuesioner, newStatus),
          );
        }
      }

      CustomSnackbar.show(
        title: 'Berhasil',
        message: newStatus == 'approved'
            ? 'Kuesioner berhasil disetujui'
            : 'Kuesioner berhasil ditolak',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (error) {
      AppLogger.info('Error updating kuesioner: $error');
      CustomSnackbar.show(
        title: 'Gagal',
        message: 'Status kuesioner belum dapat diperbarui',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Kuesioner _copyWithStatus(Kuesioner source, String status) {
    return Kuesioner(
      id: source.id,
      createdAt: source.createdAt,
      answers: source.answers,
      status: status,
      orderId: source.orderId,
      userId: source.userId,
      link: source.link,
      rentangUsia: source.rentangUsia,
      jenisKelamin: source.jenisKelamin,
      tingkatPenghasilan: source.tingkatPenghasilan,
      pendidikanTerakhir: source.pendidikanTerakhir,
    );
  }

  void changeStatusFilter(String status) {
    if (selectedStatusFilter.value == status) return;
    selectedStatusFilter.value = status;
    fetchKuesioners();
  }

  static List<String> statusesForFilter(String filter) {
    switch (filter) {
      case 'waiting verification':
        return const ['waiting verification', 'pending'];
      default:
        return [filter];
    }
  }

  List<AdminKuesionerItem> get filteredKuesioners {
    final filter = selectedStatusFilter.value;
    if (filter == 'all') return kuesioners;
    final statuses = statusesForFilter(filter);
    return kuesioners
        .where((item) => statuses.contains(item.kuesioner.status))
        .toList(growable: false);
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return AppColors.greenColor;
      case 'rejected':
        return AppColors.redColor;
      case 'waiting verification':
      case 'pending':
        return AppColors.yellow2Color;
      default:
        return AppColors.textSecondary;
    }
  }

  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'waiting verification':
      case 'pending':
        return 'Menunggu verifikasi';
      default:
        return 'Status tidak diketahui';
    }
  }
}
