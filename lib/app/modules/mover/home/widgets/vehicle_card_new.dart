import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleCardNew extends StatelessWidget {
  final String title;
  final String price;
  final String assetName;
  final VoidCallback? onTap;
  final bool selected;

  const VehicleCardNew({
    super.key,
    required this.title,
    required this.price,
    required this.assetName,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.accent : Colors.transparent;
    final cardColor = selected
        ? const Color(0xFF262626)
        : const Color(0xFF2B2B2B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: borderColor, width: selected ? 1.5 : 0),
        ),
        elevation: selected ? 6 : 2,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      // child: SvgPicture.asset(
                      //   assetName,
                      //   width: 44.w,
                      //   height: 44.w,
                      // ),
                      child: Image.asset(
                        assetName,
                        height: 60.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    price,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 0.h,
                  right: 0.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 14.w, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
