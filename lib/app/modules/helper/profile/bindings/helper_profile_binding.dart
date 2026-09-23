import 'package:get/get.dart';

import '../controllers/helper_profile_controller.dart';
import '../controllers/helper_edit_profile_controller.dart';

class HelperProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HelperProfileController>()) {
      Get.lazyPut<HelperProfileController>(() => HelperProfileController());
    }
    if (!Get.isRegistered<HelperEditProfileController>()) {
      Get.lazyPut<HelperEditProfileController>(
        () => HelperEditProfileController(),
      );
    }
  }
}
