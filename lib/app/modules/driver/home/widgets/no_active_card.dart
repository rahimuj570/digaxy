import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoActiveCard extends StatelessWidget {
  const NoActiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No Active Deliveries',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Center(
              child: Text(
                'You\'ll be notified when a new delivery request comes in',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_bottom, color: AppColors.accent),
              SizedBox(width: 8.w),
              Text(
                'Waiting for new delivery requests...',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
