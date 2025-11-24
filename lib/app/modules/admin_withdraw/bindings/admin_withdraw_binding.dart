import 'package:get/get.dart';
import '../controllers/admin_withdraw_controller.dart';

class AdminWithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminWithdrawController>(() => AdminWithdrawController());
  }
}
