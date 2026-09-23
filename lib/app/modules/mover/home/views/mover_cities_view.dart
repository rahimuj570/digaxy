import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MoverCitiesView extends StatelessWidget {
  const MoverCitiesView({super.key});

  final List<Map<String, String>> _cities = const [
    {
      'name': 'Denver, CO',
      'subtitle': 'Capital city · Busy & High Demand',
      'image': 'assets/images/city_denver.png',
    },
    {
      'name': 'Boulder, CO',
      'subtitle': 'College Town · Active & Vibrant',
      'image': 'assets/images/city_boulder.png',
    },
    {
      'name': 'Aurora, CO',
      'subtitle': 'Growing Suburb · Diverse & Expanding',
      'image': 'assets/images/city_aurora.png',
    },
    {
      'name': 'Colorado Springs, CO',
      'subtitle': 'Pikes Peak Region · Scenic',
      'image': 'assets/images/city_springs.png',
    },
  ];

  Widget _cityCard(BuildContext context, Map<String, String> city) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Get.toNamed(Routes.MOVER_CITY_DETAILS, arguments: city);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F10),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.accent.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 110.w,
                      height: 84.h,
                      child: Image.asset(
                        city['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF222222),
                          width: 110.w,
                          height: 84.h,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8.w,
                      top: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        city['name']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        city['subtitle']!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.accent,
                  size: 24.w,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Cities We Serve',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Fast service across selected cities.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _cities.length,
              itemBuilder: (context, i) => _cityCard(context, _cities[i]),
            ),
          ),
        ],
      ),
    );
  }
}
