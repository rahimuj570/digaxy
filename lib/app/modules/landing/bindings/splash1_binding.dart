import 'package:get/get.dart';
import '../controllers/splash1_controller.dart';

class Splash1Binding extends Bindings {
  @override
  void dependencies() {
    // Ensure controller is created when route opens so onInit() runs
    Get.put<Splash1Controller>(Splash1Controller());
  }
}
