import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/maps/google_places_service.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();
  final GooglePlacesService _placesService =
      Get.isRegistered<GooglePlacesService>()
          ? Get.find<GooglePlacesService>()
          : GooglePlacesService();

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
  final humanReadableAddress = ''.obs;

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

      final rawPic = (data['profile_picture'] ??
              data['profile_image'] ??
              data['image'] ??
              data['avatar'] ??
              '')
          .toString()
          .trim();
      if (rawPic.isNotEmpty && rawPic != 'null') {
        if (rawPic.startsWith('http://') || rawPic.startsWith('https://')) {
          profilePictureUrl.value = rawPic;
        } else if (rawPic.startsWith('/')) {
          profilePictureUrl.value = 'http://10.10.29.119:8300$rawPic';
        } else {
          profilePictureUrl.value = 'http://10.10.29.119:8300/$rawPic';
        }
      } else {
        profilePictureUrl.value = '';
      }

      licenseNumber.value = (data['driver_license_number'] ?? '').toString();
      vehicleType.value = (data['vehicle_type'] ?? '').toString();
      vehicleNumber.value = (data['driver_vehicle_number'] ?? '').toString();
      currentLatitude.value = (data['current_location_latitude'] ?? '')
          .toString();
      currentLongitude.value = (data['current_location_longitude'] ?? '')
          .toString();

      final lat = double.tryParse(currentLatitude.value);
      final lng = double.tryParse(currentLongitude.value);
      if (lat != null && lng != null && (lat != 0.0 || lng != 0.0)) {
        _resolveHumanReadableAddress(lat, lng);
      }

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

  Future<void> _resolveHumanReadableAddress(double lat, double lng) async {
    try {
      final address = await _placesService.reverseGeocode(lat, lng);
      if (address != null && address.trim().isNotEmpty) {
        humanReadableAddress.value = address.trim();
      }
    } catch (_) {}
  }
}
