import '../controllers/helper_delivery_detail_controller.dart';
import 'package:get/get.dart';

class HelperDeliveryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelperDeliveryDetailController>(
      () => HelperDeliveryDetailController(),
    );
  }
}
