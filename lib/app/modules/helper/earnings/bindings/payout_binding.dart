import 'package:get/get.dart';

import '../controllers/payout_controller.dart';

class HelperPayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperPayoutController>(() => HelperPayoutController());
  }
}
