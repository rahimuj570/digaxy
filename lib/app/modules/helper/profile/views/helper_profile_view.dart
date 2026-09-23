import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/helper_profile_controller.dart';

class HelperProfileView extends GetView<HelperProfileController> {
  const HelperProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Defensive: ensure controller exists
    if (!Get.isRegistered<HelperProfileController>()) {
      Get.put(HelperProfileController());
    }

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 1),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6.r),
                      splashColor: AppColors.accent.withOpacity(0.12),
                      onTap: () async {
                        await Future.microtask(
                          () => Get.toNamed(Routes.HELPER_PROFILE_EDIT),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.edit,
                              color: AppColors.accent,
                              size: 18.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Avatar (display only; editing happens in edit profile screen)
              Obx(
                () => Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: controller.profilePictureUrl.value.trim().isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              controller.profilePictureUrl.value.trim(),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.profilePictureUrl.value.trim().isEmpty
                      ? Icon(Icons.person, size: 42.w, color: Colors.black54)
                      : null,
                ),
              ),

              SizedBox(height: 12.h),
              Obx(
                () => Text(
                  controller.email.value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Obx(
                () => Text(
                  controller.id.value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Priority pill
              InkWell(
                onTap: () => Get.toNamed(Routes.HELPER_PRIORITY),

                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events, color: AppColors.accent),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Priority level',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              'Details',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
              Obx(() => _infoRow(Icons.person, controller.name.value)),
              SizedBox(height: 12.h),
              _infoRow(Icons.star, 'Customer reviews'),
              SizedBox(height: 12.h),
              SizedBox(height: 12.h),
              Obx(() => _infoRow(Icons.email, controller.email.value)),
              SizedBox(height: 12.h),
              Obx(() => _infoRow(Icons.phone, controller.phone.value)),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.person_outline,
                  'Gender: ${controller.userGender.value}',
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.cake,
                  'DOB: ${controller.dateOfBirth.value}',
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.calendar_today,
                  'Joining: ${controller.joining.value}',
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(text, style: TextStyle(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
