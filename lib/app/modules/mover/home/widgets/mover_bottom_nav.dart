import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoverBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MoverBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assetPaths = [
      'assets/icons/home.svg',
      'assets/icons/bookings.svg',
      'assets/icons/cities.svg',
      'assets/icons/profile.svg',
    ];
    final labels = ['Home', 'Bookings', 'Cities', 'Profile'];

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.only(top: 6.h),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.white54,
          items: List.generate(
            assetPaths.length,
            (i) => BottomNavigationBarItem(
              icon: SvgPicture.asset(
                assetPaths[i],
                color: currentIndex == i ? AppColors.accent : Colors.white54,
                width: 20.w,
                height: 20.w,
              ),
              label: labels[i],
            ),
          ),
        ),
      ),
    );
  }
}
