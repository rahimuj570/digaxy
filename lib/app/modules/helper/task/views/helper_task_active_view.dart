import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/helper_task_active_controller.dart';

class HelperTaskActiveView extends GetView<HelperTaskActiveController> {
  const HelperTaskActiveView({super.key});

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
              Text(
                controller.subtitle.value,
                style: TextStyle(color: AppColors.textSecondary),
              ),
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
                    _line('Total Helper Pay', controller.totalHelperPay.value),
                  ],
                ),
              ),

              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Live movement On Map',
                  onPressed: () => Get.toNamed(
                    '/helper/task/live',
                    arguments: {
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
                      child: Text(
                        '${controller.customerName.value} / ${controller.customerTax.value}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.snackbar(
                        'Call',
                        'Calling customer (placeholder)',
                        backgroundColor: AppColors.accent,
                        colorText: Colors.white,
                      ),
                      icon: Icon(Icons.call, color: AppColors.textHeadline),
                    ),
                    IconButton(
                      onPressed: () => Get.snackbar(
                        'Chat',
                        'Open chat (placeholder)',
                        backgroundColor: AppColors.accent,
                        colorText: Colors.white,
                      ),
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
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
