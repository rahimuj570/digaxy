import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/helper_priority_controller.dart';

class HelperPriorityView extends GetView<HelperPriorityController> {
  const HelperPriorityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Priority Level',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),
                _levelsRow(),
                SizedBox(height: 18.h),
                Obx(
                  () => Text(
                    'Your Current Priority: ${controller.currentPriorityLabel}',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Next Level',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Next Upgrade: ${controller.nextUpgrade}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                Column(
                  children: controller.criteria
                      .map((c) => _criterionRow(c))
                      .toList(),
                ),

                SizedBox(height: 18.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Benefits of priority ${controller.currentLevel.value}',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    controller.benefits,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),

                SizedBox(height: 26.h),
                Text(
                  'Next: Priority ${controller.currentLevel.value - 1}',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _levelsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _hexBadge(1),
        SizedBox(width: 20.w),
        _hexBadge(2, highlighted: true),
        SizedBox(width: 20.w),
        _hexBadge(3),
      ],
    );
  }

  Widget _hexBadge(int level, {bool highlighted = false}) {
    final color = highlighted
        ? const Color(0xFF775000)
        : const Color(0xFF201600);
    final textColor = highlighted
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    final double w = highlighted ? 96.w : 72.w;
    final double h = highlighted ? 84.h : 64.h;
    final double numberSize = highlighted ? 24.sp : 18.sp;
    final double labelSize = highlighted ? 16.sp : 12.sp;

    return Column(
      children: [
        ClipPath(
          clipper: _HexagonClipper(),
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: color,
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  level.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: numberSize,
                  ),
                ),
                Text(
                  'Priority',
                  style: TextStyle(color: textColor, fontSize: labelSize),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _criterionRow(HelperPriorityCriterion c) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check,
            color: c.completed.value ? AppColors.accent : Colors.white24,
            size: 18.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: TextStyle(color: AppColors.textPrimary)),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: c.progress.value,
                        color: AppColors.accent,
                        backgroundColor: Colors.white12,
                        minHeight: 6.h,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      c.subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
