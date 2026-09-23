import 'package:get/get.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../models/parcel_data.dart';

class MoverCreateParcelController extends GetxController {
  MoverCreateParcelController({required ApiService api}) : _api = api;

  final ApiService _api;

  var loading = false.obs;

  Future<Map<String, dynamic>> createParcel({
    required ParcelData parcelData,
  }) async {
    try {
      loading.value = true;
      final response = await _api.createParcel(parcelData: parcelData.toJson());
      return response;
    } finally {
      loading.value = false;
    }
  }
}
