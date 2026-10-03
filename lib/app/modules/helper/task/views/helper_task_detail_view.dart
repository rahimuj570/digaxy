import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/helper_task_controller.dart';

class HelperTaskDetailView extends GetView<HelperTaskDetailController> {
  const HelperTaskDetailView({super.key});

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
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (controller.loadError.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  controller.loadError.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.assignedAt.value.isNotEmpty) ...[
                  Text(
                    controller.assignedAt.value,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
                if (controller.deliveryId.value.isNotEmpty) ...[
                  Text(
                    'Delivery ID: ${controller.deliveryId.value}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Card with pickup/dropoff
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Location',
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.accent,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.pickupAddress.value.isNotEmpty
                                  ? controller.pickupAddress.value
                                  : 'N/A',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Drop-off Location',
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.accent,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.dropoffAddress.value.isNotEmpty
                                  ? controller.dropoffAddress.value
                                  : 'N/A',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      if (controller.pickupContactName.value.isNotEmpty ||
                          controller.pickupContactPhone.value.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: AppColors.textSecondary,
                              size: 18.w,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                [
                                  if (controller.pickupContactName.value.isNotEmpty)
                                    controller.pickupContactName.value,
                                  if (controller.pickupContactPhone.value.isNotEmpty)
                                    controller.pickupContactPhone.value,
                                ].join(' - '),
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (controller.pickupDate.value.isNotEmpty ||
                          controller.pickupTime.value.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: AppColors.textSecondary,
                              size: 16.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              [
                                if (controller.pickupDate.value.isNotEmpty)
                                  controller.pickupDate.value,
                                if (controller.pickupTime.value.isNotEmpty)
                                  controller.pickupTime.value,
                              ].join(' '),
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 18.h),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.items.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          controller.items[i],
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),

                if (controller.showActionButton.value) ...[
                  SizedBox(height: 6.h),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: controller.isTrackMode.value
                          ? 'Track Movement'
                          : 'Confirm Task',
                      onPressed: controller.isConfirming.value
                          ? null
                          : () => controller.confirmTask(),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
