import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:digaxy/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final pass = _passCtrl.text;
    final conf = _confirmCtrl.text;
    final emailArg = Get.arguments is Map
        ? (Get.arguments as Map)['email']
        : null;
    final email = (emailArg as String?)?.trim();

    if (email == null || email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email is required to reset password',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

    if (pass.isEmpty || conf.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter and confirm password',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }
    if (pass != conf) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _authController.resetPassword(
        email: email,
        newPassword: pass,
        confirmPassword: conf,
      );
      Get.snackbar(
        'Success',
        'Password updated',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.AUTH_LOGIN);
    } catch (e) {
      debugPrint('Reset password error: $e');
      Get.snackbar(
        'Failed',
        e.toString(),
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments is Map ? (Get.arguments as Map)['email'] : null;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 36.h),
              Center(
                child: SizedBox(
                  height: 160.h,
                  child: SvgPicture.asset(
                    'assets/icons/auth_signup.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Center(
                child: Text(
                  'Set New Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              if (email != null)
                Center(
                  child: Text(email, style: TextStyle(color: Colors.white70)),
                ),
              SizedBox(height: 18.h),
              Text(
                'New Password',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              PrimaryTextField(
                controller: _passCtrl,
                hint: 'Enter new password',
                obscure: true,
                prefixIcon: Icon(Icons.lock),
              ),
              SizedBox(height: 18.h),
              Text(
                'Confirm Password',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              PrimaryTextField(
                controller: _confirmCtrl,
                hint: 'Confirm password',
                obscure: true,
                prefixIcon: Icon(Icons.lock),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Save',
                  backgroundColor: AppColors.accent,
                  onPressed: _onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
