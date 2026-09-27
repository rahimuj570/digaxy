import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import '../controllers/mover_notifications_controller.dart';

class MoverNotificationsView extends GetView<MoverNotificationsController> {
  const MoverNotificationsView({super.key});

  void _openDetails(Map<String, dynamic> item) {
    final parcelId = item['parcel_id'] ?? item['parcel'];
    final parcelUuid = (item['parcel_uuid'] ?? '').toString();

    if (parcelId != null || parcelUuid.isNotEmpty) {
      Get.toNamed(
        Routes.MOVER_PARCEL_TRACKING,
        arguments: {
          'title': item['title'] ?? 'Parcel Tracking',
          'status': item['message'] ?? 'In Transit',
          'parcelId': parcelId,
          'parcel_id': parcelId,
          'parcel_uuid': parcelUuid,
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
                item['message'] ?? '',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                ),
              ),
              if ((item['time'] ?? '').isNotEmpty) ...[
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

  IconData _iconForNotification(String title, String message) {
    final lower = '$title $message'.toLowerCase();
    if (lower.contains('otp')) return Icons.vpn_key_outlined;
    if (lower.contains('picked up') || lower.contains('on the way')) {
      return Icons.local_shipping_outlined;
    }
    if (lower.contains('accepted')) return Icons.check_circle_outline;
    if (lower.contains('delivered')) return Icons.task_alt;
    if (lower.contains('payment') || lower.contains('received')) {
      return Icons.receipt_long_outlined;
    }
    if (lower.contains('promo') || lower.contains('discount')) {
      return Icons.card_giftcard;
    }
    return Icons.notifications_outlined;
  }

  Color _colorForNotification(String title, String message) {
    final lower = '$title $message'.toLowerCase();
    if (lower.contains('otp')) return const Color(0xFFE5A93C);
    if (lower.contains('delivered') || lower.contains('accepted')) {
      return Colors.greenAccent.shade400;
    }
    if (lower.contains('payment')) return Colors.blueAccent;
    if (lower.contains('picked up') || lower.contains('on the way')) {
      return const Color(0xFFC08A10);
    }
    return const Color(0xFFC08A10);
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final title = item['title'] ?? 'Notification';
    final message = item['message'] ?? '';
    final time = item['time'] ?? '';
    final otp = (item['otp'] ?? '').toString();
    final isRead = item['is_read'] == true;
    final parcelId = item['parcel_id'] ?? item['parcel'];
    final icon = _iconForNotification(title, message);
    final accentColor = _colorForNotification(title, message);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isRead ? Colors.transparent : accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetails(item),
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textHeadline,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Text(
                              time,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (message.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          message,
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(alpha: 0.85),
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                      ],
                      // Extra Tags (OTP / Parcel tracking CTA)
                      if (otp.isNotEmpty || parcelId != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (otp.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: otp));
                                  Get.snackbar('Copied', 'OTP $otp copied to clipboard');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC08A10).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: const Color(0xFFC08A10),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.vpn_key_outlined,
                                        color: const Color(0xFFE5A93C),
                                        size: 11.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'OTP: $otp',
                                        style: TextStyle(
                                          color: const Color(0xFFE5A93C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (parcelId != null) ...[
                              if (otp.isNotEmpty) SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Parcel #$parcelId',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.textSecondary,
                                      size: 8.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.recentNotifications.isEmpty &&
            controller.previousNotifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final recent = controller.recentNotifications;
        final previous = controller.previousNotifications;

        if (recent.isEmpty && previous.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 0.7.sh,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            children: [
              if (recent.isNotEmpty) ...[
                Text(
                  'Recent',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                ...recent.map(_notificationCard),
                SizedBox(height: 14.h),
              ],
              if (previous.isNotEmpty) ...[
                Text(
                  'Previous',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                ...previous.map(_notificationCard),
                SizedBox(height: 20.h),
              ],
            ],
          ),
        );
      }),
    );
  }
}
