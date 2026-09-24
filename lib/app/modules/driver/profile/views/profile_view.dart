import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: Colors.grey[900],
          onRefresh: () => controller.fetchProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 1),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6.r),
                      splashColor: AppColors.accent.withValues(alpha: 0.12),
                      onTap: () async {
                        // Navigate to edit profile. Use a microtask to ensure
                        // the tap event finishes before navigation (more reliable
                        // on first tap across platforms).
                        await Future.microtask(
                          () => Get.toNamed(Routes.DRIVER_PROFILE_EDIT),
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
              // avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A2A2A),
                    ),
                    child: Obx(() {
                      final pic = controller.profilePictureUrl.value.trim();
                      if (pic.isNotEmpty && pic != 'null') {
                        return ClipOval(
                          child: Image.network(
                            pic,
                            width: 100.w,
                            height: 100.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 50.w,
                              color: AppColors.accent,
                            ),
                          ),
                        );
                      }
                      return Icon(
                        Icons.person,
                        size: 50.w,
                        color: AppColors.accent,
                      );
                    }),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16.w,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
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
              Obx(
                () => controller.isLoading.value
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: LinearProgressIndicator(
                          minHeight: 2.h,
                          color: AppColors.accent,
                          backgroundColor: Colors.white10,
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              // info rows
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     'Your Name',
              //     style: TextStyle(color: AppColors.textSecondary),
              //   ),
              // ),
              // priority pill with details
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.DRIVER_PRIORITY);
                },
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
              Obx(() => _infoRow(Icons.email, controller.email.value)),
              SizedBox(height: 12.h),
              Obx(() => _infoRow(Icons.phone, controller.phone.value)),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(Icons.badge, 'Role: ${controller.role.value}'),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.calendar_today,
                  'Joining, ${controller.joining.value}',
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.verified,
                  'Application Status: ${controller.applicationStatus.value}',
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.badge_outlined,
                  'License: ${controller.licenseNumber.value}',
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => _infoRow(
                  Icons.directions_car,
                  'Vehicle: ${controller.vehicleType.value} (${controller.vehicleNumber.value})',
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                final lat = controller.currentLatitude.value.trim();
                final lng = controller.currentLongitude.value.trim();
                final address = controller.humanReadableAddress.value.trim();
                final hasCoords = lat.isNotEmpty &&
                    lng.isNotEmpty &&
                    lat != 'null' &&
                    lng != 'null';

                final coordsText = hasCoords ? '$lat, $lng' : 'Not Available';
                final mainText = address.isNotEmpty
                    ? address
                    : (hasCoords
                        ? 'Current Location: $coordsText'
                        : 'Location Not Set');
                final subText = address.isNotEmpty ? '($coordsText)' : null;

                return _infoRow(
                  Icons.location_on,
                  mainText,
                  subtitle: subText,
                );
              }),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _infoRow(IconData icon, String text, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
