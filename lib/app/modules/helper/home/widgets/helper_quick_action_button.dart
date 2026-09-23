import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelperQuickActionButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;

  const HelperQuickActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.accent.withAlpha(150)),
      ),
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          minimumSize: Size(0, 30.h),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SizedBox(width: 2.w),
              IconTheme(
                data: IconThemeData(size: 14.h, color: AppColors.textPrimary),
                child: icon!,
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
