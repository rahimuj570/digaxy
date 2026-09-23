import 'package:get/get.dart';
import '../controllers/helper_task_active_controller.dart';

class HelperTaskActiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperTaskActiveController>(() => HelperTaskActiveController());
  }
}
