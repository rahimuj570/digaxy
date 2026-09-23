import 'dart:io';

import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';

import '../controllers/mover_edit_profile_controller.dart';

class MoverEditProfileView extends GetView<MoverEditProfileController> {
  const MoverEditProfileView({super.key});

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
                                : ((controller
                                              .profileController
                                              ?.profilePictureUrl
                                              .value
                                              .trim()
                                              .isNotEmpty ??
                                          false)
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            controller
                                                .profileController!
                                                .profilePictureUrl
                                                .value
                                                .trim(),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
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
                                          .trim()
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
              SizedBox(height: 12.h),
              Center(
                child: Obx(() {
                  final email = controller.profileController?.email.value ?? '';
                  return Text(
                    email.isEmpty ? 'Enter your email' : email,
                    style: TextStyle(color: AppColors.textPrimary),
                  );
                }),
              ),
              SizedBox(height: 18.h),

              _label('Full Name'),
              SizedBox(height: 8.h),
              _field(controller.usernameCtrl, hint: 'Enter your full name'),

              SizedBox(height: 12.h),
              _label('Phone'),
              SizedBox(height: 8.h),
              _field(controller.phoneCtrl, hint: 'Phone number'),

              SizedBox(height: 12.h),
              _label('Gender'),
              SizedBox(height: 8.h),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          [
                            'Male',
                            'Female',
                            'Other',
                          ].contains(controller.userGender.value)
                          ? controller.userGender.value
                          : 'Male',
                      isExpanded: true,
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: AppColors.primary),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          controller.userGender.value = newValue;
                        }
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),
              SizedBox(height: 12.h),
              _label('Date of Birth (YYYY-MM-DD)'),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: now,
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                  if (picked != null) {
                    final formatted =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    controller.dateOfBirthCtrl.text = formatted;
                  }
                },
                child: AbsorbPointer(
                  child: _field(
                    controller.dateOfBirthCtrl,
                    hint: 'YYYY-MM-DD',
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
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
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
