import 'package:get/get.dart';

class DashboardController extends GetxController {
  static const int homeIndex = 0;

  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map && arguments['initialTab'] is int) {
      currentIndex.value = (arguments['initialTab'] as int).clamp(0, 4);
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Dashboard anggota selalu dibuka dari Home saat memulai sesi baru.
  void resetToHome() {
    currentIndex.value = homeIndex;
  }
}
