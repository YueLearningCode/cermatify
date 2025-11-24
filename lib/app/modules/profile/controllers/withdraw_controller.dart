import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class WithdrawController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController namaRekeningController = TextEditingController();
  final TextEditingController nomorRekeningController = TextEditingController();

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  static const int minWithdraw = 50000; // Minimum 50rb

  @override
  void onClose() {
    nominalController.dispose();
    namaRekeningController.dispose();
    nomorRekeningController.dispose();
    super.onClose();
  }

  Future<void> submitWithdraw() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final User? user = _auth.currentUser;
      if (user == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'User tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Data user tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final mentorName = userData['nama'] ?? user.displayName ?? 'Mentor';
      final currentSaldo = (userData['saldo'] as int?) ?? 0;

      // Parse nominal
      final nominal = int.tryParse(nominalController.text.trim().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

      // Validate nominal
      if (nominal < minWithdraw) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Minimal withdraw adalah Rp ${_formatPrice(minWithdraw)}',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      if (nominal > currentSaldo) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Saldo tidak mencukupi. Saldo Anda: ${_formatPrice(currentSaldo)}',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Create withdraw document
      final withdrawData = {
        'mentorId': user.uid,
        'mentorName': mentorName,
        'nominal': nominal,
        'namaRekening': namaRekeningController.text.trim(),
        'nomorRekening': nomorRekeningController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('withdraws').add(withdrawData);

      // Clear form
      nominalController.clear();
      namaRekeningController.clear();
      nomorRekeningController.clear();

      // Close dialog and remove controller
      Get.back();
      Get.delete<WithdrawController>();

      CustomSnackbar.show(
        title: 'Sukses',
        message: 'Permintaan withdraw berhasil diajukan. Menunggu persetujuan admin.',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Gagal mengajukan withdraw: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
