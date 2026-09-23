import 'package:get/get.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:flutter/material.dart';

class MoverProfileController extends GetxController {
  final ApiService _api = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();

  final name = ''.obs;
  final email = ''.obs;
  final id = ''.obs;
  final phone = ''.obs;
  final joining = ''.obs;
  final isLoading = true.obs;
  final profilePictureUrl = ''.obs;

  final userGender = 'Male'.obs;
  final dateOfBirth = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _api.getCustomerProfile();

      // The API returns the profile object directly or wrapped.
      // Assuming straightforward mapping based on JSON.
      final data = response;

      name.value = data['full_name']?.toString().isNotEmpty == true
          ? data['full_name']
          : (data['username'] ?? 'Mover');

      email.value = data['email'] ?? '';
      id.value = 'M-${data['id']}';
      phone.value = data['phone_number'] ?? 'Not set';
      profilePictureUrl.value = (data['profile_picture'] ?? '').toString();
      userGender.value = data['usergender'] ?? 'Not set';
      dateOfBirth.value = data['date_of_birth'] ?? 'Not set';

      // Simple date parsing or raw string
      if (data['date_joined'] != null) {
        joining.value = data['date_joined'].toString().split('T')[0];
      }

      // Populate other fields if available in future updates
    } catch (e) {
      debugPrint('Error fetching mover profile: $e');
      // existing values will act as fallback or remain empty
    } finally {
      isLoading.value = false;
    }
  }
}
