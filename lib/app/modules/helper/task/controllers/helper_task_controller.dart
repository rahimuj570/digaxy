import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:digaxy/shared/widgets/app_snackbar.dart';

class HelperTaskDetailController extends GetxController {
  final title = 'New Task - Job #4582'.obs;
  final assignedAt = 'Assigned at 4:00PM'.obs;
  final deliveryId = '8535385XX'.obs;

  final pickupAddress = '123 sunset blvd, apt 12b los angeles, Ca 90026'.obs;
  final dropoffAddress = '4321 Vube st los angeles, ca 90048'.obs;
  final customerName = 'John Doe'.obs;
  final customerPhone = '(79799-00)'.obs;

  final items = <String>[
    '3 * Grocery Bags',
    '1 * Electronics Box',
    'Fragile: Yes',
    'Total Weight: 19lbs',
    'Special Note: Leave at door if no one home',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['jobId'] != null) {
        title.value = 'New Task - Job #${args['jobId']}';
      }
      if (args['pickup'] != null) pickupAddress.value = args['pickup'];
      if (args['dropoff'] != null) dropoffAddress.value = args['dropoff'];
    }
  }

  void confirmTask() {
    AppSnackbar.success(
      'Confirmed',
      'Task accepted. Please check your active tasks.',
    );

    try {
      Get.toNamed(
        '/helper/task/active',
        arguments: {
          'jobId': deliveryId.value,
          'pickup': pickupAddress.value,
          'dropoff': dropoffAddress.value,
          'customerName': customerName.value,
          'customerPhone': customerPhone.value,
        },
      );
      return;
    } catch (_) {}
    try {
      final ctx = Get.context;
      if (ctx != null) {
        Navigator.of(ctx).pop();
        return;
      }
    } catch (_) {}
    try {
      Get.back();
    } catch (_) {}
  }
}
