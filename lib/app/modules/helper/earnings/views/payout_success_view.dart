import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

import '../controllers/payout_controller.dart';

class HelperPayoutSuccessView extends StatefulWidget {
  const HelperPayoutSuccessView({super.key});

  @override
  State<HelperPayoutSuccessView> createState() =>
      _HelperPayoutSuccessViewState();
}

class _HelperPayoutSuccessViewState extends State<HelperPayoutSuccessView> {
  late final HelperPayoutController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HelperPayoutController>();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      try {
        Get.offAllNamed(Routes.HELPER_HOME);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // no back button on success page
        automaticallyImplyLeading: false,
        title: Text(
          'Payout Successful',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.accent, size: 64.w),
                SizedBox(height: 18.h),
                Text(
                  'Payout Successful',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Money sent to your bank account',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => Text(
                    '\$${controller.lastPayoutAmount.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // transaction history placeholder

                // TextButton(
                //   onPressed: () => Get.snackbar(
                //     'History',
                //     'View Transaction History (placeholder)',
                //     backgroundColor: AppColors.accent,
                //     colorText: AppColors.textPrimary,
                //   ),
                //   child: Text(
                //     'View Transaction History',
                //     style: TextStyle(color: AppColors.accent),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
