import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/models/competition_catalog.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplinkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = true.obs;
  final loadError = ''.obs;

  // Single filter: Cabang Lomba Akademik - store ID
  var selectedCabang = ''.obs; // Store layanan ID
  final selectedCategory = ''.obs;
  final categories = <Map<String, String>>[].obs;

  // Lists from Firebase
  final listLayanan = <Map<String, String>>[]
      .obs; // [{id: '...', name: '...', type: 'complink'}]

  // Get filtered layanan for complink only
  List<Map<String, String>> get filteredLayanan {
    return competitionServicesForCategory(listLayanan, selectedCategory.value);
  }

  // Get name for display (for passing to ListMentorView)
  String get selectedCabangName {
    return filteredLayanan.firstWhereOrNull(
          (l) => l['id'] == selectedCabang.value,
        )?['name'] ??
        selectedCabang.value;
  }

  // Check if all filters are selected
  bool get isFilterComplete => selectedCabang.isNotEmpty;

  String get selectedCategoryName =>
      categories.firstWhereOrNull(
        (category) => category['id'] == selectedCategory.value,
      )?['name'] ??
      '';

  String serviceChoiceLabel(Map<String, String> service) {
    final name = service['name'] ?? '';
    final categoryName = categories.firstWhereOrNull(
      (category) => category['id'] == service['competitionCategoryId'],
    )?['name'];
    return categoryName == null ? name : '$name — $categoryName';
  }

  @override
  void onInit() {
    super.onInit();
    fetchMasterData();
    ever(selectedCategory, (_) => selectedCabang.value = '');
  }

  // Fetch master data from Firebase
  Future<void> fetchMasterData() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      // Fetch layanan filtered by complink type
      final snapshots = await Future.wait([
        _firestore
            .collection('competitionCategories')
            .where('active', isEqualTo: true)
            .get(),
        _firestore
            .collection('layanan')
            .where('type', isEqualTo: 'complink')
            .get(),
      ]);
      categories.assignAll(
        snapshots[0].docs.map(
          (doc) => {'id': doc.id, 'name': doc.data()['name']?.toString() ?? ''},
        ),
      );
      categories.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      final layananSnapshot = snapshots[1];
      listLayanan.value = layananSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name']?.toString() ?? '',
              'type': data['type']?.toString() ?? '',
              'competitionCategoryId':
                  data['competitionCategoryId']?.toString() ?? '',
            };
          })
          .toList()
          .cast<Map<String, String>>();
      listLayanan.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      if (selectedCategory.value.isNotEmpty &&
          selectedCategory.value != uncategorizedCompetitionId &&
          !categories.any(
            (category) => category['id'] == selectedCategory.value,
          )) {
        selectedCategory.value = '';
      }
      if (!filteredLayanan.any(
        (service) => service['id'] == selectedCabang.value,
      )) {
        selectedCabang.value = '';
      }
    } catch (e) {
      AppLogger.info('Error fetching master data: $e');
      loadError.value = 'Daftar kategori kompetisi belum dapat dimuat.';
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    selectedCategory.value = '';
    selectedCabang.value = '';
  }
}
