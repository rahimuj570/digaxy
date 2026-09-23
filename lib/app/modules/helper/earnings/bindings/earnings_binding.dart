import 'package:get/get.dart';

import '../controllers/earnings_controller.dart';

class HelperEarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperEarningsController>(() => HelperEarningsController());
  }
}
