import 'package:get/get.dart';
import '../controllers/order_history_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderHistoryController());
  }
}
