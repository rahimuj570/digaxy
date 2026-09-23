import 'package:get/get.dart';
import '../controllers/helper_task_live_controller.dart';

class HelperTaskLiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperTaskLiveController>(() => HelperTaskLiveController());
  }
}
