import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplinkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Single filter: Cabang Lomba Akademik - store ID
  var selectedCabang = ''.obs; // Store layanan ID

  // Lists from Firebase
  final listLayanan = <Map<String, String>>[].obs; // [{id: '...', name: '...', type: 'complink'}]

  // Get filtered layanan for complink only
  List<Map<String, String>> get filteredLayanan {
    return listLayanan.where((layanan) => layanan['type'] == 'complink').toList();
  }

  // Get name for display (for passing to ListMentorView)
  String get selectedCabangName {
    return filteredLayanan.firstWhereOrNull((l) => l['id'] == selectedCabang.value)?['name'] ?? selectedCabang.value;
  }

  // Check if all filters are selected
  bool get isFilterComplete => selectedCabang.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchMasterData();
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
      // Fetch layanan filtered by complink type
      final layananSnapshot = await _firestore.collection('layanan').where('type', isEqualTo: 'complink').get();
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
    selectedCabang.value = '';
  }
}
