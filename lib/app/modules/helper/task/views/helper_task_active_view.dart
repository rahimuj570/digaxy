import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/helper_task_active_controller.dart';

class HelperTaskActiveView extends GetView<HelperTaskActiveController> {
  const HelperTaskActiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Obx(
          () => Text(
            controller.title.value,
            style: TextStyle(color: AppColors.accent),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.subtitle.value,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 12.h),

                Text(
                  'Booking Details',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line('Pickup Address', controller.pickupAddress.value),
                      SizedBox(height: 8.h),
                      _line('Drop-Off Address', controller.dropoffAddress.value),
                      if (controller.scheduledTime.value.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _line('Scheduled Time', controller.scheduledTime.value),
                      ],
                      if (controller.itemType.value.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _line('Item Type', controller.itemType.value),
                      ],
                      if (controller.date.value.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _line('Date', controller.date.value),
                      ],
                      if (controller.distancePay.value.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _line('Distance', controller.distancePay.value),
                      ],
                      if (controller.totalHelperPay.value.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _line('Total Helper Pay', controller.totalHelperPay.value),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Live movement On Map',
                    onPressed: () {
                      final parcelNum =
                          (controller.parcelNumericId ?? 0).toString();
                      final uuid = controller.parcelId.value.trim();

                      Get.toNamed(
                        Routes.HELPER_TASK_LIVE,
                        arguments: {
                          if (parcelNum != '0') 'parcelId': parcelNum,
                          if (uuid.isNotEmpty) 'parcel_id': uuid,
                          if (uuid.isNotEmpty) 'jobId': uuid,
                          'pickup': controller.pickupAddress.value,
                          'dropoff': controller.dropoffAddress.value,
                          'pickupLat': ?controller.pickupLat.value,
                          'pickupLng': ?controller.pickupLng.value,
                          'dropLat': ?controller.dropLat.value,
                          'dropLng': ?controller.dropLng.value,
                          'customerName': controller.customerName.value,
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.h),
                Text(
                  'Your Customer',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: AppColors.textSecondary),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          [
                            controller.customerName.value.isNotEmpty
                                ? controller.customerName.value
                                : 'Customer',
                            if (controller.customerPhone.value.isNotEmpty)
                              controller.customerPhone.value,
                          ].join(' / '),
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.callCustomer(),
                        icon: Icon(Icons.call, color: AppColors.textHeadline),
                        tooltip: 'Call Customer',
                      ),
                      IconButton(
                        onPressed: () => controller.messageCustomer(),
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.textHeadline,
                        ),
                        tooltip: 'Message Customer',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                Text(
                  'Payment',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line('Method', controller.paymentMethod.value),
                      SizedBox(height: 6.h),
                      _line('Transaction ID', controller.transactionId.value),
                      SizedBox(height: 6.h),
                      _line('Status', controller.paymentStatus.value),
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

  Widget _line(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '--',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
