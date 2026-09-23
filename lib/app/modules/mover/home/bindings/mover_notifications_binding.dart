import 'package:get/get.dart';

import '../controllers/mover_notifications_controller.dart';

class MoverNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoverNotificationsController>(
      () => MoverNotificationsController(),
    );
  }
}
