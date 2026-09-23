import 'dart:io';

import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Edit', style: TextStyle(color: AppColors.textHeadline)),
        iconTheme: IconThemeData(color: AppColors.textHeadline),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.edit, color: AppColors.textHeadline),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Obx(
                  () => InkWell(
                    onTap: controller.pickProfileImage,
                    borderRadius: BorderRadius.circular(60.r),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            image:
                                controller
                                    .selectedProfileImagePath
                                    .value
                                    .isNotEmpty
                                ? DecorationImage(
                                    image: FileImage(
                                      File(
                                        controller
                                            .selectedProfileImagePath
                                            .value,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : (controller
                                          .profileController
                                          ?.profilePictureUrl
                                          .value
                                          .isNotEmpty ??
                                      false)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      controller
                                          .profileController!
                                          .profilePictureUrl
                                          .value,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (controller
                                      .selectedProfileImagePath
                                      .value
                                      .isEmpty &&
                                  (controller
                                          .profileController
                                          ?.profilePictureUrl
                                          .value
                                          .isNotEmpty !=
                                      true))
                              ? Icon(
                                  Icons.person,
                                  size: 42.w,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16.w,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  'Tap image to change profile photo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.emailCtrl,
                  builder: (context, value, _) => Text(
                    value.text.isEmpty ? 'Enter your email' : value.text,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              _label('Username'),
              SizedBox(height: 8.h),
              _field(controller.usernameCtrl, hint: 'Enter your username'),

              SizedBox(height: 12.h),
              _label('Phone'),
              SizedBox(height: 8.h),
              _field(controller.phoneCtrl, hint: 'Phone number'),

              SizedBox(height: 12.h),
              _label('Email'),
              SizedBox(height: 8.h),
              _field(controller.emailCtrl, hint: 'Enter your email'),

              SizedBox(height: 12.h),
              _label('Vehicle Type'),
              SizedBox(height: 8.h),
              _field(controller.vehicleTypeCtrl, hint: 'Vehicle type'),

              SizedBox(height: 12.h),
              _label('Vehicle Number'),
              SizedBox(height: 8.h),
              _field(controller.vehicleNumberCtrl, hint: 'Vehicle number'),

              SizedBox(height: 20.h),
              Center(
                child: Obx(
                  () => PrimaryButton(
                    label: 'Update',
                    loading: controller.isUpdating.value,
                    onPressed: () => controller.updateProfile(),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) =>
      Text(t, style: TextStyle(color: AppColors.textSecondary));

  Widget _field(
    TextEditingController ctrl, {
    String? hint,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
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
