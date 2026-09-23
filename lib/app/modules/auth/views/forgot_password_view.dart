import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:digaxy/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailCtrl = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _authController.sendOtp(email: email);
    } catch (e) {
      debugPrint('Forgot password send OTP error: $e');
      Get.snackbar(
        'Failed',
        e.toString(),
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

    // navigate to verify page with origin flag
    Get.toNamed(
      Routes.AUTH_VERIFY,
      arguments: {'email': email, 'from': 'forgot'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: SizedBox(
                  height: 180.h,
                  child: SvgPicture.asset(
                    'assets/icons/forgot_illustration.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Forget Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select a method to reset your password',
                style: TextStyle(color: AppColors.accent, fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              PrimaryTextField(
                controller: _emailCtrl,
                hint: 'Code send to your email',
                prefixIcon: Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Next',
                  backgroundColor: AppColors.accent,
                  onPressed: _onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
