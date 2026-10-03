import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:get/get.dart';

class HelperPayoutController extends GetxController {
  final available = 0.0.obs;
  final selectedMethod = 'bank'.obs;
  final instantFee = 0.0.obs;
  final expressFee = 1.0.obs;

  final amount = 0.0.obs;
  final lastPayoutAmount = 0.0.obs;
  final bankName = 'Bank Transfer'.obs;
  final accountNumber = ''.obs;
  final accountHolderName = ''.obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();
    loadWalletInfo();
  }

  Future<void> loadWalletInfo() async {
    try {
      isLoading.value = true;
      final res = await _api.fetchWalletInfo();
      if (res['data'] is Map) {
        final data = Map<String, dynamic>.from(res['data']);
        final val = double.tryParse((data['earn_money'] ?? '').toString());
        if (val != null) {
          available.value = val;
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

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
    if (amount.value <= 0) {
      AppSnackbar.error('Error', 'Please enter a valid payout amount');
      return;
    }

    try {
      isSubmitting.value = true;
      lastPayoutAmount.value = amount.value;

      final bank = bankName.value.isNotEmpty ? bankName.value : 'City Bank';
      final accNum = accountNumber.value.isNotEmpty ? accountNumber.value : '01700000000';
      final accHolder = accountHolderName.value.isNotEmpty ? accountHolderName.value : 'Helper User';

      await _api.requestWalletPayout(
        amount: amount.value,
        bankName: bank,
        accountNumber: accNum,
        accountHolderName: accHolder,
      );

      available.value = (available.value - amount.value).clamp(0.0, double.infinity);
      AppSnackbar.success('Success', 'Payout request submitted successfully');
      Get.offNamed(Routes.HELPER_PAYOUT_SUCCESS);
    } catch (e) {
      AppSnackbar.error(
        'Payout Failed',
        e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
