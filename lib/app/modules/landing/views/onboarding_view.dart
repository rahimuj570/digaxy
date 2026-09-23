import 'dart:async';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  late Timer _timer;
  int _current = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/icons/onboarding1.svg',
      'title': 'Join DIGAXY as a Professional Driver',
      'subtitle':
          'Connect with verified customers, earn money on your schedule.',
    },
    {
      'image': 'assets/icons/onboarding2.svg',
      'title': 'Instant Job Alerts',
      'subtitle':
          'Accept jobs, plan your route, and stay updated in real time.',
    },
    {
      'image': 'assets/icons/onboarding3.svg',
      'title': 'Work on Your Time',
      'subtitle': 'Choose when to work — accept jobs that match your schedule.',
    },
    {
      'image': 'assets/icons/onboarding4.svg',
      'title': 'Right Job for You',
      'subtitle':
          'Find deliveries that fit your vehicle, load size, and experience.',
    },
    {
      'image': 'assets/icons/onboarding5.svg',
      'title': 'Safe & Secure Earnings',
      'subtitle':
          'Every trip is protected with verified customers and instant payments.',
    },
    {
      'image': 'assets/icons/onboarding6.svg',
      'title': 'Trusted Professional Network',
      'subtitle':
          'Join a verified platform built for skilled movers and drivers.',
    },
  ];

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final realLength = _pages.length;
      final next = _current + 1;
      final target = next < realLength
          ? next
          : realLength; // animate to clone when wrapping
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    if (_timer.isActive) _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  final realLength = _pages.length;
                  if (index == realLength) {
                    // reached cloned page; snap to real first page without animation
                    setState(() {
                      _current = 0;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _pageController.jumpToPage(0);
                    });
                  } else {
                    setState(() {
                      _current = index;
                    });
                  }
                  // restart timer to give user time after manual swipe
                  _stopAutoPlay();
                  _startAutoPlay();
                },
                // add one cloned page (first page) at the end for seamless forward looping
                itemCount: _pages.length + 1,
                itemBuilder: (context, index) {
                  final realLength = _pages.length;
                  final item = index < realLength ? _pages[index] : _pages[0];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        // image placeholder (SVG)
                        SizedBox(
                          height: 260.h,
                          child: SvgPicture.asset(
                            item['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Title with only the word 'DIGAXY' colored differently
                        item['title']!.contains('DIGAXY')
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: item['title']!.split('DIGAXY')[0],
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'DIGAXY',
                                      style: TextStyle(
                                        color: AppColors.textHeadline,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          item['title']!
                                                  .split('DIGAXY')
                                                  .length >
                                              1
                                          ? item['title']!.split('DIGAXY')[1]
                                          : '',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                item['title']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                        SizedBox(height: 18.h),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // indicators & button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _current == i ? 28.w : 12.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: _current == i
                              ? AppColors.accent
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // If last page, proceed to role selection; otherwise go next
                        // if (_current == _pages.length - 1) {
                        //   Get.toNamed(Routes.LANDING_ROLE);
                        // } else {
                        //   final next = (_current + 1) % _pages.length;
                        //   _pageController.animateToPage(
                        //     next,
                        //     duration: const Duration(milliseconds: 400),
                        //     curve: Curves.easeInOut,
                        //   );
                        // }
                        Get.toNamed(Routes.LANDING_ROLE);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _current == _pages.length - 1
                            ? 'GET STARTED'
                            : 'GET STARTED',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: Color(0xFF092832),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
