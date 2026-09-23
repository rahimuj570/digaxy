import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/payout_controller.dart';

class HelperConfirmPayoutView extends GetView<HelperPayoutController> {
  const HelperConfirmPayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Confirm Payout',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You're about to withdraw:",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Text(
                  '\$${controller.amount.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'To: ${controller.selectedMethod.value == 'bank' ? 'Bank Transfer (01xxxxxx)' : 'Bkash (01xxxxxx)'}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 6.h),
              Text(
                'Arrival time: Instantly',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Confirm Payout',
                  onPressed: () => controller.confirmPayout(),
                  backgroundColor: AppColors.accent,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
