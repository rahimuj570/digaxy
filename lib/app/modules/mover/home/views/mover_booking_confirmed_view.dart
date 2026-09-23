import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class MoverBookingConfirmedView extends StatelessWidget {
  const MoverBookingConfirmedView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final service = args['service'] ?? 'Pickup Truck';
    final parcelId = args['parcelId'] ?? '';
    final paymentStatus = args['paymentStatus'] ?? 'pending';

    // Format scheduled date/time for readability
    String scheduledDisplay = '';
    final rawDate = args['scheduledDate'];
    final rawTime = args['scheduledTime'] ?? '';
    if (rawDate != null && (rawDate is String) && rawDate.isNotEmpty) {
      try {
        final dt = DateTime.tryParse(rawDate);
        if (dt != null) {
          final local = dt.toLocal();
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          scheduledDisplay =
              '${months[local.month - 1]} ${local.day}, ${local.year}';
        }
      } catch (_) {
        scheduledDisplay = rawDate.toString();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Booking Confirmed',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Icon(
              Icons.check_circle_outline,
              size: 84.sp,
              color: const Color(0xFFC08A10),
            ),
            SizedBox(height: 18.h),
            Text(
              'Your booking is confirmed!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We have scheduled a $service for your move. A driver will contact you shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),

            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Parcel ID
                  if (parcelId.isNotEmpty) ...[
                    Text(
                      'Parcel ID: $parcelId',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                  Text(
                    'Name: ${args['senderName'] ?? ''}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Phone: ${args['senderPhone'] ?? ''}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Scheduled: ${scheduledDisplay.isNotEmpty ? scheduledDisplay : ''}${scheduledDisplay.isNotEmpty && (rawTime ?? '').toString().isNotEmpty ? ' • ' : ''}${rawTime ?? ''}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                  // Payment Status
                  if (paymentStatus.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: paymentStatus == 'paid'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Payment: ${paymentStatus == 'paid' ? 'Paid' : 'Pending'}',
                        style: TextStyle(
                          color: paymentStatus == 'paid'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),
            PrimaryButton(
              label: 'Back to Home',
              onPressed: () => Get.offAllNamed(Routes.MOVER_HOME),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
