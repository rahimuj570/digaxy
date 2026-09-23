import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class HelpView extends GetView<SettingsController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Help & Support',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              _label('Email'),
              SizedBox(height: 8.h),
              _field(
                controller.supportEmail,
                hint: 'johndoe016@gmail.com',
                readOnly: true,
                onTap: () {
                  // copy fixed support email to clipboard and show snackbar
                  final email = controller.supportEmail.text.isNotEmpty
                      ? controller.supportEmail.text
                      : 'support@digaxy.com';
                  Clipboard.setData(ClipboardData(text: email));
                  Get.snackbar(
                    'Copied',
                    'Support email copied to clipboard',
                    backgroundColor: AppColors.accent,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                },
              ),
              SizedBox(height: 12.h),
              _label('Describe Your Problem'),
              SizedBox(height: 8.h),
              _multilineField(controller.supportMessage),
              SizedBox(height: 20.h),
              PrimaryButton(
                label: 'Send',
                onPressed: () => controller.sendSupport(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Text(t, style: TextStyle(color: AppColors.textSecondary)),
  );

  Widget _field(
    TextEditingController ctrl, {
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(
        color: readOnly ? AppColors.primary : AppColors.textPrimary,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.textHeadline),
        ),
      ),
    );
  }

  Widget _multilineField(TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      maxLines: 8,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Describe Your Problem',
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.all(12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: AppColors.textHeadline),
        ),
      ),
    );
  }
}
