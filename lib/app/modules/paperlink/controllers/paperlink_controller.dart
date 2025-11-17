import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaperlinkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Filter selections - store IDs
  var selectedUniversitas = ''.obs; // Store kampus ID
  var selectedJurusan = ''.obs; // Store jurusan ID
  var selectedLayanan = ''.obs; // Store layanan ID

  // Lists from Firebase
  final listKampus = <Map<String, String>>[].obs; // [{id: '...', name: '...'}]
  final listJurusan = <Map<String, String>>[].obs; // [{id: '...', name: '...', kampusId: '...'}]
  final listLayanan = <Map<String, String>>[].obs; // [{id: '...', name: '...', type: 'paperlink'}]

  // Get filtered jurusan based on selected kampus
  List<Map<String, String>> get filteredJurusan {
    if (selectedUniversitas.value.isEmpty) return [];
    return listJurusan.where((jurusan) => jurusan['kampusId'] == selectedUniversitas.value).toList();
  }

  // Get filtered layanan for paperlink only
  List<Map<String, String>> get filteredLayanan {
    return listLayanan.where((layanan) => layanan['type'] == 'paperlink').toList();
  }

  // Get names for display (for passing to ListMentorView)
  String get selectedUniversitasName {
    return listKampus.firstWhereOrNull((k) => k['id'] == selectedUniversitas.value)?['name'] ??
        selectedUniversitas.value;
  }

  String get selectedJurusanName {
    return filteredJurusan.firstWhereOrNull((j) => j['id'] == selectedJurusan.value)?['name'] ?? selectedJurusan.value;
  }

  String get selectedLayananName {
    return filteredLayanan.firstWhereOrNull((l) => l['id'] == selectedLayanan.value)?['name'] ?? selectedLayanan.value;
  }

  // Check if all filters are selected
  bool get isFilterComplete =>
      selectedUniversitas.isNotEmpty && selectedJurusan.isNotEmpty && selectedLayanan.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchMasterData();
    // Reset jurusan when kampus changes
    ever(selectedUniversitas, (_) {
      selectedJurusan.value = '';
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Fetch master data from Firebase
  Future<void> fetchMasterData() async {
    try {
      // Fetch kampus
      final kampusSnapshot = await _firestore.collection('kampus').get();
      listKampus.value = kampusSnapshot.docs
          .map((doc) {
            return {'id': doc.id, 'name': doc.data()['name']?.toString() ?? ''};
          })
          .toList()
          .cast<Map<String, String>>();

      // Fetch all jurusan
      final jurusanSnapshot = await _firestore.collection('jurusan').get();
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

      // Fetch layanan filtered by paperlink type
      final layananSnapshot = await _firestore.collection('layanan').where('type', isEqualTo: 'paperlink').get();
      listLayanan.value = layananSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {'id': doc.id, 'name': data['name']?.toString() ?? '', 'type': data['type']?.toString() ?? ''};
          })
          .toList()
          .cast<Map<String, String>>();
    } catch (e) {
      print('Error fetching master data: $e');
    }
  }

  void resetFilters() {
    selectedUniversitas.value = '';
    selectedJurusan.value = '';
    selectedLayanan.value = '';
  }
}
