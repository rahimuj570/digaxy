import 'package:get/get.dart';
import '../controllers/helper_task_controller.dart';

class HelperTaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperTaskDetailController>(() => HelperTaskDetailController());
  }
}
