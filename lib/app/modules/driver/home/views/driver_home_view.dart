import 'package:digaxy/app/modules/driver/home/widgets/active_delivery_card.dart';
import 'package:digaxy/app/modules/driver/home/widgets/earning_card.dart';
import 'package:digaxy/app/modules/driver/home/widgets/no_active_card.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:digaxy/app/modules/driver/home/widgets/driver_bottom_nav.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/app/modules/driver/earnings/widgets/earnings_content.dart';
import 'package:digaxy/app/modules/driver/profile/views/profile_view.dart';
import 'package:digaxy/app/modules/driver/home/widgets/history_content.dart';
import 'package:digaxy/app/modules/driver/profile/bindings/profile_binding.dart';
import 'package:digaxy/app/modules/driver/home/controllers/driver_home_controller.dart';
import 'package:digaxy/app/modules/driver/earnings/controllers/earnings_controller.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({super.key});

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  int _navIndex = 0;
  late PageController _pageController;
  late DriverHomeController _homeController;
  late EarningsController _earningsController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
    _homeController = Get.isRegistered<DriverHomeController>()
        ? Get.find<DriverHomeController>()
        : Get.put(DriverHomeController());
    _earningsController = Get.isRegistered<EarningsController>()
        ? Get.find<EarningsController>()
        : Get.put(EarningsController());
    ProfileBinding().dependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _homeController.refreshActiveDeliveries(),
      _homeController.fetchCurrentLocation(),
      _earningsController.loadEarnings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // logo icon
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      width: 38.w,
                      height: 38.h,
                    ),
                    SizedBox(width: 8.w),
                    // text logo
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
                        // Navigate to settings
                        Get.toNamed(Routes.DRIVER_SETTINGS);
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/settings.svg',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Defensive: only navigate if the route is registered to avoid null errors
                        final exists = AppPages.routes.any(
                          (p) => p.name == Routes.DRIVER_NOTIFICATIONS,
                        );
                        if (exists) {
                          Get.toNamed(Routes.DRIVER_NOTIFICATIONS);
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
            // Home tab content (original body)
            RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: Colors.grey[900],
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Obx(
                      () => Text(
                        'Welcome Back, ${_homeController.driverName.value}!',
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

                    // Helper callout pill
                    // GestureDetector(
                    //   onTap: () {
                    //     // TODO: navigate to helper certification flow
                    //   },
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: 12.w,
                    //       vertical: 8.h,
                    //     ),
                    //     margin: EdgeInsets.only(bottom: 12.h),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white10,
                    //       borderRadius: BorderRadius.circular(28.r),
                    //       border: Border.all(
                    //         color: AppColors.accent.withAlpha(46),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Text(
                    //           "Don't own a truck? ",
                    //           style: TextStyle(
                    //             color: AppColors.textSecondary,
                    //             fontSize: 12.sp,
                    //           ),
                    //         ),
                    //         SizedBox(width: 6.w),
                    //         Text(
                    //           'Become a certified helper!',
                    //           style: TextStyle(
                    //             color: AppColors.textHeadline,
                    //             fontSize: 12.sp,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // Online toggle and search
                    Obx(
                      () => GestureDetector(
                        onTap: () => _homeController.toggleOnlineStatus(),
                        child: Row(
                          children: [
                            Text(
                              _homeController.isOnline.value
                                  ? 'Online'
                                  : 'Offline',
                              style: TextStyle(
                                color: _homeController.isOnline.value
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Transform.scale(
                              scale: 0.70,
                              child: Switch(
                                value: _homeController.isOnline.value,
                                onChanged: (v) =>
                                    _homeController.setOnlineStatus(v),
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

                    // Use current location button
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
                            child: Obx(
                              () => Text(
                                _homeController.currentAddress.value,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Obx(() {
                            if (_homeController.isLoadingLocation.value) {
                              return SizedBox(
                                width: 14.w,
                                height: 14.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () =>
                                  _homeController.fetchCurrentLocation(),
                              child: const Icon(
                                Icons.refresh,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // PageView showing no active / active delivery cards
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
                        height: 300.h,
                        child: PageView(
                          children: _homeController.activeDeliveries.map((
                            item,
                          ) {
                            final pickup = (item['pickup_address'] ?? 'N/A')
                                .toString();
                            final dropoff = (item['drop_address'] ?? 'N/A')
                                .toString();
                            final distance = (item['gm_distance_text'] ??
                                    item['estimated_distance_km'] ??
                                    item['estimated_distance'] ??
                                    item['distance'] ??
                                    '--')
                                .toString();
                            final eta = (item['gm_eta_text'] ??
                                    item['estimated_time_minutes'] ??
                                    item['estimated_time'] ??
                                    item['eta'] ??
                                    item['duration'] ??
                                    '--')
                                .toString();
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
                              (item['ding'] ?? item['drop_lat'] ?? '')
                                  .toString(),
                            );
                            final dropLng = double.tryParse(
                              (item['dong'] ?? item['drop_lng'] ?? '')
                                  .toString(),
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
                                  Routes.DRIVER_TASK_LIVE,
                                  arguments: {
                                    if (parcelNumericId.isNotEmpty)
                                      'parcelId': parcelNumericId,
                                    if (parcelId.isNotEmpty)
                                      'parcel_id': parcelId,
                                    if (parcelId.isNotEmpty) 'jobId': parcelId,
                                    'pickup': pickup,
                                    'dropoff': dropoff,
                                    if (pickupLat != null)
                                      'pickupLat': pickupLat,
                                    if (pickupLng != null)
                                      'pickupLng': pickupLng,
                                    if (dropLat != null) 'dropLat': dropLat,
                                    if (dropLng != null) 'dropLng': dropLng,
                                    'customerName':
                                        (item['pickup_user_name'] ?? '')
                                            .toString(),
                                    'deliveryStatus': status,
                                    'isPickedUp':
                                        status.toLowerCase().contains(
                                          'onway',
                                        ) ||
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
                          () => EarningCard(
                            title: 'Today',
                            value:
                                '\$${_earningsController.today.value.toStringAsFixed(2)}',
                            valueSize: 16,
                          ),
                        ),
                        Obx(
                          () => EarningCard(
                            title: 'This Week',
                            value:
                                '\$${_earningsController.week.value.toStringAsFixed(2)}',
                            valueSize: 16,
                          ),
                        ),
                        Obx(
                          () => EarningCard(
                            title: 'Total',
                            value:
                                '\$${_earningsController.lifetime.value.toStringAsFixed(2)}',
                            valueSize: 16,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),
                    // Text(
                    //   'Quick Action',
                    //   style: TextStyle(
                    //     color: AppColors.textHeadline,
                    //     fontSize: 14.sp,
                    //     fontWeight: FontWeight.w700,
                    //   ),
                    // ),
                    // SizedBox(height: 8.h),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   physics: BouncingScrollPhysics(),
                    //   child: Row(
                    //     children: [
                    //       QuickActionButton(
                    //         label: 'My Deliveries',
                    //         icon: SvgPicture.asset(
                    //           'assets/icons/my_deliveries.svg',
                    //           width: 20.w,
                    //           height: 20.h,
                    //         ),
                    //         onPressed: () {},
                    //       ),
                    //       QuickActionButton(
                    //         label: 'Payouts',
                    //         icon: SvgPicture.asset(
                    //           'assets/icons/payouts.svg',
                    //           width: 20.w,
                    //           height: 20.h,
                    //         ),
                    //         onPressed: () {},
                    //       ),
                    //       QuickActionButton(
                    //         label: 'Availability',
                    //         icon: SvgPicture.asset(
                    //           'assets/icons/availability.svg',
                    //           width: 20.w,
                    //           height: 20.h,
                    //         ),
                    //         onPressed: () {},
                    //       ),
                    //       SizedBox(width: 6.w),
                    //     ],
                    //   ),
                    // ),
                    // const Spacer(),
                  ],
                ),
              ),
            ),

            // Earnings tab content (embedded)
            Container(color: Colors.black, child: const EarningsContent()),

            // History content
            const HistoryContent(),

            // Profile view
            const ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: DriverBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          // animate to the selected page so appbar/nav remain
          _pageController.animateToPage(
            i,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
