import 'package:digaxy/app/modules/helper/earnings/controllers/earnings_controller.dart';
import 'package:digaxy/app/modules/driver/earnings/widgets/growth_chart_card.dart';
import 'package:digaxy/app/modules/driver/home/widgets/earning_card.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelperEarningsContent extends GetView<HelperEarningsController> {
  const HelperEarningsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Expanded(
                    child: EarningCard(
                      title: 'Today',
                      value: '\$${controller.today.value.toStringAsFixed(2)}',
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                Obx(
                  () => Expanded(
                    child: EarningCard(
                      title: 'This week',
                      value: '\$${controller.week.value.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Obx(
                  () => Expanded(
                    child: EarningCard(
                      title: 'This month',
                      value: '\$${controller.month.value.toStringAsFixed(2)}',
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Obx(
                  () => Expanded(
                    child: EarningCard(
                      title: 'Lifetime',
                      value:
                          '\$${controller.lifetime.value.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            GrowthChartCard(),

            SizedBox(height: 18.h),
            Text(
              'Commission',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Obx(
                    () => _buildKeyValueRow(
                      'Total payouts requested',
                      '\$${controller.lifetime.value.toStringAsFixed(2)}',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => _buildKeyValueRow(
                      'Total pending payouts',
                      '\$${controller.pending.value.toStringAsFixed(2)}',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => _buildKeyValueRow(
                      'Last payout date',
                      controller.lastPayoutDate.value,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => _buildKeyValueRow(
                      'Payment method (Stripe, Cash on hand)',
                      controller.paymentMethod.value,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),
            Text(
              'Earnings Breakdown',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            // Earnings list
            Obx(() {
              final list = controller.earnings;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      'No earnings yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return Column(
                children: List.generate(list.length, (index) {
                  final item = list[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Text(
                              'Job ${item['jobId']}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item['date'] ?? '',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            item['route'] ?? '',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      Divider(color: Colors.white10),
                    ],
                  );
                }),
              );
            }),
            // const Spacer(),
            PrimaryButton(
              label: 'Payout',
              onPressed: () => controller.requestPayout(),
              backgroundColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.white70)),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
