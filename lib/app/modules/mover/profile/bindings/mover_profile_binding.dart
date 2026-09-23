import 'package:get/get.dart';
import 'package:digaxy/services/api/api_service.dart';
import '../controllers/mover_profile_controller.dart';

class MoverProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    }
    Get.lazyPut<MoverProfileController>(() => MoverProfileController());
  }
}
