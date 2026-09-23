import 'package:get/get.dart';
import '../../../../../services/api/api_service.dart';
import '../controllers/mover_settings_controller.dart';

class MoverSettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<MoverSettingsController>(() => MoverSettingsController());
  }
}
