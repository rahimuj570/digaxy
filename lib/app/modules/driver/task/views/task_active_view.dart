import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

import '../controllers/task_active_controller.dart';

class TaskActiveView extends GetView<TaskActiveController> {
  const TaskActiveView({super.key});

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
            style: TextStyle(color: AppColors.accent),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isLoading.value)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: LinearProgressIndicator(
                    minHeight: 2.h,
                    color: AppColors.accent,
                    backgroundColor: Colors.white10,
                  ),
                ),
              Text(
                controller.subtitle.value,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (controller.loadError.value.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  controller.loadError.value,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
              SizedBox(height: 12.h),

              Text(
                'Booking Details',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(
                      'Delivery ID',
                      controller.parcelId.value.isEmpty
                          ? 'N/A'
                          : controller.parcelId.value,
                    ),
                    SizedBox(height: 8.h),
                    _line(
                      'Delivery Status',
                      controller.deliveryStatus.value.isEmpty
                          ? 'N/A'
                          : controller.deliveryStatus.value,
                    ),
                    SizedBox(height: 8.h),
                    _line('Pickup Address', controller.pickupAddress.value),
                    SizedBox(height: 8.h),
                    _line('Drop-Off Address', controller.dropoffAddress.value),
                    SizedBox(height: 8.h),
                    _line('Scheduled Time', controller.scheduledTime.value),
                    SizedBox(height: 8.h),
                    _line('Item Type', controller.itemType.value),
                    SizedBox(height: 8.h),
                    _line('Item', controller.item.value),
                    SizedBox(height: 8.h),
                    _line('Date', controller.date.value),
                    SizedBox(height: 8.h),
                    _line('Distance Pay', controller.distancePay.value),
                    SizedBox(height: 8.h),
                    _line('Total Driver Pay', controller.totalDriverPay.value),
                    SizedBox(height: 8.h),
                    _line(
                      'Vehicle Type',
                      controller.vehicleType.value.isEmpty
                          ? 'N/A'
                          : controller.vehicleType.value,
                    ),
                    SizedBox(height: 8.h),
                    _line(
                      'Pickup Contact',
                      controller.pickupContactName.value.isEmpty
                          ? 'N/A'
                          : '${controller.pickupContactName.value} ${controller.pickupContactPhone.value.isEmpty ? '' : '/ ${controller.pickupContactPhone.value}'}',
                    ),
                    SizedBox(height: 8.h),
                    _line(
                      'Drop Contact',
                      controller.dropContactName.value.isEmpty
                          ? 'N/A'
                          : '${controller.dropContactName.value} ${controller.dropContactPhone.value.isEmpty ? '' : '/ ${controller.dropContactPhone.value}'}',
                    ),
                    if (controller.estimatedDistance.value.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _line(
                        'Estimated Distance',
                        '${controller.estimatedDistance.value} km',
                      ),
                    ],
                    if (controller.estimatedTime.value.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _line(
                        'Estimated Time',
                        '${controller.estimatedTime.value} min',
                      ),
                    ],
                    if (controller.notes.value.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _line('Notes', controller.notes.value),
                    ],
                    if (controller.specialInstructions.value.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _line(
                        'Special Instructions',
                        controller.specialInstructions.value,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Live movement On Map',
                  onPressed: () => Get.toNamed(
                    Routes.DRIVER_TASK_LIVE,
                    arguments: {
                      'parcelId': (Get.arguments is Map)
                          ? ((Get.arguments as Map)['parcelId'] ??
                                (Get.arguments as Map)['jobId'])
                          : null,
                      'jobId': (Get.arguments is Map)
                          ? (Get.arguments as Map)['jobId']
                          : null,
                      'pickup': controller.pickupAddress.value,
                      'dropoff': controller.dropoffAddress.value,
                      'customerName': controller.customerName.value,
                    },
                  ),
                ),
              ),

              SizedBox(height: 16.h),
              Text(
                'Your Customer',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: Colors.transparent),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.textSecondary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.customerName.value} / ${controller.customerTax.value}',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            controller.customerPhone.value.isEmpty
                                ? 'Phone: N/A'
                                : 'Phone: ${controller.customerPhone.value}',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.callCustomer(),
                      icon: Icon(Icons.call, color: AppColors.textHeadline),
                    ),
                    IconButton(
                      onPressed: () => controller.messageCustomer(),
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),
              Text(
                'Payment',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line('Method', controller.paymentMethod.value),
                    SizedBox(height: 6.h),
                    _line('Transaction ID', controller.transactionId.value),
                    SizedBox(height: 6.h),
                    _line('Status', controller.paymentStatus.value),
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

  Widget _line(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(label, style: TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
