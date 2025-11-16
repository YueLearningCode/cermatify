import 'package:get/get.dart';

import '../controllers/complink_controller.dart';

class ComplinkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplinkController>(
      () => ComplinkController(),
    );
  }
}
