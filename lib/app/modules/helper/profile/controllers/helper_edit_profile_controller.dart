import 'package:digaxy/services/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:image_picker/image_picker.dart';

import 'helper_profile_controller.dart';

class HelperEditProfileController extends GetxController {
  final ApiService _apiService = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();

  // Form controllers
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // New fields
  final userGender = ''.obs;
  final dateOfBirth = ''.obs;
  final selectedProfileImagePath = ''.obs;

  HelperProfileController? profileController;
  final ImagePicker _imagePicker = ImagePicker();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<HelperProfileController>()) {
      profileController = Get.find<HelperProfileController>();
      usernameCtrl.text = profileController!.name.value;
      phoneCtrl.text = profileController!.phone.value;
      emailCtrl.text = profileController!.email.value;

      userGender.value = profileController!.userGender.value;
      dateOfBirth.value = profileController!.dateOfBirth.value;
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked != null && picked.path.isNotEmpty) {
        selectedProfileImagePath.value = picked.path;
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    if (usernameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Full Name is required',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      String? normalizedGender;
      final rawGender = userGender.value.trim();
      if (rawGender.isNotEmpty &&
          rawGender.toLowerCase() != 'not set' &&
          rawGender.toLowerCase() != 'notset') {
        normalizedGender = rawGender;
      }

      String? normalizedDob;
      final rawDob = dateOfBirth.value.trim();
      if (rawDob.isNotEmpty &&
          rawDob.toLowerCase() != 'not set' &&
          rawDob.toLowerCase() != 'notset') {
        normalizedDob = rawDob;
      }

      await _apiService.updateHelperProfileMultipart(
        fullName: usernameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        userGender: normalizedGender,
        dateOfBirth: normalizedDob,
        profilePicturePath: selectedProfileImagePath.value.isEmpty
            ? null
            : selectedProfileImagePath.value,
      );

      if (profileController != null) {
        await profileController!.fetchProfile();
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppColors.accent,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      String message = e.toString();
      if (e is ApiException) {
        message = e.message;
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
