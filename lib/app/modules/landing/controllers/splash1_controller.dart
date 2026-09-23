import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class Splash1Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(seconds: 3), () {
      Get.offNamed(Routes.LANDING_SPLASH2);
    });
  }
}
