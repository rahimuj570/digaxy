import 'package:get/get.dart';

import '../controllers/task_active_controller.dart';

class TaskActiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskActiveController>(() => TaskActiveController());
  }
}
