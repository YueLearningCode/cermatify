import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaperlinkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLoading = true.obs;
  final loadError = ''.obs;

  // Filter selections - store IDs
  var selectedUniversitas = ''.obs; // Store kampus ID
  var selectedJurusan = ''.obs; // Store jurusan ID
  var selectedLayanan = ''.obs; // Store layanan ID

  // Lists from Firebase
  final listKampus = <Map<String, String>>[].obs; // [{id: '...', name: '...'}]
  final listJurusan = <Map<String, String>>[]
      .obs; // [{id: '...', name: '...', kampusId: '...'}]
  final listLayanan = <Map<String, String>>[]
      .obs; // [{id: '...', name: '...', type: 'paperlink'}]

  // Get filtered jurusan based on selected kampus
  List<Map<String, String>> get filteredJurusan {
    if (selectedUniversitas.value.isEmpty) return [];
    return listJurusan
        .where((jurusan) => jurusan['kampusId'] == selectedUniversitas.value)
        .toList();
  }

  // Get filtered layanan for paperlink only
  List<Map<String, String>> get filteredLayanan {
    return listLayanan
        .where((layanan) => layanan['type'] == 'paperlink')
        .toList();
  }

  // Get names for display (for passing to ListMentorView)
  String get selectedUniversitasName {
    return listKampus.firstWhereOrNull(
          (k) => k['id'] == selectedUniversitas.value,
        )?['name'] ??
        selectedUniversitas.value;
  }

  String get selectedJurusanName {
    return filteredJurusan.firstWhereOrNull(
          (j) => j['id'] == selectedJurusan.value,
        )?['name'] ??
        selectedJurusan.value;
  }

  String get selectedLayananName {
    return filteredLayanan.firstWhereOrNull(
          (l) => l['id'] == selectedLayanan.value,
        )?['name'] ??
        selectedLayanan.value;
  }

  // Check if all filters are selected
  bool get isFilterComplete =>
      selectedUniversitas.isNotEmpty &&
      selectedJurusan.isNotEmpty &&
      selectedLayanan.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchMasterData();
    // Reset jurusan when kampus changes
    ever(selectedUniversitas, (_) {
      selectedJurusan.value = '';
    });
  }

  // Fetch master data from Firebase
  Future<void> fetchMasterData() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final snapshots = await Future.wait([
        _firestore.collection('kampus').get(),
        _firestore.collection('jurusan').get(),
        _firestore
            .collection('layanan')
            .where('type', isEqualTo: 'paperlink')
            .get(),
      ]);
      final kampusSnapshot = snapshots[0];
      listKampus.value = kampusSnapshot.docs
          .map((doc) {
            return {'id': doc.id, 'name': doc.data()['name']?.toString() ?? ''};
          })
          .toList()
          .cast<Map<String, String>>();

      final jurusanSnapshot = snapshots[1];
      listJurusan.value = jurusanSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name']?.toString() ?? '',
              'kampusId': data['kampusId']?.toString() ?? '',
            };
          })
          .toList()
          .cast<Map<String, String>>();

      final layananSnapshot = snapshots[2];
      listLayanan.value = layananSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name']?.toString() ?? '',
              'type': data['type']?.toString() ?? '',
            };
          })
          .toList()
          .cast<Map<String, String>>();
      listKampus.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      listJurusan.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      listLayanan.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    } catch (e) {
      AppLogger.info('Error fetching master data: $e');
      loadError.value = 'Data pencarian belum dapat dimuat.';
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    selectedUniversitas.value = '';
    selectedJurusan.value = '';
    selectedLayanan.value = '';
  }
}
