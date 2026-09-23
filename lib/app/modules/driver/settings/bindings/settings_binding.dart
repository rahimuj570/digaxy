import 'package:get/get.dart';
import '../../../../../services/api/api_service.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
