import 'package:get/get.dart';

class ComplinkController extends GetxController {
  // Single filter: Cabang Lomba Akademik
  var selectedCabang = ''.obs;

  // Fixed options shown in dropdown (as per design)
  final List<String> listCabang = const [
    'Business Plan Competition',
    'Startup Competition',
    'Olimpiade Mahasiswa',
    'Data Science Competition',
    'Programming Competition',
    'Debat Mahasiswa',
  ];

  // Check if all filters are selected
  bool get isFilterComplete => selectedCabang.isNotEmpty;

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
    selectedCabang.value = '';
  }
}
