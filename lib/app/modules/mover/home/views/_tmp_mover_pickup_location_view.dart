// temporary file containing the corrected implementation for mover pickup view
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class TmpMoverPickupLocationView extends StatefulWidget {
  const TmpMoverPickupLocationView({super.key});

  @override
  State<TmpMoverPickupLocationView> createState() =>
      _TmpMoverPickupLocationViewState();
}

class _TmpMoverPickupLocationViewState
    extends State<TmpMoverPickupLocationView> {
  final _streetCtrl = TextEditingController();
  final _aptCtrl = TextEditingController();

  @override
  void dispose() {
    _streetCtrl.dispose();
    _aptCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final payload = Get.arguments ?? {};
    if (payload is Map) {
      payload['pickupStreet'] = _streetCtrl.text.trim();
      payload['pickupApt'] = _aptCtrl.text.trim();
    }
    Get.toNamed(Routes.MOVER_DROPOFF_LOCATION, arguments: payload);
  }

  @override
  Widget build(BuildContext context) {
    final service = (Get.arguments is Map)
        ? (Get.arguments as Map)['service']
        : 'Pickup Truck';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Pickup Location',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Image.asset(
                      'assets/images/1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service ?? 'Pickup Truck',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Best for small deliveries',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              'This is where your delivery begins. Please provide your pickup address to help our driver locate you quickly and start the trip smoothly.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'Enter Pickup Address',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _streetCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Street / House / Street Name',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _aptCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Apartment / City / Zip code',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              'Helpful Tips',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(top: 6.h, right: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC08A10),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Ensure your location pin is placed correctly.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(top: 6.h, right: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC08A10),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Add nearby landmarks (e.g., "next to ABC Market") for easier identification.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(top: 6.h, right: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC08A10),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Be available at the pickup spot before the vehicle arrives.',
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

            SizedBox(height: 30.h),
            PrimaryButton(
              label: 'Confirm Pickup Location',
              onPressed: _onConfirm,
            ),
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}
