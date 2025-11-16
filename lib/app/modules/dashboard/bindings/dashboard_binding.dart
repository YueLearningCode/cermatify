import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../kuesioner/controllers/kuesioner_controller.dart';
import '../../faq/controllers/faq_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<KuesionerController>(() => KuesionerController());
    Get.lazyPut<FaqController>(() => FaqController());
  }
}
