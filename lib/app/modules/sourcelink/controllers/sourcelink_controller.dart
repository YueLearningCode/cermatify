import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/dummy_sourcelink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Keys for local storage
  static const String _keyUsia = 'sourcelink_usia';
  static const String _keyKelamin = 'sourcelink_kelamin';
  static const String _keyPenghasilan = 'sourcelink_penghasilan';
  static const String _keyPendidikan = 'sourcelink_pendidikan';
  static const String _keyKriteria = 'sourcelink_kriteria';

  @override
  void onInit() {
    super.onInit();
    // Initialize with first values
    selectedUsia.value = dummyRentangUsia.first;
    selectedKelamin.value = dummyJenisKelamin.first;
    selectedPenghasilan.value = dummyTingkatPenghasilan.first;
    selectedPendidikan.value = dummyPendidikanTerakhir.first;
    // Load saved criteria if exists
    loadSavedCriteria();
  }

  // Save criteria to local storage
  Future<void> saveCriteria() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsia, selectedUsia.value);
      await prefs.setString(_keyKelamin, selectedKelamin.value);
      await prefs.setString(_keyPenghasilan, selectedPenghasilan.value);
      await prefs.setString(_keyPendidikan, selectedPendidikan.value);
      await prefs.setString(_keyKriteria, kriteriaController.text);
    } catch (e) {
      print('Error saving criteria: $e');
    }
  }

  // Load criteria from local storage
  Future<void> loadSavedCriteria() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usia = prefs.getString(_keyUsia);
      final kelamin = prefs.getString(_keyKelamin);
      final penghasilan = prefs.getString(_keyPenghasilan);
      final pendidikan = prefs.getString(_keyPendidikan);
      final kriteria = prefs.getString(_keyKriteria);

      if (usia != null && usia.isNotEmpty) selectedUsia.value = usia;
      if (kelamin != null && kelamin.isNotEmpty) selectedKelamin.value = kelamin;
      if (penghasilan != null && penghasilan.isNotEmpty) selectedPenghasilan.value = penghasilan;
      if (pendidikan != null && pendidikan.isNotEmpty) selectedPendidikan.value = pendidikan;
      if (kriteria != null) kriteriaController.text = kriteria;
    } catch (e) {
      print('Error loading criteria: $e');
    }
  }

  // Clear saved criteria
  Future<void> clearSavedCriteria() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUsia);
      await prefs.remove(_keyKelamin);
      await prefs.remove(_keyPenghasilan);
      await prefs.remove(_keyPendidikan);
      await prefs.remove(_keyKriteria);
    } catch (e) {
      print('Error clearing criteria: $e');
    }
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
