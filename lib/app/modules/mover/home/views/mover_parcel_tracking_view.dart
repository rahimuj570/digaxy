import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MoverParcelTrackingView extends StatelessWidget {
  const MoverParcelTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = (Get.arguments is Map) ? (Get.arguments as Map) : {};

    final title = args['title'] ?? 'Parcel Tracking';
    final from = args['from'] ?? 'Pickup Location';
    final to = args['to'] ?? 'Delivery Location';
    final status = args['status'] ?? 'In Transit';
    final parcelId = args['parcelId'];
    final driverPhone = args['driverPhone'] ?? '+1 (555) 123-4567';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Track Parcel',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parcel Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textHeadline,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (parcelId != null) ...[
                      Text(
                        'Parcel ID: $parcelId',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Journey Timeline
              Text(
                'Journey',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),

              // Timeline Steps
              _buildTimelineStep(
                number: 1,
                title: 'Pickup Location',
                address: from,
                status: 'Completed',
                isCompleted: status == 'On_the_way' || status == 'Delivered',
                isActive: false,
              ),
              SizedBox(height: 8.h),

              _buildTimelineStep(
                number: 2,
                title: 'In Transit',
                address: 'On the way to destination',
                status: 'In Progress',
                isCompleted: status == 'Delivered',
                isActive: status == 'On_the_way' || status == 'Delivered',
              ),
              SizedBox(height: 8.h),

              _buildTimelineStep(
                number: 3,
                title: 'Delivery Location',
                address: to,
                status: 'Pending',
                isCompleted: status == 'Delivered',
                isActive: status == 'Delivered',
              ),
              SizedBox(height: 32.h),

              // Driver Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Information',
                      style: TextStyle(
                        color: AppColors.textHeadline,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: AppColors.accent.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 32.sp,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Driver Name',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                driverPhone,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.star,
                              color: const Color(0xFFFFC107),
                              size: 18.sp,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '4.8',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final cleanPhone = driverPhone.replaceAll(
                                  RegExp(r'[^\d+\-]'),
                                  '',
                                );
                                final uri = Uri(
                                  scheme: 'tel',
                                  path: cleanPhone,
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  _showPhoneErrorDialog(context, cleanPhone);
                                }
                              } catch (e) {
                                _showPhoneErrorDialog(context, driverPhone);
                              }
                            },
                            icon: Icon(Icons.call, size: 18.sp),
                            label: const Text('Call'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              side: BorderSide(
                                color: AppColors.accent.withOpacity(0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final cleanPhone = driverPhone.replaceAll(
                                  RegExp(r'[^\d+\-]'),
                                  '',
                                );
                                final uri = Uri(
                                  scheme: 'sms',
                                  path: cleanPhone,
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  _showSmsErrorDialog(context, cleanPhone);
                                }
                              } catch (e) {
                                _showSmsErrorDialog(context, driverPhone);
                              }
                            },
                            icon: Icon(
                              Icons.message,
                              size: 18.sp,
                              color: AppColors.accent,
                            ),
                            label: Text(
                              'Chat',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Estimated Delivery
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Delivery',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Today, 6:30 PM',
                      style: TextStyle(
                        color: AppColors.textHeadline,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required int number,
    required String title,
    required String address,
    required String status,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.accent
                    : isActive
                    ? AppColors.accent
                    : Colors.white10,
                border: Border.all(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.black, size: 20.sp)
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: isActive ? Colors.black : Colors.white38,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (number < 3)
              Container(
                width: 2.w,
                height: 24.h,
                color: isCompleted ? AppColors.accent : Colors.white10,
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                address,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : isActive
                      ? AppColors.accent.withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green
                        : isActive
                        ? AppColors.accent
                        : Colors.white38,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPhoneErrorDialog(BuildContext context, String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('Call Driver'),
        content: Text(
          'Phone number: $phoneNumber\n\nNo phone app found. You can copy this number and call manually.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showSmsErrorDialog(BuildContext context, String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('Message Driver'),
        content: Text(
          'Phone number: $phoneNumber\n\nNo messaging app found. You can copy this number and message manually.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
