import 'package:get/get.dart';
import '../controllers/admin_kuesioner_controller.dart';

class AdminKuesionerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminKuesionerController>(() => AdminKuesionerController());
  }
}
