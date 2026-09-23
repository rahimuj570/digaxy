import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../services/api/api_service.dart';

class MoverSettingsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _box = GetStorage();

  final name = 'Mover Joe'.obs;
  final email = 'mover@example.com'.obs;

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
    if (!Get.isRegistered<MoverSettingsController>()) {
      Get.put<MoverSettingsController>(MoverSettingsController());
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
