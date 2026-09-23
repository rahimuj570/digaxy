import 'package:get/get.dart';

class HelperTaskLiveController extends GetxController {
  final title = 'Live Movement'.obs;
  final from = 'Los Angeles'.obs;
  final to = 'Santa Monic'.obs;
  final distance = '12.4km'.obs;
  final eta = '22-28mins'.obs;
  final customerName = 'John Mathew'.obs;
  final customerTax = 'TAX 2345'.obs;

  final pickupAddress = '1234 Sunset Blvd, Apt 12B, Los Angeles, CA 90026'.obs;
  final dropoffAddress = '8769 Ocean View Ave Santa Monica, CA 90405'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['pickup'] != null) pickupAddress.value = args['pickup'];
      if (args['dropoff'] != null) dropoffAddress.value = args['dropoff'];
      if (args['customerName'] != null) {
        customerName.value = args['customerName'];
      }
    }
  }
}
