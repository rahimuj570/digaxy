import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/payout_controller.dart';

class HelperPayoutView extends GetView<HelperPayoutController> {
  const HelperPayoutView({super.key});

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
          'Payout',
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
                'Cash Out Your Earnings',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Your Available Balance:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Text(
                  '\$${controller.available.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Choose How You Want to Receive Your Money:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => RadioListTile<String>(
                  value: 'bank',
                  activeColor: AppColors.accent,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  groupValue: controller.selectedMethod.value,
                  onChanged: (v) => controller.selectMethod(v ?? 'bank'),
                  title: Text(
                    'Bank Transfer',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              Obx(
                () => RadioListTile<String>(
                  value: 'bkash',
                  activeColor: AppColors.accent,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  groupValue: controller.selectedMethod.value,
                  onChanged: (v) => controller.selectMethod(v ?? 'bkash'),
                  title: Text(
                    'Bkash',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Fee',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '\$${controller.instantFee.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(Instant)',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          '\$${controller.expressFee.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(Express)',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () => controller.continuePayout(),
                  backgroundColor: AppColors.accent,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
