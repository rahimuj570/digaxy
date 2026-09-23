import 'package:get/get.dart';

import '../../../../../services/api/api_service.dart';

import '../controllers/helper_settings_controller.dart';

class HelperSettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    if (!Get.isRegistered<HelperSettingsController>()) {
      Get.lazyPut<HelperSettingsController>(() => HelperSettingsController());
    }
  }
}
