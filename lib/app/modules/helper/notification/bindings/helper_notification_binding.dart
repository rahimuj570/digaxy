import '../controllers/helper_notification_controller.dart';
import 'package:get/get.dart';

class HelperNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperNotificationController>(
      () => HelperNotificationController(),
    );
  }
}
