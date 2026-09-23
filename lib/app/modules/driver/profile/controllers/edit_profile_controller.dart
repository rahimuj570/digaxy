import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_controller.dart';

class EditProfileController extends GetxController {
  // Form controllers
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final vehicleTypeCtrl = TextEditingController();
  final vehicleNumberCtrl = TextEditingController();
  final isUpdating = false.obs;
  final selectedProfileImagePath = ''.obs;

  final ApiService _apiService = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  ProfileController? profileController;

  @override
  void onInit() {
    super.onInit();
    // Try to load existing profile values
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
      usernameCtrl.text = profileController!.name.value;
      phoneCtrl.text = profileController!.phone.value;
      emailCtrl.text = profileController!.email.value;
      vehicleTypeCtrl.text = profileController!.vehicleType.value;
      vehicleNumberCtrl.text = profileController!.vehicleNumber.value;
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    vehicleTypeCtrl.dispose();
    vehicleNumberCtrl.dispose();
    super.onClose();
  }

  Future<void> pickProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked != null && picked.path.isNotEmpty) {
        selectedProfileImagePath.value = picked.path;
      }
    } catch (_) {
      AppSnackbar.error('Error', 'Failed to pick image');
    }
  }

  Future<void> updateProfile() async {
    // Basic validation (expand as needed)
    if (usernameCtrl.text.trim().isEmpty) {
      AppSnackbar.show('Validation', 'Username is required');
      return;
    }

    // Push changes to main ProfileController if available
    if (profileController != null) {
      try {
        isUpdating.value = true;

        await _apiService.updateDriverProfileMultipart(
          username: usernameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phoneNumber: phoneCtrl.text.trim(),
          vehicleType: vehicleTypeCtrl.text.trim(),
          driverVehicleNumber: vehicleNumberCtrl.text.trim(),
          profilePicturePath: selectedProfileImagePath.value.isEmpty
              ? null
              : selectedProfileImagePath.value,
        );

        await profileController!.fetchProfile();
      } catch (e) {
        AppSnackbar.error('Error', 'Failed to update profile.');
        return;
      } finally {
        isUpdating.value = false;
      }
    }

    AppSnackbar.success('Success', 'Profile updated');

    // Wait for snackbar to be visible, then hide it and pop the edit page.
    await Future.delayed(Duration(milliseconds: 1200));
    try {
      Get.closeCurrentSnackbar();
    } catch (_) {}

    // Pop the edit page to go back to profile
    try {
      Get.back();
    } catch (_) {}
  }
}
