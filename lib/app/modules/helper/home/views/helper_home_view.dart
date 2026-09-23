import 'package:digaxy/app/modules/driver/home/widgets/active_delivery_card.dart';
import 'package:digaxy/app/modules/driver/home/widgets/no_active_card.dart';
import 'package:digaxy/app/modules/helper/earnings/controllers/earnings_controller.dart';
import 'package:digaxy/app/modules/helper/earnings/views/earnings_view.dart';
import 'package:digaxy/app/modules/helper/home/controllers/helper_home_controller.dart';
import 'package:digaxy/app/modules/helper/home/widgets/helper_bottom_nav.dart';
import 'package:digaxy/app/modules/helper/home/widgets/helper_earning_card.dart';
import 'package:digaxy/app/modules/helper/home/widgets/helper_history_content.dart';
import 'package:digaxy/app/modules/helper/profile/bindings/helper_profile_binding.dart';
import 'package:digaxy/app/modules/helper/profile/views/helper_profile_view.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HelperHomeView extends StatefulWidget {
  const HelperHomeView({super.key});

  @override
  State<HelperHomeView> createState() => _HelperHomeViewState();
}

class _HelperHomeViewState extends State<HelperHomeView> {
  int _navIndex = 0;
  late PageController _pageController;
  late HelperHomeController _homeController;
  late HelperEarningsController _earningsController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
    _homeController = Get.isRegistered<HelperHomeController>()
        ? Get.find<HelperHomeController>()
        : Get.put(HelperHomeController());
    _earningsController = Get.isRegistered<HelperEarningsController>()
        ? Get.find<HelperEarningsController>()
        : Get.put(HelperEarningsController());
    HelperProfileBinding().dependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72.h),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      width: 38.w,
                      height: 38.h,
                    ),
                    SizedBox(width: 8.w),
                    SvgPicture.asset(
                      'assets/icons/text_logo.svg',
                      width: 76.w,
                      height: 14.h,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.toNamed(Routes.HELPER_SETTINGS);
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/settings.svg',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final exists = AppPages.routes.any(
                          (p) => p.name == Routes.HELPER_NOTIFICATIONS,
                        );
                        if (exists) {
                          Get.toNamed(Routes.HELPER_NOTIFICATIONS);
                        } else {
                          Get.snackbar(
                            'Route missing',
                            'Notifications route is not registered',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/notifications.svg',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _navIndex = i),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Obx(
                    () => Text(
                      'Welcome Back, ${_homeController.helperName.value}!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "You're ready to start earning.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  GestureDetector(
                    onTap: () => _homeController.toggleOnlineStatus(
                      !_homeController.isOnline.value,
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          Text(
                            'Online',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Transform.scale(
                            scale: 0.70,
                            child: Switch(
                              value: _homeController.isOnline.value,
                              onChanged: _homeController.toggleOnlineStatus,
                              activeThumbColor: AppColors.textHeadline,
                              inactiveThumbColor: Colors.white54,
                              inactiveTrackColor: Colors.white12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/current_location.svg',
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Use current location',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  Obx(() {
                    if (_homeController.isLoadingActive.value) {
                      return SizedBox(
                        height: 160.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      );
                    }

                    if (_homeController.activeDeliveries.isEmpty) {
                      return SizedBox(
                        height: 160.h,
                        child: const NoActiveCard(),
                      );
                    }

                    return SizedBox(
                      height: 160.h,
                      child: PageView(
                        children: _homeController.activeDeliveries.map((item) {
                          final pickup = (item['pickup_address'] ?? 'N/A')
                              .toString();
                          final dropoff = (item['drop_address'] ?? 'N/A')
                              .toString();
                          final distance = (item['gm_distance_text'] ?? '--')
                              .toString();
                          final eta = (item['gm_eta_text'] ?? '--').toString();
                          final status =
                              (item['delivery_status'] ?? 'Active Delivery')
                                  .toString();

                          final pickupLat = double.tryParse(
                            (item['ping'] ?? item['pickup_lat'] ?? '')
                                .toString(),
                          );
                          final pickupLng = double.tryParse(
                            (item['pong'] ?? item['pickup_lng'] ?? '')
                                .toString(),
                          );
                          final dropLat = double.tryParse(
                            (item['ding'] ?? item['drop_lat'] ?? '').toString(),
                          );
                          final dropLng = double.tryParse(
                            (item['dong'] ?? item['drop_lng'] ?? '').toString(),
                          );

                          final parcelNumericId = (item['id'] ?? '')
                              .toString()
                              .trim();
                          final parcelId = (item['parcel_id'] ?? '')
                              .toString()
                              .trim();

                          return ActiveDeliveryCard(
                            pickup: pickup,
                            dropoff: dropoff,
                            distance: distance,
                            eta: eta,
                            status: status,
                            onTap: () {
                              Get.toNamed(
                                '/helper/task/live',
                                arguments: {
                                  if (parcelNumericId.isNotEmpty)
                                    'parcelId': parcelNumericId,
                                  if (parcelId.isNotEmpty)
                                    'parcel_id': parcelId,
                                  if (parcelId.isNotEmpty) 'jobId': parcelId,
                                  'pickup': pickup,
                                  'dropoff': dropoff,
                                  if (pickupLat != null) 'pickupLat': pickupLat,
                                  if (pickupLng != null) 'pickupLng': pickupLng,
                                  if (dropLat != null) 'dropLat': dropLat,
                                  if (dropLng != null) 'dropLng': dropLng,
                                  'customerName':
                                      (item['pickup_user_name'] ?? '')
                                          .toString(),
                                  'deliveryStatus': status,
                                  'isPickedUp':
                                      status.toLowerCase().contains('onway') ||
                                      status.toLowerCase().contains(
                                        'on_the_way',
                                      ),
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }),

                  SizedBox(height: 18.h),

                  Text(
                    'Earning Overview',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => HelperEarningCard(
                          title: 'Today',
                          value:
                              '\$${_earningsController.today.value.toStringAsFixed(2)}',
                        ),
                      ),
                      Obx(
                        () => HelperEarningCard(
                          title: 'This Week',
                          value:
                              '\$${_earningsController.week.value.toStringAsFixed(2)}',
                        ),
                      ),
                      Obx(
                        () => HelperEarningCard(
                          title: 'Total',
                          value:
                              '\$${_earningsController.lifetime.value.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const HelperEarningsView(),
            const HelperHistoryContent(),
            const HelperProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: HelperBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
