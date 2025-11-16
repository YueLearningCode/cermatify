import 'package:get/get.dart';

import '../controllers/sourcelink_controller.dart';

class SourcelinkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SourcelinkController>(
      () => SourcelinkController(),
    );
  }
}
