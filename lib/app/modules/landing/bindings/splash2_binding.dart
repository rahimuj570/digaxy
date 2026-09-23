import 'package:get/get.dart';
import '../controllers/splash2_controller.dart';

class Splash2Binding extends Bindings {
  @override
  void dependencies() {
    // Ensure controller is created when route opens so onInit() runs
    Get.put<Splash2Controller>(Splash2Controller());
  }
}
