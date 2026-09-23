import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/task_controller.dart';

class TaskDetailView extends GetView<TaskDetailController> {
  const TaskDetailView({super.key});

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
        child: Obx(
          () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isLoading.value)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: LinearProgressIndicator(
                      minHeight: 2.h,
                      color: AppColors.accent,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                Text(
                  controller.assignedAt.value.isEmpty
                      ? 'Assigned at: N/A'
                      : controller.assignedAt.value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Delivery ID: ${controller.deliveryId.value.isEmpty ? 'N/A' : controller.deliveryId.value}',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                if (controller.loadError.value.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    controller.loadError.value,
                    style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
                  ),
                ],
                SizedBox(height: 16.h),

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
                        style: TextStyle(color: AppColors.textHeadline),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.textSecondary,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.pickupAddress.value.isEmpty
                                  ? 'N/A'
                                  : controller.pickupAddress.value,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Drop-off Location',
                        style: TextStyle(color: AppColors.textHeadline),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textSecondary,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.dropoffAddress.value.isEmpty
                                  ? 'N/A'
                                  : controller.dropoffAddress.value,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
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
                              'Pickup Contact: ${controller.pickupContactName.value.isEmpty ? 'N/A' : controller.pickupContactName.value}  ${controller.pickupContactPhone.value.isEmpty ? '' : controller.pickupContactPhone.value}',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_circle_outlined,
                            color: AppColors.textSecondary,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Drop Contact: ${controller.dropContactName.value.isEmpty ? 'N/A' : controller.dropContactName.value}  ${controller.dropContactPhone.value.isEmpty ? '' : controller.dropContactPhone.value}',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: AppColors.textSecondary,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Status: ${controller.parcelStatus.value.isEmpty ? 'N/A' : controller.parcelStatus.value}',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: AppColors.textSecondary,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Pickup: ${controller.pickupDate.value.isEmpty ? 'N/A' : controller.pickupDate.value} ${controller.pickupTime.value.isEmpty ? '' : controller.pickupTime.value}',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
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
                  child: controller.items.isEmpty
                      ? Text(
                          'No order summary available.',
                          style: TextStyle(color: AppColors.textSecondary),
                        )
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: controller.items.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                controller.items[i],
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
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
                          ? 'Track'
                          : 'Confirm Task',
                      loading: controller.isTrackMode.value
                          ? false
                          : controller.isConfirming.value,
                      onPressed: () => controller.confirmTask(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
