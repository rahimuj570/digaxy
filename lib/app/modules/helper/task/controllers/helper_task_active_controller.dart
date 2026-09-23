import 'package:get/get.dart';

class HelperTaskActiveController extends GetxController {
  final title = 'New Job Assigned!'.obs;
  final subtitle = 'You have been assigned a new delivery task'.obs;

  final pickupAddress = '1234 Sunset Blvd, Apt 12B, Los Angeles, CA 90026'.obs;
  final dropoffAddress = '8769 Ocean View Ave Santa Monica, Ca 90405'.obs;
  final scheduledTime = '10:00AM - 12:00PM'.obs;
  final itemType = 'Medium (Furniture, Electronics)'.obs;
  final item = 'Furniture'.obs;
  final date = 'Nov 12, 2025'.obs;
  final distancePay = '\$3.20'.obs;
  final totalHelperPay = '\$22.20'.obs;

  final customerName = 'John Mathew'.obs;
  final customerTax = 'TAX 2345'.obs;

  final paymentMethod = 'Stripe'.obs;
  final transactionId = '#GP2345K'.obs;
  final paymentStatus = 'Unpaid'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['jobId'] != null) title.value = 'New Job Assigned!';
      if (args['pickup'] != null) pickupAddress.value = args['pickup'];
      if (args['dropoff'] != null) dropoffAddress.value = args['dropoff'];
      if (args['customerName'] != null) {
        customerName.value = args['customerName'];
      }
    }
  }
}
