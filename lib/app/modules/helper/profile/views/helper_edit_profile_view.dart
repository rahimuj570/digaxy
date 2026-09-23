import 'dart:io';

import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';

import '../controllers/helper_edit_profile_controller.dart';

class HelperEditProfileView extends GetView<HelperEditProfileController> {
  const HelperEditProfileView({super.key});

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

              SizedBox(height: 12.h),
              _label('Full Name'),
              SizedBox(height: 8.h),
              _field(controller.usernameCtrl, hint: 'Enter your full name'),

              SizedBox(height: 12.h),
              _label('Phone'),
              SizedBox(height: 8.h),
              _field(controller.phoneCtrl, hint: 'Phone number'),

              SizedBox(height: 12.h),
              _label('Email'),
              SizedBox(height: 8.h),
              _field(controller.emailCtrl, hint: 'Enter your email'),

              SizedBox(height: 12.h),
              _label('Gender'),
              SizedBox(height: 8.h),
              Obx(
                () => _dropdown(
                  value:
                      [
                        'Male',
                        'Female',
                        'Other',
                      ].contains(controller.userGender.value)
                      ? controller.userGender.value
                      : 'Male',
                  items: ['Male', 'Female', 'Other'],
                  onChanged: (v) {
                    if (v != null) controller.userGender.value = v;
                  },
                ),
              ),

              SizedBox(height: 12.h),
              _label('Date of Birth'),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () async {
                  final initial = DateTime.tryParse(
                    controller.dateOfBirth.value,
                  );
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initial ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    final dateStr = picked.toString().split(' ')[0];
                    controller.dateOfBirth.value = dateStr;
                  }
                },
                child: AbsorbPointer(
                  child: Obx(
                    () => _field(
                      TextEditingController(text: controller.dateOfBirth.value),
                      hint: 'YYYY-MM-DD',
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Center(
                child: Obx(
                  () => PrimaryButton(
                    label: 'Update',
                    loading: controller.isLoading.value,
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
    Widget? suffixIcon,
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
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: SizedBox.shrink(),
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
