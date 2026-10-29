import 'package:cloud_functions/cloud_functions.dart';
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

  String? _withdrawRequestId;
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  static const int minWithdraw = 20000; // Keputusan pemilik: minimum Rp20.000

  @override
  void onClose() {
    nominalController.dispose();
    namaRekeningController.dispose();
    nomorRekeningController.dispose();
    super.onClose();
  }

  Future<void> submitWithdraw() async {
    if (isLoading.value || !(formKey.currentState?.validate() ?? false)) {
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
      if (userData['role'] != 'mentor' || userData['status'] != 'active') {
        throw StateError('Withdraw hanya tersedia untuk mentor aktif.');
      }
      final currentSaldo =
          ((userData['saldo'] as num?)?.toInt() ?? 0) +
          ((userData['playAvailable'] as num?)?.toInt() ?? 0);
      if (namaRekeningController.text.trim().isEmpty ||
          !RegExp(r'^\d+$').hasMatch(nomorRekeningController.text.trim())) {
        throw StateError('Isi nama pemilik dan nomor rekening yang valid.');
      }

      // Parse nominal
      final nominal =
          int.tryParse(
            nominalController.text.trim().replaceAll(RegExp(r'[^\d]'), ''),
          ) ??
          0;

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
          message:
              'Saldo tidak mencukupi. Saldo Anda: ${_formatPrice(currentSaldo)}',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      _withdrawRequestId ??= _firestore.collection('withdraws').doc().id;
      await FirebaseFunctions.instanceFor(
        region: 'asia-southeast2',
      ).httpsCallable('requestWithdrawal').call({
        'requestId': _withdrawRequestId,
        'nominal': nominal,
        'namaRekening': namaRekeningController.text.trim(),
        'nomorRekening': nomorRekeningController.text.trim(),
      });

      // Clear form
      nominalController.clear();
      namaRekeningController.clear();
      nomorRekeningController.clear();

      // Close dialog and remove controller
      Get.back();
      Get.delete<WithdrawController>();

      CustomSnackbar.show(
        title: 'Sukses',
        message:
            'Permintaan withdraw berhasil diajukan. Menunggu persetujuan admin.',
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
