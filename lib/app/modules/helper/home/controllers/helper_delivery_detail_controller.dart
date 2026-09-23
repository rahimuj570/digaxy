import 'package:get/get.dart';

class HelperDeliveryDetailController extends GetxController {
  final title = 'Santa Monica › Beverly Hills'.obs;
  final routeSummary = 'Santa Monica › Beverly Hills'.obs;
  final distance = '18.2 miles'.obs;
  final eta = 'Est. 32 mins'.obs;
  final status = 'Completed'.obs;

  final deliveryId = '8535385XX'.obs;

  final pickupAddress = '123 Sunset Blvd, Apt 12B, Los Angeles, CA 90026'.obs;
  final dropoffAddress = '4321 Vue St Los Angeles, CA 90848'.obs;
  final pickupContact = 'John Doe (79799-00)'.obs;
  final pickupTime = '10:55 AM'.obs;
  final dropoffTime = '11:55 AM'.obs;

  final trackingNote = 'Picked up at 3:14PM'.obs;
  final trackingAddress =
      '441 Ocean Parkway, Apt 4C Brooklyn, NY 24232, Tanya (503530-58)'.obs;

  final orderSummary = <String>[
    "3 * Grocery Bags",
    "1 * Electronics Box",
    "Fragile: Yes",
    "Total Weight: 19lbs",
    "Special Note: Leave at door if no one home",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      routeSummary.value = args['routeSummary'] ?? routeSummary.value;
      title.value = args['routeSummary'] ?? title.value;
      distance.value = args['distance'] ?? distance.value;
      eta.value = args['eta'] ?? eta.value;
      status.value = args['status'] ?? status.value;
      deliveryId.value = args['deliveryId'] ?? deliveryId.value;
      pickupAddress.value = args['pickupAddress'] ?? pickupAddress.value;
      dropoffAddress.value = args['dropoffAddress'] ?? dropoffAddress.value;
      pickupContact.value = args['pickupContact'] ?? pickupContact.value;
      pickupTime.value = args['pickupTime'] ?? pickupTime.value;
      dropoffTime.value = args['dropoffTime'] ?? dropoffTime.value;
      final os = args['orderSummary'];
      if (os != null && os is List) {
        orderSummary.assignAll(os.map((e) => e.toString()).toList());
      }
    }
  }

  void navigateToDropoff() {
    Get.snackbar('Navigate', 'Launching navigation (placeholder)');
  }
}
