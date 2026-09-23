import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'mover_payment_dialog.dart';

class MoverBookingConfirmedView extends StatelessWidget {
  const MoverBookingConfirmedView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final Map apiResp =
        (args['apiResponse'] is Map) ? (args['apiResponse'] as Map) : {};

    final service = args['service'] ??
        args['vehicle_type'] ??
        args['vehicleType'] ??
        apiResp['vehicle_type'] ??
        'Pickup Truck';

    final parcelId = (args['parcel_id'] ??
            args['parcelId'] ??
            args['id'] ??
            apiResp['parcel_id'] ??
            apiResp['id'] ??
            '')
        .toString();

    final price = (args['price'] ??
            args['totalPrice'] ??
            args['estimatedPrice'] ??
            apiResp['price'] ??
            apiResp['total_price'] ??
            '0')
        .toString();

    final senderName = (args['senderName'] ??
            args['pickup_user_name'] ??
            args['pickup_name'] ??
            args['sender_name'] ??
            apiResp['pickup_user_name'] ??
            apiResp['sender_name'] ??
            '')
        .toString();

    final senderPhone = (args['senderPhone'] ??
            args['pickup_phone_number'] ??
            args['pickup_phone'] ??
            args['sender_phone'] ??
            apiResp['pickup_phone_number'] ??
            apiResp['sender_phone'] ??
            '')
        .toString();

    final paymentStatus = (args['payment_status'] ??
            args['paymentStatus'] ??
            apiResp['payment_status'] ??
            'pending')
        .toString()
        .toLowerCase();
    final isPaid = paymentStatus == 'paid' ||
        paymentStatus == 'completed' ||
        paymentStatus == 'success' ||
        paymentStatus == 'succeeded';
    final isPending = !isPaid;

    // Format scheduled date/time for readability
    String scheduledDisplay = '';
    final rawDate = args['scheduledDate'] ??
        args['pickup_date'] ??
        apiResp['pickup_date'];
    final rawTime = (args['scheduledTime'] ??
            args['pickup_time'] ??
            apiResp['pickup_time'] ??
            '')
        .toString();
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      Icon(
                        Icons.check_circle_outline,
                        size: 80.sp,
                        color: const Color(0xFFC08A10),
                      ),
                      SizedBox(height: 16.h),
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
                        isPaid
                            ? 'We have scheduled a $service for your move. A driver will contact you shortly.'
                            : 'We have scheduled a $service for your move.',
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
                            if (parcelId.toString().isNotEmpty) ...[
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
                              'Name: $senderName',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Phone: $senderPhone',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Scheduled: ${scheduledDisplay.isNotEmpty ? scheduledDisplay : ''}${scheduledDisplay.isNotEmpty && rawTime.isNotEmpty ? ' • ' : ''}$rawTime',
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
                                  color: isPaid
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Payment: ${isPaid ? 'Paid' : 'Pending'}',
                                  style: TextStyle(
                                    color: isPaid
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

                      // Info text for pending payment
                      if (isPending) ...[
                        SizedBox(height: 16.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orangeAccent,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'If you do not complete the payment, this booking will not be visible to drivers. To make it visible for a driver, you must complete the payment.',
                                  style: TextStyle(
                                    color: const Color(0xFFFFD59E),
                                    fontSize: 13.sp,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              if (isPending) ...[
                PrimaryButton(
                  label: 'Make Payment',
                  onPressed: () {
                    Get.dialog(
                      MoverPaymentDialog(
                        parcelId: parcelId,
                        price: price,
                        bookingArgs: Map<String, dynamic>.from(args),
                      ),
                      barrierDismissible: false,
                    );
                  },
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 48.h,
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    onPressed: () => Get.offAllNamed(Routes.MOVER_HOME),
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  label: 'Back to Home',
                  onPressed: () => Get.offAllNamed(Routes.MOVER_HOME),
                ),
              ],
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
