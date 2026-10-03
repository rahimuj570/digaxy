import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelperNotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String? parcelId;
  final bool isRead;
  final VoidCallback? onTap;

  const HelperNotificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.parcelId,
    this.isRead = true,
    this.onTap,
  });

  IconData _iconForNotification(String title, String message) {
    final lower = '$title $message'.toLowerCase();
    if (lower.contains('otp')) return Icons.vpn_key_outlined;
    if (lower.contains('assigned') || lower.contains('new task') || lower.contains('new delivery')) {
      return Icons.assignment_outlined;
    }
    if (lower.contains('picked up') || lower.contains('on the way') || lower.contains('in transit')) {
      return Icons.local_shipping_outlined;
    }
    if (lower.contains('accepted')) return Icons.check_circle_outline;
    if (lower.contains('delivered') || lower.contains('completed')) {
      return Icons.task_alt;
    }
    if (lower.contains('payment') || lower.contains('payout') || lower.contains('earning')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (lower.contains('cancel') || lower.contains('failed')) {
      return Icons.cancel_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  Color _colorForNotification(String title, String message) {
    final lower = '$title $message'.toLowerCase();
    if (lower.contains('otp')) return const Color(0xFFE5A93C);
    if (lower.contains('delivered') || lower.contains('completed') || lower.contains('accepted')) {
      return Colors.greenAccent.shade400;
    }
    if (lower.contains('payment') || lower.contains('payout') || lower.contains('earning')) {
      return Colors.blueAccent;
    }
    if (lower.contains('cancel') || lower.contains('failed')) {
      return Colors.redAccent;
    }
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForNotification(title, subtitle);
    final accentColor = _colorForNotification(title, subtitle);
    final hasParcel = parcelId != null && parcelId!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isRead ? Colors.white10 : accentColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
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
                                color: isRead ? AppColors.textPrimary : AppColors.textHeadline,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5.sp,
                              ),
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Text(
                              time,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (hasParcel) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Task #$parcelId',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.accent,
                                size: 8.sp,
                              ),
                            ],
                          ),
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
}
