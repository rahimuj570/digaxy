import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor,
    this.textColor,
  }) : assert(label != null || child != null, 'Provide label or child');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.accent,
          foregroundColor: textColor ?? AppColors.textPrimary,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: loading
            ? SizedBox(
                height: 22.h,
                width: 22.w,
                child: CircularProgressIndicator(),
              )
            : (child ??
                  Text(
                    label!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  )),
      ),
    );
  }
}
