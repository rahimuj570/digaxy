import 'package:get/get.dart';

import '../controllers/helper_priority_controller.dart';

class HelperPriorityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperPriorityController>(() => HelperPriorityController());
  }
}
