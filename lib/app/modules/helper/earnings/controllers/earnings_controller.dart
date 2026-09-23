import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class HelperEarningsController extends GetxController {
  final today = 0.0.obs;
  final week = 0.0.obs;
  final month = 0.0.obs;
  final lifetime = 0.0.obs;
  final pending = 0.0.obs;
  final lastPayoutDate = ''.obs;
  final paymentMethod = ''.obs;

  final earnings = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDummy();
  }

  void loadDummy() {
    today.value = 212.44;
    week.value = 812.33;
    month.value = 1438.50;
    lifetime.value = 8367.75;
    pending.value = 150.00;
    lastPayoutDate.value = 'Dec 1';
    paymentMethod.value = 'Stripe';

    earnings.assignAll([
      {
        'jobId': '#4553',
        'date': 'Aug 23, 4:12 PM',
        'route': 'Pickup → Drop-off',
      },
      {
        'jobId': '#4552',
        'date': 'Aug 20, 2:30 PM',
        'route': 'Pickup → Drop-off',
      },
    ]);
  }

  void requestPayout() {
    Get.toNamed(Routes.HELPER_PAYOUT);
  }
}
