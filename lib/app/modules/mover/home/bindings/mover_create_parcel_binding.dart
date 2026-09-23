import 'package:get/get.dart';
import '../../../../../services/api/api_service.dart';
import '../controllers/mover_create_parcel_controller.dart';

class MoverCreateParcelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoverCreateParcelController>(
      () => MoverCreateParcelController(api: Get.find<ApiService>()),
    );
  }
}
