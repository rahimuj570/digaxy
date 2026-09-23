import 'package:digaxy/services/api/api_service.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();

  final name = ''.obs;
  final email = ''.obs;
  final id = ''.obs;
  final phone = ''.obs;
  final joining = ''.obs;

  final role = ''.obs;
  final applicationStatus = ''.obs;
  final profilePictureUrl = ''.obs;
  final licenseNumber = ''.obs;
  final vehicleType = ''.obs;
  final vehicleNumber = ''.obs;
  final currentLatitude = ''.obs;
  final currentLongitude = ''.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final data = await _apiService.getDriverProfile();

      name.value = (data['full_name'] ?? data['username'] ?? 'Driver')
          .toString();
      email.value = (data['email'] ?? '').toString();
      id.value = 'D-${(data['id'] ?? 'N/A').toString()}';
      phone.value = (data['phone_number'] ?? '').toString();

      role.value = (data['role'] ?? 'Driver').toString();
      applicationStatus.value = (data['driver_application_status'] ?? '')
          .toString();
      profilePictureUrl.value = (data['profile_picture'] ?? '').toString();
      licenseNumber.value = (data['driver_license_number'] ?? '').toString();
      vehicleType.value = (data['vehicle_type'] ?? '').toString();
      vehicleNumber.value = (data['driver_vehicle_number'] ?? '').toString();
      currentLatitude.value = (data['current_location_latitude'] ?? '')
          .toString();
      currentLongitude.value = (data['current_location_longitude'] ?? '')
          .toString();

      final rawJoined = (data['date_joined'] ?? '').toString();
      if (rawJoined.isNotEmpty) {
        joining.value = rawJoined.split('T').first;
      } else {
        joining.value = 'N/A';
      }
    } catch (_) {
      // Keep empty placeholders on failure.
    } finally {
      isLoading.value = false;
    }
  }
}
