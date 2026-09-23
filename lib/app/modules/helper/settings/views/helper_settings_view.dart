import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/helper_settings_controller.dart';
import 'package:digaxy/app/widgets/admin_support_panel.dart';

class HelperSettingsView extends GetView<HelperSettingsController> {
  const HelperSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Settings',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        'Change Password',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () =>
                          Get.toNamed(Routes.HELPER_SETTINGS_CHANGE_PASSWORD),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        'Privacy Policy',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => Get.toNamed(Routes.HELPER_SETTINGS_PRIVACY),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.article_outlined,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        'Terms & Condition',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => Get.toNamed(Routes.HELPER_SETTINGS_TERMS),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        'Help & Support',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => Get.toNamed(Routes.HELPER_SETTINGS_HELP),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.redAccent),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            title: Text(
                              'Confirm logout',
                              style: TextStyle(
                                color: AppColors.textHeadline,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                onPressed: () {
                                  Get.back();
                                  try {
                                    controller.logout();
                                  } catch (_) {}
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const AdminSupportPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
