import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MoverCityDetailView extends StatelessWidget {
  const MoverCityDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final city = (Get.arguments ?? <String, String>{}) as Map<String, String>;
    final name = city['name'] ?? 'City';
    final subtitle = city['subtitle'] ?? '';
    final image = city['image'] ?? 'assets/images/splash_D.png';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Cities',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digaxy Movers in $name',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),

            // Pickup / Drop inputs
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.accent.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _buildInputRow(Icons.my_location_outlined, 'Pickup address'),
                  SizedBox(height: 16.h),
                  _buildInputRow(
                    Icons.location_on_outlined,
                    'Drop off address',
                  ),
                  SizedBox(height: 16.h),
                  PrimaryButton(
                    label: 'See prices',
                    onPressed: () {
                      // navigate to services list or estimate
                      Get.toNamed(Routes.MOVER_SERVICES);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // City image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: double.infinity,
                height: 180.h,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: Colors.grey[900]),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Ratings row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem('Digaxy Overall', '4.9/5'),
                _statItem('Delivery Rating', '4.8/5'),
                _statItem('Furniture Movers', '4.7/5'),
              ],
            ),

            SizedBox(height: 18.h),

            Text(
              'Service Available in This City',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 12.h),

            // Services grid (using PNG assets)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _serviceCardImage(
                  'Lite',
                  'Small/light items',
                  'assets/images/1.png',
                ),
                _serviceCardImage('Van', 'Large moves', 'assets/images/2.png'),
                _serviceCardImage(
                  'Pickup',
                  'Medium moves',
                  'assets/images/3.png',
                ),
                _serviceCardImage(
                  'XL',
                  'Oversized loads',
                  'assets/images/4.png',
                ),
              ],
            ),

            SizedBox(height: 18.h),

            Text(
              'Why Choose Digaxy in This City (Local Benefits)',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bullet('Near-instant delivery times'),
                _bullet('Best rates for short-distance moves'),
                _bullet('Movers available 7 days a week'),
                _bullet('Same-day and scheduled deliveries'),
                _bullet('Background-checked helpers'),
              ],
            ),

            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(IconData icon, String placeholder) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        SizedBox(width: 12.w),
        Expanded(
          child: TextField(
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _serviceCardImage(String title, String subtitle, String assetPath) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.accent.withAlpha(20)),
        color: const Color(0xFF0F0F10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40.h,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                color: Colors.transparent,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text, style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
