import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../../services/websocket/websocket_bootstrap_service.dart';

class Splash2Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(seconds: 4), () async {
      final box = GetStorage();
      final isLoggedIn = (box.read('is_logged_in') as bool?) ?? false;

      if (!isLoggedIn) {
        Get.offNamed(Routes.LANDING_ONBOARDING);
        return;
      }

      final wsBootstrap = Get.isRegistered<WebSocketBootstrapService>()
          ? Get.find<WebSocketBootstrapService>()
          : Get.put(WebSocketBootstrapService(), permanent: true);
      await wsBootstrap.connectForAuthenticatedUser();

      final role = (box.read('user_role') as String?)?.toLowerCase();
      if (role == 'driver') {
        Get.offAllNamed(Routes.DRIVER_HOME);
      } else if (role == 'mover') {
        Get.offAllNamed(Routes.MOVER_HOME);
      } else if (role == 'helper') {
        Get.offAllNamed(Routes.HELPER_HOME);
      } else {
        Get.offNamed(Routes.LANDING_ONBOARDING);
      }
    });
  }
}
