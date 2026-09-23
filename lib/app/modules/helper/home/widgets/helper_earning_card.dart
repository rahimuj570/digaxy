import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelperEarningCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? icon;
  final double? titleSize;
  final double? valueSize;

  const HelperEarningCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.titleSize,
    this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 100.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF092832),
              fontSize: titleSize != null ? titleSize!.sp : 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (icon != null) ...[icon!, SizedBox(width: 6.w)],
              Text(
                value,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: valueSize != null ? valueSize!.sp : 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
