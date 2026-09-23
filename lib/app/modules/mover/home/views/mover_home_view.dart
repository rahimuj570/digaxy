import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../widgets/mover_bottom_nav.dart';
import '../widgets/vehicle_card_new.dart';
import '../../profile/views/mover_profile_view.dart';
import '../../profile/controllers/mover_profile_controller.dart';
import 'mover_bookings_view.dart';
import 'mover_cities_view.dart';
import '../controllers/mover_home_controller.dart';
import 'package:digaxy/app/modules/mover/home/widgets/mover_chatbot.dart';

class MoverHomeView extends StatefulWidget {
  const MoverHomeView({super.key});

  @override
  State<MoverHomeView> createState() => _MoverHomeViewState();
}

class _MoverHomeViewState extends State<MoverHomeView> {
  int _navIndex = 0;
  int _selectedVehicle = -1;
  late PageController _pageController;
  late final MoverHomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.isRegistered<MoverHomeController>()
        ? Get.find<MoverHomeController>()
        : Get.put(MoverHomeController());
    _pageController = PageController(initialPage: _navIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
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
                  // text logo with subtitle beneath
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/text_logo.svg',
                        width: 76.w,
                        height: 14.h,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'YOUR MOVE • OUR PRIORITY',
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to settings
                      Get.toNamed(Routes.MOVER_SETTINGS);
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/settings.svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigate to notifications
                      Get.toNamed(Routes.MOVER_NOTIFICATIONS);
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
    );
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              'Welcome Back, ${_homeController.userName.value}!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ready to book your next move?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 18.h),
          Text(
            'Book A Move',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => Text(
                      _homeController.currentAddress.value,
                      style: TextStyle(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(() {
                  if (_homeController.isLoadingLocation.value) {
                    return SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => _homeController.fetchCurrentLocation(),
                    child: const Icon(
                      Icons.refresh,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Choose Vehicle Type',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.2,
              children: List.generate(4, (i) {
                final names = [
                  'Pickup Truck',
                  'Van',
                  'Mini Box Truck',
                  '26-foot Box truck',
                ];
                final prices = [
                  '\$42.92 + \$1.62',
                  '\$77 + \$2.02',
                  '\$144.5 + \$2.30',
                  '\$230 + \$4.99',
                ];
                final assetNames = [
                  'assets/images/1.png',
                  'assets/images/2.png',
                  'assets/images/3.png',
                  'assets/images/4.png',
                ];

                return VehicleCardNew(
                  title: names[i],
                  price: prices[i],
                  assetName: assetNames[i],
                  selected: _selectedVehicle == i,
                  onTap: () {
                    setState(() => _selectedVehicle = i);
                  },
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          PrimaryButton(
            label: 'Continue',
            onPressed: () {
              if (_selectedVehicle == -1) {
                Get.snackbar(
                  'Vehicle Required',
                  'Please select a vehicle type to continue',
                  backgroundColor: AppColors.accent,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(16.w),
                );
                return;
              }

              // Persist the selected vehicle locally (in-memory) and log for debugging
              final draft = {'selectedVehicleIndex': _selectedVehicle};
              debugPrint('Draft after vehicle select: $draft');

              Get.toNamed(Routes.MOVER_SERVICES, arguments: draft);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return const MoverBookingsView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _navIndex = i),
            children: [
              _buildHomeTab(),
              _buildBookingsTab(),
              const MoverCitiesView(),
              // Ensure mover profile controller exists and show profile view inline
              Builder(
                builder: (context) {
                  if (!Get.isRegistered<MoverProfileController>()) {
                    Get.put(MoverProfileController());
                  }
                  return MoverProfileView();
                },
              ),
            ],
          ),
          const MoverChatbot(),
        ],
      ),
      bottomNavigationBar: MoverBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          _pageController.jumpToPage(i);
        },
      ),
    );
  }
}
