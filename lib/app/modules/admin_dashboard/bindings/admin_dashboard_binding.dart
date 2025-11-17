import 'package:get/get.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../../admin_home/controllers/admin_home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../users/controllers/users_controller.dart';
import '../../master_data/controllers/master_data_controller.dart';
import '../../admin_orders/controllers/admin_orders_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<UsersController>(() => UsersController());
    Get.lazyPut<MasterDataController>(() => MasterDataController());
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController());
  }
}
