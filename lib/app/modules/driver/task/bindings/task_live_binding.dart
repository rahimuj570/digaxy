import 'package:get/get.dart';

import '../controllers/task_live_controller.dart';

class TaskLiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskLiveController>(() => TaskLiveController());
  }
}
