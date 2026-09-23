import 'package:get/get.dart';

import '../controllers/mover_home_controller.dart';

class MoverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoverHomeController>(
      () => MoverHomeController(),
    );
  }
}
