import 'package:digaxy/app/modules/driver/home/widgets/earning_card.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningsView extends StatelessWidget {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Row(
          children: [
            Text(
              'Earnings',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top summary cards (2x2 grid similar to design)
              Row(
                children: [
                  Expanded(
                    child: EarningCard(title: "Today", value: '\$40.25'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: EarningCard(title: "This week", value: '\$355.00'),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: EarningCard(
                      title: "This month",
                      value: '\$1,438.50',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: EarningCard(title: 'Lifetime', value: '\$8,367.75'),
                  ),
                ],
              ),

              SizedBox(height: 18.h),
              // Growth chart placeholder (fl_chart removed for now)
              Container(
                width: double.infinity,
                height: 140.h,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'Growth chart',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),

              SizedBox(height: 18.h),
              Text(
                'Commission',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Total payouts requested',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '\$3,440.75',
                      style: TextStyle(
                        color: AppColors.textHeadline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    'Payout',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
