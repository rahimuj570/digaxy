import 'package:digaxy/app/routes/app_pages.dart';
import 'package:get/get.dart';

class HelperPayoutController extends GetxController {
  final available = 86.5.obs;
  final selectedMethod = 'bank'.obs;
  final instantFee = 0.0.obs;
  final expressFee = 1.0.obs;

  final amount = 0.0.obs;
  final lastPayoutAmount = 0.0.obs;

  void selectMethod(String method) => selectedMethod.value = method;

  void continuePayout() {
    Get.toNamed(Routes.HELPER_PAYOUT_AMOUNT);
  }

  void setAmount(double value) {
    amount.value = value;
  }

  void withdrawFull() {
    amount.value = available.value;
    Get.toNamed(Routes.HELPER_PAYOUT_CONFIRM);
  }

  void gotoConfirm() {
    Get.toNamed(Routes.HELPER_PAYOUT_CONFIRM);
  }

  Future<void> confirmPayout() async {
    lastPayoutAmount.value = amount.value;
    await Future.delayed(const Duration(milliseconds: 400));
    Get.offNamed(Routes.HELPER_PAYOUT_SUCCESS);
  }
}
