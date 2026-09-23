import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../services/api/api_service.dart';

class HelperSettingsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _box = GetStorage();

  final name = 'Helper Name'.obs;
  final email = 'helper@example.com'.obs;

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final supportEmail = TextEditingController(text: 'support@digaxy.com');
  final supportMessage = TextEditingController();

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

    AppSnackbar.success('Success', 'Password changed');

    Future.delayed(Duration(milliseconds: 1200), () async {
      try {
        Get.closeCurrentSnackbar();
        await Future.delayed(Duration(milliseconds: 100));
        final ctx = Get.context;
        if (ctx != null) {
          try {
            Navigator.of(ctx).pop();
            return;
          } catch (_) {}
        }
        try {
          Get.back();
        } catch (_) {}
      } catch (_) {}
    });
  }

  void sendSupport() {
    AppSnackbar.success('Sent', 'Support request sent');

    Future.delayed(Duration(milliseconds: 1200), () async {
      try {
        Get.closeCurrentSnackbar();
        await Future.delayed(Duration(milliseconds: 100));
        // Navigate to help ack page for helper
        try {
          Get.toNamed(Routes.HELPER_SETTINGS_HELP_ACK);
          return;
        } catch (_) {}
        // fallback to popping
        final ctx = Get.context;
        if (ctx != null) {
          try {
            Navigator.of(ctx).pop();
            return;
          } catch (_) {}
        }
        try {
          Get.back();
        } catch (_) {}
      } catch (_) {}
    });
  }

  void logout() {
    // Defensive: ensure this controller is registered (in case logout is triggered
    // from a flow where the binding wasn't applied).
    if (!Get.isRegistered<HelperSettingsController>()) {
      Get.put<HelperSettingsController>(HelperSettingsController());
    }

    // Show a brief confirmation then clear app-level controllers and navigate
    AppSnackbar.show('Logged out', 'You have been logged out');

    Future.delayed(const Duration(milliseconds: 800), () {
      try {
        // Remove registered dependencies to avoid stale controllers holding state.
        // Use force to ensure cleanup; avoid deleting essential singletons elsewhere.
        try {
          Get.deleteAll(force: true);
        } catch (_) {}

        // Navigate to role selection (landing role) and clear navigation stack.
        Get.offAllNamed(Routes.LANDING_ROLE);
      } catch (_) {}
    });
  }
}
