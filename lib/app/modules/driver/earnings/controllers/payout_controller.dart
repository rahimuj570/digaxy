import 'package:digaxy/app/routes/app_pages.dart';
import 'package:get/get.dart';

class PayoutController extends GetxController {
  final available =
      86.5.obs; // sample balance — real value should be passed or read
  final selectedMethod = 'bank'.obs; // 'bank' or 'bkash'
  final instantFee = 0.0.obs;
  final expressFee = 1.0.obs;

  // amount entered by user
  final amount = 0.0.obs;

  // last successful payout amount (for success screen)
  final lastPayoutAmount = 0.0.obs;

  void selectMethod(String method) => selectedMethod.value = method;

  // Called from initial Payout screen -> goes to Enter Amount
  void continuePayout() {
    Get.toNamed(Routes.DRIVER_PAYOUT_AMOUNT);
  }

  void setAmount(double value) {
    amount.value = value;
  }

  void withdrawFull() {
    amount.value = available.value;
    // go to confirm screen
    Get.toNamed(Routes.DRIVER_PAYOUT_CONFIRM);
  }

  void gotoConfirm() {
    Get.toNamed(Routes.DRIVER_PAYOUT_CONFIRM);
  }

  Future<void> confirmPayout() async {
    // In a real app: call payout API here. We'll simulate success.
    lastPayoutAmount.value = amount.value;
    await Future.delayed(const Duration(milliseconds: 400));
    Get.offNamed(Routes.DRIVER_PAYOUT_SUCCESS);
  }
}
