import 'package:get/get.dart';

import '../controllers/paperlink_controller.dart';

class PaperlinkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaperlinkController>(
      () => PaperlinkController(),
    );
  }
}
