import 'package:digaxy/app/modules/driver/task/controllers/task_live_controller.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:get/get.dart';

class HelperTaskLiveController extends TaskLiveController {
  final isCancelling = false.obs;

  Future<void> withdrawDeal() async {
    final id = parcelNumericId.value;
    if (id == null) {
      Get.snackbar('Error', 'Missing parcel id');
      return;
    }

    try {
      isCancelling.value = true;
      final api = Get.isRegistered<ApiService>()
          ? Get.find<ApiService>()
          : ApiService();
      await api.cancelHelperDeal(id: id);
      Get.snackbar('Success', 'Successfully withdrawn from helper delivery');
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(Routes.HELPER_HOME);
    } catch (e) {
      Get.snackbar(
        'Withdraw Failed',
        e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
    } finally {
      isCancelling.value = false;
    }
  }
}
