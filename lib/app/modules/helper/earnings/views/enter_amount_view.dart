import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/payout_controller.dart';

class HelperEnterAmountView extends GetView<HelperPayoutController> {
  const HelperEnterAmountView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController ctrl = TextEditingController(
      text: controller.available.value.toStringAsFixed(2),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Enter Amount',
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
                'Enter Amount to Withdraw:',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  hintText: '\$0.00',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Withdraw Full Amount',
                  onPressed: () {
                    controller.withdrawFull();
                  },
                  backgroundColor: AppColors.accent,
                ),
              ),
              SizedBox(height: 12.h),
              // Continue with entered value
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final text = ctrl.text.replaceAll('\u0000', '');
                    final parsed =
                        double.tryParse(
                          text.replaceAll('\u0000', '').replaceAll(',', ''),
                        ) ??
                        double.tryParse(text) ??
                        0.0;
                    controller.setAmount(parsed);
                    controller.gotoConfirm();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
