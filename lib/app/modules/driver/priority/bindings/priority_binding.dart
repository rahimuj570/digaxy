import 'package:get/get.dart';
import '../controllers/priority_controller.dart';

class PriorityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PriorityController>(() => PriorityController());
  }
}
