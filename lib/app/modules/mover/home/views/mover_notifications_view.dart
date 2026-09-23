import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import '../controllers/mover_notifications_controller.dart';

class MoverNotificationsView extends GetView<MoverNotificationsController> {
  const MoverNotificationsView({super.key});

  void _openDetails(Map<String, String> item) {
    Get.toNamed(
      Routes.MOVER_PARCEL_TRACKING,
      arguments: {
        'title': item['title'] ?? 'Parcel Tracking',
        'status': item['subtitle'] ?? 'In Transit',
      },
    );
  }

  Widget _row(
    IconData icon,
    String title, {
    String subtitle = '',
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFC08A10),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey.shade800, height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notification',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Obx(() {
          final recent = controller.recentNotifications;
          final previous = controller.notifications;

          IconData iconForTitle(String title) {
            final lower = title.toLowerCase();
            if (lower.contains('book')) return Icons.check_box_outlined;
            if (lower.contains('way') || lower.contains('ship')) {
              return Icons.local_shipping_outlined;
            }
            if (lower.contains('pay')) return Icons.payment;
            if (lower.contains('promo') || lower.contains('discount')) {
              return Icons.card_giftcard;
            }
            return Icons.notifications_outlined;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      if (recent.isEmpty)
                        _row(Icons.notifications_none, 'No notifications yet')
                      else
                        ...recent.map(
                          (item) => _row(
                            iconForTitle(item['title'] ?? ''),
                            item['title'] ?? 'Notification',
                            subtitle: item['subtitle'] ?? '',
                            onTap: () => _openDetails(item),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),
                Text(
                  'Previous',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      if (previous.isEmpty)
                        _row(Icons.history, 'No previous notifications')
                      else
                        ...previous.map(
                          (item) => _row(
                            iconForTitle(item['title'] ?? ''),
                            item['title'] ?? 'Notification',
                            subtitle: item['subtitle'] ?? '',
                            onTap: () => _openDetails(item),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
