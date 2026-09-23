import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 1600),
  }) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: backgroundColor ?? AppColors.accent,
        snackPosition: SnackPosition.TOP,
        duration: duration,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      ),
    );
  }

  static void success(String title, String message) {
    show(title, message, backgroundColor: AppColors.accent);
  }

  static void error(String title, String message) {
    show(title, message, backgroundColor: Colors.redAccent);
  }
}
