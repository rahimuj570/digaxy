import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

import '../controllers/helper_task_live_controller.dart';

class HelperTaskLiveView extends GetView<HelperTaskLiveController> {
  const HelperTaskLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Obx(
          () => Text(
            controller.title.value,
            style: TextStyle(color: AppColors.textHeadline),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map/illustration placeholder
              Container(
                width: double.infinity,
                height: 180.h,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.map_outlined,
                    color: AppColors.textSecondary,
                    size: 48.w,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Icon(Icons.circle, color: AppColors.accent, size: 10.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${controller.from.value}  ->  ${controller.to.value}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _dotLine('Distance: ', controller.distance.value),
              _dotLine('ETA: ', controller.eta.value),
              SizedBox(height: 12.h),

              Text(
                'Your Customer',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.textSecondary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${controller.customerName.value} / ${controller.customerTax.value}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.snackbar(
                      'Call',
                      'Calling customer (placeholder)',
                      backgroundColor: AppColors.accent,
                      colorText: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.call, color: AppColors.textHeadline),
                        SizedBox(width: 6.w),
                        Text(
                          'Call Customer',
                          style: TextStyle(color: AppColors.textHeadline),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => Get.snackbar(
                      'Chat',
                      'Open chat (placeholder)',
                      backgroundColor: AppColors.accent,
                      colorText: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.textHeadline,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Chat',
                          style: TextStyle(color: AppColors.textHeadline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),
              Text(
                'Pickup Details',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              _detailCard(controller.pickupAddress.value, scheduled: '4:10PM'),
              SizedBox(height: 12.h),
              Text(
                'Drop-off Details',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              _detailCard(
                controller.dropoffAddress.value,
                scheduled: '4:10PM',
                confirmLabel: 'Confirm Drop-off',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: PrimaryButton(
            label: 'Delivery Done',
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  title: Text(
                    'Complete Delivery',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  content: Text(
                    'Mark this delivery as completed?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      onPressed: () {
                        Get.back();
                        // navigate back to helper home (clear stack)
                        Get.offAllNamed(Routes.HELPER_HOME);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dotLine(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(Icons.brightness_1, size: 6.w, color: AppColors.accent),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(width: 6.w),
          Text(value, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _detailCard(
    String address, {
    String scheduled = '',
    String confirmLabel = 'Confirm Pickup',
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address, style: TextStyle(color: AppColors.textPrimary)),
          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                          size: 16.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            controller.customerName.value,
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          color: AppColors.textSecondary,
                          size: 14.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            controller.customerTax.value,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Scheduled: $scheduled',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Actual: 4:15PM',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => Get.snackbar(
                'Photo',
                'Open camera (placeholder)',
                backgroundColor: AppColors.accent,
                colorText: Colors.white,
              ),
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                'Pickup Photo',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.accent),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),
          PrimaryButton(
            label: confirmLabel,
            onPressed: () => Get.snackbar(
              'Confirm',
              '$confirmLabel action (placeholder)',
              backgroundColor: AppColors.accent,
              colorText: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
