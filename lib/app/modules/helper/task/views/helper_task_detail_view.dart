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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.assignedAt.value,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Delivery ID: ${controller.deliveryId.value}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16.h),

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
                            controller.pickupAddress.value,
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
                            controller.dropoffAddress.value,
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
                            '${controller.customerName.value}  ${controller.customerPhone.value} - Customer',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
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
                          '10:55 Am',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.schedule,
                          color: AppColors.textSecondary,
                          size: 16.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '11:55 Am',
                          style: TextStyle(color: AppColors.textSecondary),
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
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
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

              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Confirm Task',
                  onPressed: () => controller.confirmTask(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
