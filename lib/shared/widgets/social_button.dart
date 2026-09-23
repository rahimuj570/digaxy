import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'primary_button.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String svgAsset;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const SocialButton({
    super.key,
    required this.label,
    required this.svgAsset,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.white12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(svgAsset, height: 26.h, width: 26.w),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
