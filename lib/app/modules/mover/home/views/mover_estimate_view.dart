import 'dart:math' as math;

import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class MoverEstimateView extends StatelessWidget {
  const MoverEstimateView({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final Map<String, dynamic> args = Map<String, dynamic>.from(rawArgs);
    final service = args['service'] ?? 'Pickup Truck';

    final pickupLat = _toDouble(args['pickupLat']);
    final pickupLng = _toDouble(args['pickupLng']);
    final dropLat = _toDouble(args['dropLat']);
    final dropLng = _toDouble(args['dropLng']);

    final distanceMiles =
        (pickupLat != null &&
            pickupLng != null &&
            dropLat != null &&
            dropLng != null)
        ? _distanceMiles(
            lat1: pickupLat,
            lon1: pickupLng,
            lat2: dropLat,
            lon2: dropLng,
          )
        : null;

    final distanceKm = distanceMiles != null ? distanceMiles * 1.609344 : null;
    if (distanceKm != null) {
      args['estimatedDistanceKm'] = distanceKm.toStringAsFixed(2);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Estimated Distance & Price',
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
                    height: 46.h,
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
                          service,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Best for small deliveries',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              "Here's a quick overview of your delivery details — including distance, estimated cost, and travel route.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),

            Text(
              'Estimated Distance:',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (distanceMiles != null)
              Text(
                '${distanceMiles.toStringAsFixed(2)} miles',
                style: TextStyle(
                  color: const Color(0xFFC08A10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              distanceMiles != null
                  ? 'Calculated from your pickup and dropoff coordinates.'
                  : 'Select pickup and dropoff locations to calculate distance.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),

            Text(
              'Estimated Price:',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 8.h),
            Text(
              'Generated according to the selected vehicle type, distance, and base fare.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            Text(
              'Notes & Info',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
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
                          'Prices may slightly vary due to real-time traffic.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
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
                          'Distance is calculated using the shortest available route.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
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
                          "You'll see the final price after confirmation.",
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
              label: 'Continue to Details',
              onPressed: () =>
                  Get.toNamed(Routes.MOVER_SCHEDULE, arguments: args),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  double? _toDouble(dynamic value) {
    return double.tryParse((value ?? '').toString());
  }

  double _distanceMiles({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadiusMiles = 3958.7613;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) *
            math.cos(rLat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  double _toRadians(double degree) => degree * (math.pi / 180);
}
