import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminKuesionerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final kuesioners = <Kuesioner>[].obs;
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final selectedStatusFilter = 'all'.obs; // 'all', 'waiting verification', 'approved', 'rejected'

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchKuesioners();
  }

  Future<void> fetchKuesioners() async {
    try {
      isLoading.value = true;

      Query<Map<String, dynamic>> query = _firestore.collection('kuesioners');

      // Apply status filter if not 'all'
      if (selectedStatusFilter.value != 'all') {
        query = query.where('status', isEqualTo: selectedStatusFilter.value);
      }

      try {
        // Try with orderBy first
        final querySnapshot = await query.orderBy('createdAt', descending: true).get();
        final kuesionersList = querySnapshot.docs.map((doc) {
          return Kuesioner.fromJson(doc.data(), doc.id);
        }).toList();
        kuesioners.value = kuesionersList;
      } catch (e) {
        // If orderBy fails, fetch without orderBy
        print('Error with orderBy, trying without: $e');
        final querySnapshot = await query.get();
        final kuesionersList = querySnapshot.docs.map((doc) {
          return Kuesioner.fromJson(doc.data(), doc.id);
        }).toList();

        // Sort manually by createdAt
        kuesionersList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        kuesioners.value = kuesionersList;
      }
    } catch (e) {
      print('Error fetching kuesioners: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal mengambil data kuesioner: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
      kuesioners.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateKuesionerStatus(String kuesionerId, String newStatus) async {
    try {
      isUpdating.value = true;

      // Get current kuesioner data
      final kuesionerDoc = await _firestore.collection('kuesioners').doc(kuesionerId).get();
      if (!kuesionerDoc.exists) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Kuesioner tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      final kuesionerData = kuesionerDoc.data();
      final orderId = kuesionerData?['orderId'] as String?;

      // Update kuesioner status
      await _firestore.collection('kuesioners').doc(kuesionerId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'adminId': currentUserId,
      });

      // If approved, also update the order status to 'progress'
      if (newStatus == 'approved' && orderId != null && orderId.isNotEmpty) {
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'progress',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // If rejected, also update the order status to 'rejected'
      if (newStatus == 'rejected' && orderId != null && orderId.isNotEmpty) {
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Refresh kuesioners list
      await fetchKuesioners();

      CustomSnackbar.show(
        title: 'Success',
        message: 'Status kuesioner berhasil diupdate',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal update status kuesioner: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void changeStatusFilter(String status) {
    selectedStatusFilter.value = status;
    fetchKuesioners();
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return AppColors.greenColor;
      case 'rejected':
        return AppColors.redColor;
      case 'waiting verification':
        return AppColors.yellowColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'waiting verification':
        return 'Waiting Verification';
      default:
        return 'Unknown';
    }
  }
}
