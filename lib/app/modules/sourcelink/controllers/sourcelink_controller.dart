import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/dummy_sourcelink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SourcelinkController extends GetxController {
  // Filter selections
  var selectedUsia = dummyRentangUsia.first.obs;
  var selectedKelamin = dummyJenisKelamin.first.obs;
  var selectedPenghasilan = dummyTingkatPenghasilan.first.obs;
  var selectedPendidikan = dummyPendidikanTerakhir.first.obs;

  // Text controllers
  final TextEditingController kriteriaController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  final isSubmitting = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    // Initialize with first values
    selectedUsia.value = dummyRentangUsia.first;
    selectedKelamin.value = dummyJenisKelamin.first;
    selectedPenghasilan.value = dummyTingkatPenghasilan.first;
    selectedPendidikan.value = dummyPendidikanTerakhir.first;
  }

  @override
  void onClose() {
    kriteriaController.dispose();
    linkController.dispose();
    super.onClose();
  }

  Future<void> createKuesioner() async {
    final String link = linkController.text.trim();
    if (link.isEmpty) {
      Get.snackbar('Perhatian', 'Masukkan link terlebih dahulu');
      return;
    }

    isSubmitting.value = true;
    try {
      final String uid = _auth.currentUser?.uid ?? (await _auth.signInAnonymously()).user!.uid;
      final data = {
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'link': link,
        'kriteriaLain': kriteriaController.text.trim(),
        'rentangUsia': selectedUsia.value,
        'jenisKelamin': selectedKelamin.value,
        'tingkatPenghasilan': selectedPenghasilan.value,
        'pendidikanTerakhir': selectedPendidikan.value,
        'status': 'open',
      };
      await _firestore.collection('kuesioners').add(data);
    } finally {
      isSubmitting.value = false;
    }
  }
}
