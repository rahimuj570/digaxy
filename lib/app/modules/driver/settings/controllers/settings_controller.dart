import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../services/api/api_service.dart';

class SettingsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _box = GetStorage();

  final name = 'Joe Mitchell'.obs;
  final email = 'joemitchell016@gmail.com'.obs;

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final supportEmail = TextEditingController(text: 'support@digaxy.com');
  final supportMessage = TextEditingController();
  final isSendingSupport = false.obs;

  @override
  void onClose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    supportEmail.dispose();
    supportMessage.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
    final oldPwd = oldPassword.text.trim();
    final newPwd = newPassword.text.trim();
    final confirmPwd = confirmPassword.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      AppSnackbar.show('Error', 'Please fill all password fields');
      return;
    }

    // simple validation
    if (newPwd != confirmPwd) {
      AppSnackbar.show('Error', 'Passwords do not match');
      return;
    }

    final accessToken = _box.read('access_token') as String?;
    if (accessToken == null || accessToken.isEmpty) {
      AppSnackbar.show('Error', 'You are not logged in');
      Get.offAllNamed(Routes.AUTH_LOGIN);
      return;
    }

    try {
      await _api.changePassword(
        oldPassword: oldPwd,
        newPassword: newPwd,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Change password error: $e');
      AppSnackbar.error('Failed', e.toString());
      return;
    }

    // Show a visible snackbar and wait a short moment before navigating back
    AppSnackbar.success('Success', 'Password changed');

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.back();
    });
  }

  Future<void> sendSupport() async {
    final msg = supportMessage.text.trim();
    if (msg.isEmpty) {
      AppSnackbar.show('Error', 'Please describe your problem');
      return;
    }

    try {
      isSendingSupport.value = true;
      await _api.submitSupport(message: msg);
      supportMessage.clear();
      AppSnackbar.success('Success', 'Support request submitted successfully');

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back();
      });
    } catch (e) {
      debugPrint('Submit support error: $e');
      final err = e is ApiException ? e.message : 'Failed to submit support request';
      AppSnackbar.error('Failed', err);
    } finally {
      isSendingSupport.value = false;
    }
  }

  void logout() {
    if (!Get.isRegistered<SettingsController>()) {
      Get.put<SettingsController>(SettingsController());
    }

    AppSnackbar.show('Logged out', 'You have been logged out');

    Future.delayed(const Duration(milliseconds: 800), () {
      try {
        try {
          Get.deleteAll(force: true);
        } catch (_) {}
        Get.offAllNamed(Routes.LANDING_ROLE);
      } catch (_) {}
    });
  }
}
