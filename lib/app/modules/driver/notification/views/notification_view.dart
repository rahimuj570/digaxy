import 'package:digaxy/app/modules/driver/notification/widgets/notification_card.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  void _openDetails(Map<String, dynamic> item) {
    final parcelId = (item['parcel_id'] ?? '').toString().trim();
    final parcelNumericId = (item['parcel_numeric_id'] ?? '').toString().trim();

    if (parcelId.isNotEmpty || parcelNumericId.isNotEmpty) {
      Get.toNamed(
        Routes.DRIVER_TASK_DETAIL,
        arguments: {
          if (parcelId.isNotEmpty) 'parcel_id': parcelId,
          if (parcelId.isNotEmpty) 'parcelId': parcelId,
          if (parcelNumericId.isNotEmpty) 'parcelNumericId': parcelNumericId,
          if (parcelNumericId.isNotEmpty) 'parcel_numeric_id': parcelNumericId,
        },
      );
    } else {
      Get.bottomSheet(
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] ?? 'Notification',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                item['subtitle'] ?? item['message'] ?? '',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                ),
              ),
              if ((item['time'] ?? '').toString().isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  item['time'] ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: SizedBox(
        height: 0.7.sh,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 34.sp,
                  color: AppColors.accent.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No notifications yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'You will see incoming delivery and task updates here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.accent),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.notifications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }

                final list = controller.notifications;

                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: Colors.grey[900],
                    onRefresh: controller.refreshNotifications,
                    child: _buildEmptyState(),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: Colors.grey[900],
                  onRefresh: controller.refreshNotifications,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return NotificationCard(
                        title: item['title'] ?? 'Notification',
                        subtitle: item['subtitle'] ?? item['message'] ?? '',
                        time: item['time'] ?? '',
                        parcelId: (item['parcel_id'] ?? item['parcel_numeric_id'] ?? '').toString(),
                        isRead: item['is_read'] == true,
                        onTap: () => _openDetails(item),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
