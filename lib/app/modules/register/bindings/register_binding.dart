import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // Always delete existing controller to ensure fresh instance
    if (Get.isRegistered<RegisterController>()) {
      Get.delete<RegisterController>(force: true);
    }
    // Create a fresh controller instance
    Get.put<RegisterController>(RegisterController(), permanent: false);
  }
}
