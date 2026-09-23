import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'mover_payment_webview.dart';

class MoverPaymentDialog extends StatefulWidget {
  final String parcelId;
  final String price;
  final Map<String, dynamic> bookingArgs;

  const MoverPaymentDialog({
    super.key,
    required this.parcelId,
    required this.price,
    required this.bookingArgs,
  });

  @override
  State<MoverPaymentDialog> createState() => _MoverPaymentDialogState();
}

class _MoverPaymentDialogState extends State<MoverPaymentDialog> {
  bool _isLoading = false;

  Future<void> _handlePayNow() async {
    setState(() => _isLoading = true);
    try {
      final api = Get.isRegistered<ApiService>()
          ? Get.find<ApiService>()
          : ApiService();
      print('sssssssssssssssssssssssss');
      final resp = await api.createPaymentCheckout(parcelId: widget.parcelId);
      debugPrint('Payment checkout response: $resp');

      // Extract checkout URL from response
      final checkoutUrl = resp['checkout_url'] ?? resp['url'];
      if (checkoutUrl != null && (checkoutUrl is String)) {
        debugPrint('Opening Stripe checkout URL: $checkoutUrl');
        // Close dialog before opening in-app webview
        Get.back();

        // Open Stripe checkout inside WebView to intercept success/cancel URLs
        Get.to(
          () => MoverPaymentWebView(
            checkoutUrl: checkoutUrl,
            parcelId: widget.parcelId,
            bookingArgs: widget.bookingArgs,
            successPath: '/payment/success',
            cancelPath: '/payment/cancel',
          ),
        );
      } else {
        debugPrint('Invalid checkout URL in response: $resp');
        Get.snackbar(
          'Error',
          'Invalid payment response from server',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      setState(() => _isLoading = false);
    }
  }

  void _handlePayLater() {
    Get.back();
    final next = {
      ...widget.bookingArgs,
      'parcelId': widget.parcelId,
      'parcel_id': widget.parcelId,
      'price': widget.price,
      'paymentStatus': 'pending',
      'payment_status': 'pending',
    };
    Get.toNamed(Routes.MOVER_BOOKING_CONFIRMED, arguments: next);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.2),
              ),
              child: Icon(
                Icons.check_circle,
                size: 40.sp,
                color: AppColors.accent,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),

            // Description
            Text(
              'Your booking has been created successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),

            // Price Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$${widget.price}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Payment Question
            Text(
              'Would you like to pay now?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handlePayNow,
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(
                        color: AppColors.accent.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handlePayLater,
                    child: Text(
                      'Pay Later',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
