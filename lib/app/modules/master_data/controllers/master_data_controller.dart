import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class MasterDataItem {
  final String id;
  final String name;
  final String? type; // For layanan: 'complink' or 'paperlink'
  final String? kampusId; // For jurusan: links to kampus
  final int? harga; // For layanan: price in Rupiah

  MasterDataItem({required this.id, required this.name, this.type, this.kampusId, this.harga});

  factory MasterDataItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MasterDataItem(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'],
      kampusId: data['kampusId'],
      harga: data['harga'] != null
          ? (data['harga'] is int ? data['harga'] as int : int.tryParse(data['harga'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'name': name};
    if (type != null) {
      map['type'] = type;
    }
    if (kampusId != null) {
      map['kampusId'] = kampusId;
    }
    if (harga != null) {
      map['harga'] = harga;
    }
    return map;
  }
}

class MasterDataController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final selectedTab = 0.obs; // 0 = Kampus, 1 = Jurusan, 2 = Layanan
  final selectedLayananFilter = 'all'.obs; // 'all', 'complink', 'paperlink'
  final selectedKampus = ''.obs; // For filtering jurusan by kampus

  final kampusList = <MasterDataItem>[].obs;
  final jurusanList = <MasterDataItem>[].obs;
  final layananList = <MasterDataItem>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final hargaController = TextEditingController(); // For layanan: price in Rupiah
  final typeController = 'complink'.obs; // For layanan
  final selectedKampusForJurusan = ''.obs; // For creating/editing jurusan

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    nameController.dispose();
    hargaController.dispose();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    await Future.wait([fetchKampus(), fetchJurusan(), fetchLayanan()]);
  }

  Future<void> fetchKampus() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('kampus').orderBy('name').get();
      kampusList.value = snapshot.docs.map((doc) => MasterDataItem.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching kampus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchJurusan() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('jurusan').orderBy('name').get();
      jurusanList.value = snapshot.docs.map((doc) => MasterDataItem.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching jurusan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLayanan() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('layanan').orderBy('name').get();
      layananList.value = snapshot.docs.map((doc) => MasterDataItem.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching layanan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getCollectionName() {
    switch (selectedTab.value) {
      case 0:
        return 'kampus';
      case 1:
        return 'jurusan';
      case 2:
        return 'layanan';
      default:
        return 'kampus';
    }
  }

  List<MasterDataItem> getCurrentList() {
    switch (selectedTab.value) {
      case 0:
        return kampusList;
      case 1:
        return _getFilteredJurusan();
      case 2:
        return _getFilteredLayanan();
      default:
        return kampusList;
    }
  }

  List<MasterDataItem> _getFilteredJurusan() {
    if (selectedKampus.value.isEmpty) {
      return [];
    }
    return jurusanList.where((item) => item.kampusId == selectedKampus.value).toList();
  }

  List<MasterDataItem> _getFilteredLayanan() {
    if (selectedLayananFilter.value == 'all') {
      return layananList;
    }
    return layananList.where((item) => item.type == selectedLayananFilter.value).toList();
  }

  Future<void> createItem(String name, {String? type, String? kampusId, int? harga}) async {
    try {
      if (name.trim().isEmpty) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Name cannot be empty',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Validate kampusId for jurusan
      if (selectedTab.value == 1 && (kampusId == null || kampusId.isEmpty)) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Please select a kampus',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Validate harga for layanan
      if (selectedTab.value == 2 && (harga == null || harga <= 0)) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Please enter a valid price',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      isSaving.value = true;
      final collection = getCollectionName();
      final data = <String, dynamic>{'name': name.trim()};
      if (type != null) {
        data['type'] = type;
      }
      if (kampusId != null && kampusId.isNotEmpty) {
        data['kampusId'] = kampusId;
      }
      if (harga != null && harga > 0) {
        data['harga'] = harga;
      }

      await _firestore.collection(collection).add(data);

      // Close dialog first
      Get.back();

      // Then show success message and refresh data
      CustomSnackbar.show(
        title: 'Success',
        message: 'Item created successfully',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );

      await fetchAllData();
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to create item: $e',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateItem(String id, String name, {String? type, String? kampusId, int? harga}) async {
    try {
      if (name.trim().isEmpty) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Name cannot be empty',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Validate kampusId for jurusan
      if (selectedTab.value == 1 && (kampusId == null || kampusId.isEmpty)) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Please select a kampus',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      // Validate harga for layanan
      if (selectedTab.value == 2 && (harga == null || harga <= 0)) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Please enter a valid price',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return;
      }

      isSaving.value = true;
      final collection = getCollectionName();
      final data = <String, dynamic>{'name': name.trim()};
      if (type != null) {
        data['type'] = type;
      }
      if (kampusId != null && kampusId.isNotEmpty) {
        data['kampusId'] = kampusId;
      }
      if (harga != null && harga > 0) {
        data['harga'] = harga;
      }

      await _firestore.collection(collection).doc(id).update(data);

      // Close dialog first
      Get.back();

      // Then show success message and refresh data
      CustomSnackbar.show(
        title: 'Success',
        message: 'Item updated successfully',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );

      await fetchAllData();
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to update item: $e',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      isSaving.value = true;
      final collection = getCollectionName();

      await _firestore.collection(collection).doc(id).delete();

      CustomSnackbar.show(
        title: 'Success',
        message: 'Item deleted successfully',
        backgroundColor: AppColors.greenColor,
        isNav: false,
      );

      await fetchAllData();
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to delete item: $e',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    selectedLayananFilter.value = 'all';
    if (index != 1) {
      selectedKampus.value = '';
    }
  }

  void changeLayananFilter(String filter) {
    selectedLayananFilter.value = filter;
  }

  void changeKampusFilter(String kampusId) {
    selectedKampus.value = kampusId;
  }

  void openCreateDialog() {
    nameController.clear();
    hargaController.clear();
    // For jurusan, use the currently selected kampus from filter
    if (selectedTab.value == 1) {
      selectedKampusForJurusan.value = selectedKampus.value;
    } else {
      selectedKampusForJurusan.value = '';
    }
    // For layanan, use the currently selected filter (complink/paperlink)
    if (selectedTab.value == 2) {
      if (selectedLayananFilter.value != 'all') {
        typeController.value = selectedLayananFilter.value;
      } else {
        typeController.value = 'complink'; // Default to complink if filter is 'all'
      }
    } else {
      typeController.value = 'complink';
    }
  }

  void openEditDialog(MasterDataItem item) {
    nameController.text = item.name;
    if (item.harga != null) {
      hargaController.text = item.harga.toString();
    } else {
      hargaController.clear();
    }
    // For layanan, use the currently selected filter (not editable)
    if (selectedTab.value == 2) {
      if (selectedLayananFilter.value != 'all') {
        typeController.value = selectedLayananFilter.value;
      } else if (item.type != null) {
        typeController.value = item.type!;
      }
    } else if (item.type != null) {
      typeController.value = item.type!;
    }
    // For jurusan, use the currently selected kampus from filter (not editable)
    if (selectedTab.value == 1) {
      selectedKampusForJurusan.value = selectedKampus.value;
    } else if (item.kampusId != null) {
      selectedKampusForJurusan.value = item.kampusId!;
    }
  }
}
