import 'package:cermatify/app/data/services/app_logger.dart';
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
  final String? competitionCategoryId;
  final bool active;
  final int? harga; // For layanan: price in Rupiah

  MasterDataItem({
    required this.id,
    required this.name,
    this.type,
    this.kampusId,
    this.harga,
    this.competitionCategoryId,
    this.active = true,
  });

  factory MasterDataItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MasterDataItem(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'],
      competitionCategoryId: data['competitionCategoryId'] as String?,
      active: data['active'] != false,
      kampusId: data['kampusId'],
      harga: data['harga'] != null
          ? (data['harga'] is int
                ? data['harga'] as int
                : int.tryParse(data['harga'].toString()))
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
    if (competitionCategoryId != null) {
      map['competitionCategoryId'] = competitionCategoryId;
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
  final competitionCategories = <MasterDataItem>[].obs;
  final selectedCompetitionCategory = ''.obs;
  final categoryActive = true.obs;
  final categoriesError = ''.obs;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final searchQuery = ''.obs;

  // Form controllers
  final nameController = TextEditingController();
  final hargaController =
      TextEditingController(); // For layanan: price in Rupiah
  final typeController = 'complink'.obs; // For layanan
  final selectedKampusForJurusan = ''.obs; // For creating/editing jurusan

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  @override
  void onClose() {
    nameController.dispose();
    hargaController.dispose();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchKampus(),
        fetchJurusan(),
        fetchLayanan(),
        fetchCategories(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchKampus() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        // Try with orderBy createdAt first
        snapshot = await _firestore
            .collection('kampus')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If orderBy fails, fetch without orderBy
        AppLogger.info('Error with orderBy createdAt, trying without: $e');
        snapshot = await _firestore.collection('kampus').get();
      }

      // Map to items and sort by createdAt
      final items = snapshot.docs.map((doc) {
        final item = MasterDataItem.fromFirestore(doc);
        final data = doc.data();
        return {'item': item, 'createdAt': data['createdAt'] as Timestamp?};
      }).toList();

      // Sort by createdAt (newest first)
      items.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // Descending (newest first)
      });

      kampusList.value = items.map((e) => e['item'] as MasterDataItem).toList();
    } catch (e) {
      AppLogger.info('Error fetching kampus: $e');
      kampusList.value = [];
    }
  }

  Future<void> fetchJurusan() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        // Try with orderBy createdAt first
        snapshot = await _firestore
            .collection('jurusan')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If orderBy fails, fetch without orderBy
        AppLogger.info('Error with orderBy createdAt, trying without: $e');
        snapshot = await _firestore.collection('jurusan').get();
      }

      // Map to items and sort by createdAt
      final items = snapshot.docs.map((doc) {
        final item = MasterDataItem.fromFirestore(doc);
        final data = doc.data();
        return {'item': item, 'createdAt': data['createdAt'] as Timestamp?};
      }).toList();

      // Sort by createdAt (newest first)
      items.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // Descending (newest first)
      });

      jurusanList.value = items
          .map((e) => e['item'] as MasterDataItem)
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching jurusan: $e');
      jurusanList.value = [];
    }
  }

  Future<void> fetchLayanan() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        // Try with orderBy createdAt first
        snapshot = await _firestore
            .collection('layanan')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If orderBy fails, fetch without orderBy
        AppLogger.info('Error with orderBy createdAt, trying without: $e');
        snapshot = await _firestore.collection('layanan').get();
      }

      // Map to items and sort by createdAt
      final items = snapshot.docs.map((doc) {
        final item = MasterDataItem.fromFirestore(doc);
        final data = doc.data();
        return {'item': item, 'createdAt': data['createdAt'] as Timestamp?};
      }).toList();

      // Sort by createdAt (newest first)
      items.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // Descending (newest first)
      });

      layananList.value = items
          .map((e) => e['item'] as MasterDataItem)
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching layanan: $e');
      layananList.value = [];
    }
  }

  Future<void> fetchCategories() async {
    categoriesError.value = '';
    try {
      final snapshot = await _firestore
          .collection('competitionCategories')
          .get();
      competitionCategories.assignAll(
        snapshot.docs.map(MasterDataItem.fromFirestore),
      );
      competitionCategories.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } catch (_) {
      categoriesError.value =
          'Kategori lomba belum dapat dimuat. Coba muat ulang.';
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
      case 3:
        return 'competitionCategories';
      default:
        return 'kampus';
    }
  }

  List<MasterDataItem> getCurrentList() {
    switch (selectedTab.value) {
      case 0:
        // Show all kampus, already sorted by newest
        return kampusList;
      case 1:
        return _getFilteredJurusan();
      case 2:
        return _getFilteredLayanan();
      case 3:
        return competitionCategories;
      default:
        return kampusList;
    }
  }

  List<MasterDataItem> getVisibleList() {
    final items = getCurrentList();
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  List<MasterDataItem> _getFilteredJurusan() {
    if (selectedKampus.value.isEmpty) {
      return [];
    }
    // Filter by kampus and maintain sort order (already sorted by newest)
    return jurusanList
        .where((item) => item.kampusId == selectedKampus.value)
        .toList();
  }

  List<MasterDataItem> _getFilteredLayanan() {
    // Always show all layanan, sorted by newest (filter dropdown is for filtering, but default shows all)
    // The layananList is already sorted by newest from fetchLayanan()
    if (selectedLayananFilter.value == 'all') {
      // Show all layanan
      return List<MasterDataItem>.from(layananList);
    } else {
      // Filter by type but maintain sort order (already sorted by newest)
      return layananList
          .where((item) => item.type == selectedLayananFilter.value)
          .toList();
    }
  }

  Future<void> createItem(
    String name, {
    String? type,
    String? kampusId,
    int? harga,
    String? competitionCategoryId,
    bool active = true,
  }) async {
    if (isSaving.value) return;
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

      if (selectedTab.value == 3 && name.trim().length > 100) {
        CustomSnackbar.show(
          title: 'Nama kategori terlalu panjang',
          message: 'Gunakan maksimal 100 karakter.',
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
      final data = <String, dynamic>{
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (type != null) {
        data['type'] = type;
      }
      if (kampusId != null && kampusId.isNotEmpty) {
        data['kampusId'] = kampusId;
      }
      if (harga != null && harga > 0) {
        data['harga'] = harga;
      }

      if (collection == 'competitionCategories') {
        data['active'] = active;
        data['updatedAt'] = FieldValue.serverTimestamp();
      } else if (collection == 'layanan') {
        data['competitionCategoryId'] = type == 'complink'
            ? (competitionCategoryId ?? '')
            : '';
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

  Future<void> updateItem(
    String id,
    String name, {
    String? type,
    String? kampusId,
    int? harga,
    String? competitionCategoryId,
    bool active = true,
  }) async {
    if (isSaving.value) return;
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

      if (selectedTab.value == 3 && name.trim().length > 100) {
        CustomSnackbar.show(
          title: 'Nama kategori terlalu panjang',
          message: 'Gunakan maksimal 100 karakter.',
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

      if (collection == 'competitionCategories') {
        data['active'] = active;
        data['updatedAt'] = FieldValue.serverTimestamp();
      } else if (collection == 'layanan') {
        data['competitionCategoryId'] = type == 'complink'
            ? (competitionCategoryId ?? '')
            : '';
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

      if (collection == 'competitionCategories') {
        await _firestore.collection(collection).doc(id).update({
          'active': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection(collection).doc(id).delete();
      }

      CustomSnackbar.show(
        title: 'Success',
        message: collection == 'competitionCategories'
            ? 'Kategori diarsipkan. Relasi layanan tetap disimpan.'
            : 'Item deleted successfully',
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
    searchQuery.value = '';
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

  void updateSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  void openJurusanForKampus(String kampusId) {
    selectedTab.value = 1;
    selectedKampus.value = kampusId;
    selectedLayananFilter.value = 'all';
    searchQuery.value = '';
  }

  void openCreateDialog() {
    selectedCompetitionCategory.value = '';
    categoryActive.value = true;
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
        typeController.value =
            'complink'; // Default to complink if filter is 'all'
      }
    } else {
      typeController.value = 'complink';
    }
  }

  void openEditDialog(MasterDataItem item) {
    selectedCompetitionCategory.value = item.competitionCategoryId ?? '';
    categoryActive.value = item.active;
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
