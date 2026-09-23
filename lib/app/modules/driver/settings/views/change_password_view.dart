import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({super.key});

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
          'Change Password',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              _field(controller.oldPassword, hint: 'Enter your old password'),
              SizedBox(height: 12.h),
              _field(controller.newPassword, hint: 'Enter your new password'),
              SizedBox(height: 12.h),
              _field(
                controller.confirmPassword,
                hint: 'Confirm your new password',
              ),
              SizedBox(height: 20.h),
              PrimaryButton(
                label: 'Update',
                onPressed: () => controller.changePassword(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, {String? hint}) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: AppColors.primary),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
