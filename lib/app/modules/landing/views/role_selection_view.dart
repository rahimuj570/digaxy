import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../shared/widgets/role_button.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({super.key});

  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _btn1Offset;
  late final Animation<Offset> _btn2Offset;
  late final Animation<Offset> _btn3Offset;
  late final Animation<double> _btn1Fade;
  late final Animation<double> _btn2Fade;
  late final Animation<double> _btn3Fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _btn1Offset = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );
    _btn2Offset = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
          ),
        );
    _btn3Offset = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
          ),
        );

    _btn1Fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5)));
    _btn2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.65)),
    );
    _btn3Fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.8)));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required Animation<Offset> offset,
    required Animation<double> fade,
    bool filled = false,
  }) {
    return SlideTransition(
      position: offset,
      child: FadeTransition(
        opacity: fade,
        child: RoleButton(label: label, onPressed: onTap, filled: filled),
      ),
    );
  }

  Future<void> _selectRole(String role) async {
    final box = GetStorage();
    await box.write('user_role', role);
    // After selecting a role, proceed to login/signup.
    Get.offAllNamed(Routes.AUTH_LOGIN);
  }

  Future<void> _showAbout() async {
    int tapCount = 0;
    DateTime? lastTapTime;

    await showDialog(
      context: context,
      builder: (ctx) {
        bool showDeveloper = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void handleTap() {
              final now = DateTime.now();
              if (lastTapTime == null ||
                  now.difference(lastTapTime!) > const Duration(seconds: 2)) {
                tapCount = 1;
              } else {
                tapCount++;
              }
              lastTapTime = now;

              if (tapCount >= 20 && !showDeveloper) {
                setDialogState(() {
                  showDeveloper = true;
                });
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                  color: AppColors.textHeadline.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.textHeadline,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'About DIGAXY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: handleTap,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIGAXY is an on-demand logistics & moving assistance platform designed to seamlessly connect Movers, Drivers, and Helpers for efficient, reliable services.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (showDeveloper) ...[
                        SizedBox(height: 16.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.textHeadline.withValues(alpha: 0.2),
                                Colors.amber.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.textHeadline,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.code_rounded,
                                    color: AppColors.textHeadline,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Developer Credits',
                                    style: TextStyle(
                                      color: AppColors.textHeadline,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Developed with ❤️ by Rahimuj570',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  SvgPicture.asset(
                    'assets/icons/role_selection.svg',
                    height: 256.h,
                  ),
                  Spacer(),
                  Text(
                    'Join As',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Choose your role to get started with ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextSpan(
                          text: 'DIGAXY',
                          style: TextStyle(
                            color: AppColors.textHeadline,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                            letterSpacing: 4.5,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),

                  // Mover
                  _buildButton(
                    label: 'MOVER',
                    onTap: () => _selectRole('mover'),
                    offset: _btn1Offset,
                    fade: _btn1Fade,
                    filled: false,
                  ),
                  SizedBox(height: 24.h),

                  // Driver
                  _buildButton(
                    label: 'Driver',
                    onTap: () => _selectRole('driver'),
                    offset: _btn2Offset,
                    fade: _btn2Fade,
                    filled: true,
                  ),
                  SizedBox(height: 24.h),

                  // Helper
                  _buildButton(
                    label: 'Helper',
                    onTap: () => _selectRole('helper'),
                    offset: _btn3Offset,
                    fade: _btn3Fade,
                    filled: false,
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
            Positioned(
              top: 8.h,
              right: 16.w,
              child: IconButton(
                onPressed: _showAbout,
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textHeadline,
                  size: 26.sp,
                ),
                tooltip: 'About',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
