import 'package:get/get.dart';

import '../controllers/master_data_controller.dart';

class MasterDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasterDataController>(() => MasterDataController());
  }
}
