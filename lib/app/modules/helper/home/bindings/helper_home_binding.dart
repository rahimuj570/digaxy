import 'package:get/get.dart';

import '../controllers/helper_home_controller.dart';
import '../../../driver/earnings/controllers/earnings_controller.dart';
import '../../../driver/notification/controllers/notification_controller.dart';

class HelperHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperHomeController>(() => HelperHomeController());

    // Provide earnings and notification controllers so embedded tabs can use them
    Get.lazyPut<EarningsController>(() => EarningsController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
