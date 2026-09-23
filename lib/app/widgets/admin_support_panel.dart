import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminSupportPanel extends StatelessWidget {
  const AdminSupportPanel({super.key});

  void _showContactOptions(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        elevation: 24,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Admin Support',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: AppColors.textPrimary),
              title: Text(
                'Call Admin',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: AppColors.textPrimary),
              title: Text(
                'Email Admin',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 8.h),
            Text(
              'Our support team is available 24/7.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      barrierColor: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _showContactOptions(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.support_agent, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Support',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Contact our support team for help',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
