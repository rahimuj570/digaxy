import 'package:digaxy/services/api/api_service.dart';
import 'package:get/get.dart';

class HelperProfileController extends GetxController {
  final ApiService _apiService = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();

  final name = ''.obs;
  final email = ''.obs;
  final id = ''.obs;
  final phone = ''.obs;
  final joining = ''.obs;
  final userGender = ''.obs;
  final dateOfBirth = ''.obs;
  final profilePictureUrl = ''.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getHelperProfile();

      // Parse response
      name.value = response['full_name'] ?? response['username'] ?? '';
      email.value = response['email'] ?? '';
      phone.value = response['phone_number'] ?? '';
      id.value = 'H-${response['id'] ?? 'N/A'}';
      profilePictureUrl.value = (response['profile_picture'] ?? '').toString();

      final rawGender = (response['usergender'] ?? '').toString().trim();
      userGender.value = rawGender;

      final rawDob = (response['date_of_birth'] ?? '').toString().trim();
      dateOfBirth.value = rawDob;

      if (response['date_joined'] != null) {
        try {
          joining.value = DateTime.parse(
            response['date_joined'],
          ).toString().split(' ')[0];
        } catch (_) {
          joining.value = response['date_joined'].toString();
        }
      } else {
        joining.value = 'N/A';
      }
    } catch (e) {
      // Quietly fail or log, user will see placeholders
      // Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
