import 'package:get/get.dart';
import 'package:cermatify/app/data/dummy_pacomp.dart';

class PaperlinkController extends GetxController {
  // Filter selections
  var selectedUniversitas = ''.obs;
  var selectedJurusan = ''.obs;
  var selectedLayanan = ''.obs;

  // Lists from dummy data
  List<String> get listUniversitas => dummyUniversitas;
  List<String> get listJurusan => dummyJurusan;
  List<String> get listLayanan => dummyLayanan;

  // Check if all filters are selected
  bool get isFilterComplete =>
      selectedUniversitas.isNotEmpty && selectedJurusan.isNotEmpty && selectedLayanan.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void resetFilters() {
    selectedUniversitas.value = '';
    selectedJurusan.value = '';
    selectedLayanan.value = '';
  }
}
