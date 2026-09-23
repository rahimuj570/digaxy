import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:image_picker/image_picker.dart';

import 'mover_profile_controller.dart';

class MoverEditProfileController extends GetxController {
  final ApiService _api = Get.isRegistered<ApiService>()
      ? Get.find<ApiService>()
      : ApiService();

  // Form controllers
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  // final emailCtrl = TextEditingController(); // Email typically read-only or handled separately
  // final passwordCtrl = TextEditingController(); // Password change is usually separate flow
  final userGender = 'Male'.obs;
  final dateOfBirthCtrl = TextEditingController();
  final selectedProfileImagePath = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();

  final payoutMethod = 'Bank Transfer'.obs;

  MoverProfileController? profileController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    profileController = Get.isRegistered<MoverProfileController>()
        ? Get.find<MoverProfileController>()
        : Get.put(MoverProfileController());

    usernameCtrl.text = profileController?.name.value ?? '';
    phoneCtrl.text = profileController?.phone.value ?? '';
    userGender.value = profileController?.userGender.value ?? 'Male';
    dateOfBirthCtrl.text = profileController?.dateOfBirth.value ?? '';
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    dateOfBirthCtrl.dispose();
    super.onClose();
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

  Future<void> updateProfile() async {
    final username = usernameCtrl.text.trim();
    final rawPhone = phoneCtrl.text.trim();
    final rawDob = dateOfBirthCtrl.text.trim();
    final rawGender = userGender.value.trim();

    if (username.isEmpty) {
      Get.snackbar('Validation', 'Username is required');
      return;
    }

    String? normalizedPhone;
    if (rawPhone.isNotEmpty &&
        rawPhone.toLowerCase() != 'not set' &&
        rawPhone.toLowerCase() != 'notset') {
      normalizedPhone = rawPhone;
    }

    String? normalizedDob;
    if (rawDob.isNotEmpty &&
        rawDob.toLowerCase() != 'not set' &&
        rawDob.toLowerCase() != 'notset') {
      normalizedDob = rawDob;
    }

    String? normalizedGender;
    if (rawGender.isNotEmpty &&
        rawGender.toLowerCase() != 'not set' &&
        rawGender.toLowerCase() != 'notset') {
      normalizedGender = rawGender;
    }

    isLoading.value = true;
    try {
      await _api.updateCustomerProfileMultipart(
        username: username,
        fullName: username,
        phoneNumber: normalizedPhone,
        dateOfBirth: normalizedDob,
        userGender: normalizedGender,
        profilePicturePath: selectedProfileImagePath.value.isEmpty
            ? null
            : selectedProfileImagePath.value,
      );

      // Refresh main profile
      if (profileController != null) {
        await profileController!.fetchProfile();
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppColors.accent,
        colorText: Colors.black,
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      final message = e is ApiException ? e.message : 'Update failed';
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
