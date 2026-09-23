import 'package:get/get.dart';

import '../controllers/driver_home_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../../notification/controllers/notification_controller.dart';

class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());

    // also provide earnings and notification controllers so embedded tabs can use them
    Get.lazyPut<EarningsController>(() => EarningsController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
