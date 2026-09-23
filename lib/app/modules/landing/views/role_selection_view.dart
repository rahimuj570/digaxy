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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
      ),
    );
  }
}
