import 'package:cermatify/app/data/models/withdraw_model.dart';
import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminWithdrawController extends GetxController {
  AdminWithdrawController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const int pageSize = 8;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final withdraws = <WithdrawModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isUpdating = false.obs;
  final hasMore = true.obs;
  final selectedStatusFilter = 'all'.obs;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  int _requestGeneration = 0;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchWithdraws();
  }

  Future<void> fetchWithdraws() async {
    final generation = ++_requestGeneration;
    isLoading.value = true;
    hasMore.value = true;
    _lastDocument = null;
    withdraws.clear();

    try {
      final page = await _fetchPage();
      if (generation != _requestGeneration) return;
      withdraws.assignAll(page);
    } catch (error) {
      if (generation != _requestGeneration) return;
      AppLogger.info('Error fetching withdraws: $error');
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
      final page = await _fetchPage();
      if (generation != _requestGeneration) return;
      withdraws.addAll(page);
    } catch (error) {
      AppLogger.info('Error loading more withdraws: $error');
      CustomSnackbar.show(
        title: 'Gagal memuat data',
        message: 'Permintaan berikutnya tidak dapat dimuat.',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      if (generation == _requestGeneration) isLoadingMore.value = false;
    }
  }

  Future<List<WithdrawModel>> _fetchPage() async {
    Query<Map<String, dynamic>> query = _firestore.collection('withdraws');
    if (selectedStatusFilter.value != 'all') {
      query = query.where('status', isEqualTo: selectedStatusFilter.value);
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

    final page = snapshot.docs
        .map((document) => WithdrawModel.fromJson(document.data(), document.id))
        .toList();
    page.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return page;
  }

  Future<void> updateWithdrawStatus(
    String withdrawId,
    String newStatus, {
    String? notes,
  }) async {
    if (isUpdating.value) return;
    try {
      isUpdating.value = true;
      await _firestore.runTransaction((transaction) async {
        final withdrawReference = _firestore
            .collection('withdraws')
            .doc(withdrawId);
        final withdrawDocument = await transaction.get(withdrawReference);
        if (!withdrawDocument.exists) {
          throw StateError('Withdraw tidak ditemukan');
        }

        final data = withdrawDocument.data()!;
        final oldStatus = data['status']?.toString() ?? 'pending';
        final mentorId = data['mentorId']?.toString() ?? '';
        final nominal = (data['nominal'] as num?)?.toInt() ?? 0;

        DocumentReference<Map<String, dynamic>>? mentorReference;
        DocumentSnapshot<Map<String, dynamic>>? mentorDocument;
        if (mentorId.isNotEmpty && nominal > 0) {
          mentorReference = _firestore.collection('users').doc(mentorId);
          mentorDocument = await transaction.get(mentorReference);
          if (!mentorDocument.exists) {
            throw StateError('Mentor tidak ditemukan');
          }
        }

        if (mentorReference != null && mentorDocument != null) {
          final currentBalance =
              (mentorDocument.data()?['saldo'] as num?)?.toInt() ?? 0;
          var newBalance = currentBalance;
          if (oldStatus == 'approved' && newStatus == 'rejected') {
            newBalance += nominal;
          } else if (newStatus == 'approved' && oldStatus != 'approved') {
            newBalance -= nominal;
            if (newBalance < 0) {
              throw StateError('Saldo mentor tidak mencukupi');
            }
          }
          if (newBalance != currentBalance) {
            transaction.update(mentorReference, {'saldo': newBalance});
          }
        }

        final update = <String, dynamic>{
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
          'adminId': currentUserId,
        };
        if (notes != null && notes.trim().isNotEmpty) {
          update['notes'] = notes.trim();
        }
        transaction.update(withdrawReference, update);
      });

      final index = withdraws.indexWhere((item) => item.id == withdrawId);
      if (index >= 0) {
        if (selectedStatusFilter.value != 'all' &&
            selectedStatusFilter.value != newStatus) {
          withdraws.removeAt(index);
        } else {
          final old = withdraws[index];
          withdraws[index] = WithdrawModel(
            id: old.id,
            mentorId: old.mentorId,
            mentorName: old.mentorName,
            nominal: old.nominal,
            namaRekening: old.namaRekening,
            nomorRekening: old.nomorRekening,
            status: newStatus,
            createdAt: old.createdAt,
            updatedAt: DateTime.now(),
            adminId: currentUserId,
            notes: notes ?? old.notes,
          );
        }
      }

      CustomSnackbar.show(
        title: 'Berhasil',
        message: 'Status withdraw berhasil diperbarui',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (error) {
      AppLogger.info('Error updating withdraw: $error');
      CustomSnackbar.show(
        title: 'Gagal',
        message: error is StateError
            ? error.message
            : 'Status withdraw tidak dapat diperbarui',
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
        return AppColors.primaryColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  List<WithdrawModel> get filteredWithdraws {
    if (selectedStatusFilter.value == 'all') return withdraws;
    return withdraws
        .where((item) => item.status == selectedStatusFilter.value)
        .toList(growable: false);
  }
}
