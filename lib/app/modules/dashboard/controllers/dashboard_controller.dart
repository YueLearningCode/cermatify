import 'package:get/get.dart';

class DashboardController extends GetxController {
  static const int homeIndex = 0;

  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Dashboard anggota selalu dibuka dari Home saat memulai sesi baru.
  void resetToHome() {
    currentIndex.value = homeIndex;
  }
}
