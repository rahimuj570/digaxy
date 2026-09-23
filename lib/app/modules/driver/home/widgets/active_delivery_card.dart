import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActiveDeliveryCard extends StatelessWidget {
  const ActiveDeliveryCard({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.distance,
    required this.eta,
    required this.status,
    this.onTap,
  });

  final String pickup;
  final String dropoff;
  final String distance;
  final String eta;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.only(
          top: 8.h,
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                status,
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Pickup: ',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: pickup,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Drop-off: ',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: dropoff,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white24, thickness: 1),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance', style: TextStyle(color: Colors.white54)),
                      SizedBox(height: 6.h),
                      Text(distance, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimate Time',
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(height: 6.h),
                      Text(eta, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
