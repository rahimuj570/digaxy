import 'dart:async';

import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'new_password_view.dart';
import '../controllers/auth_controller.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final AuthController _authController = Get.find<AuthController>();
  bool _verifying = false;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 30;

  String get _maskedEmail {
    // allow passing email via arguments: Get.arguments['email']
    final arg = Get.arguments is Map ? (Get.arguments as Map)['email'] : null;
    final email = (arg as String?) ?? 'naim....mail.com';
    return email;
  }

  @override
  void initState() {
    super.initState();
    // focus first box when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsLeft = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _onVerify() async {
    if (_code.length < 4) {
      Get.snackbar(
        'Invalid',
        'Please enter the 4-digit code',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final arg = Get.arguments is Map ? (Get.arguments as Map)['email'] : null;
    final email = (arg as String?)?.trim();
    if (email == null || email.isEmpty) {
      Get.snackbar(
        'Missing email',
        'Email is required to verify OTP',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_verifying) return;
    setState(() => _verifying = true);

    try {
      await _authController.verifyOtp(email: email, otp: _code);
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      Get.snackbar(
        'Verification failed',
        e.toString(),
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      if (mounted) setState(() => _verifying = false);
      return;
    }

    // If verification was reached from a forgot-password flow, navigate
    // to the new password screen instead of showing the signup success popup.
    final from = Get.arguments is Map ? (Get.arguments as Map)['from'] : null;
    if (from == 'forgot') {
      if (mounted) setState(() => _verifying = false);
      Get.to(() => const NewPasswordView(), arguments: {'email': email});
      return;
    }

    // Check if user is driver - need special pending dialog
    final box = GetStorage();
    final userRole = (box.read('user_role') as String?)?.toLowerCase();

    if (userRole == 'driver') {
      // For drivers, show pending dialog and navigate to login when closed
      if (mounted) setState(() => _verifying = false);
      _showDriverPendingDialog();
    } else {
      // Non-driver flow: silently login after OTP verification
      final passArg = Get.arguments is Map
          ? (Get.arguments as Map)['password']
          : null;
      final password = (passArg as String?) ?? '';
      if (password.isNotEmpty) {
        try {
          await _authController.login(
            email: email,
            password: password,
            navigate: false,
          );
        } catch (e) {
          debugPrint('Silent login error: $e');
          // Keep UX: still show popup, but user won't be logged-in.
        }
      }

      if (mounted) setState(() => _verifying = false);
      _showSuccessPopup();
    }
  }

  /// Show driver pending application dialog
  void _showDriverPendingDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 320.w,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/welcome_popup.svg',
                        height: 120.h,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Application Under Review',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Your driver application is pending review. We'll notify you once it's approved.",
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 18.h),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'OK',
                          backgroundColor: AppColors.accent,
                          onPressed: () {
                            Get.back();
                            // Navigate to login page
                            Get.offAllNamed(Routes.AUTH_LOGIN);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // success popup
  void _showSuccessPopup() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 320.w,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // placeholder illustration
                      SvgPicture.asset(
                        'assets/icons/welcome_popup.svg',
                        height: 120.h,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Welcome to your logistics partner',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Fast, safe and reliable movement every time.",
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 18.h),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Continue',
                          backgroundColor: AppColors.accent,
                          onPressed: () {
                            Get.back();

                            // If login succeeded, go to role home.
                            final box = GetStorage();
                            final isLoggedIn =
                                (box.read('is_logged_in') as bool?) ?? false;
                            if (!isLoggedIn) return;

                            final role = (box.read('user_role') as String?)
                                ?.toLowerCase();
                            if (role == 'driver') {
                              Get.offAllNamed(Routes.DRIVER_HOME);
                            } else if (role == 'mover') {
                              Get.offAllNamed(Routes.MOVER_HOME);
                            } else if (role == 'helper') {
                              Get.offAllNamed(Routes.HELPER_HOME);
                            } else {
                              Get.offAllNamed(Routes.LANDING_ONBOARDING);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18.w, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0) return;
    final arg = Get.arguments is Map ? (Get.arguments as Map)['email'] : null;
    final email = (arg as String?)?.trim();
    if (email == null || email.isEmpty) {
      Get.snackbar(
        'Missing email',
        'Email is required to resend OTP',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      await _authController.sendOtp(email: email);
      Get.snackbar(
        'Sent',
        'Verification code sent again',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      _startResendTimer();
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      Get.snackbar(
        'Failed',
        e.toString(),
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 18.sp),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: AppColors.accent, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: AppColors.accent, width: 1.8),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        onChanged: (val) {
          if (val.isNotEmpty) {
            if (index < _focusNodes.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
          setState(() {});
        },
      ),
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
              // SizedBox(height: 56.h),
              Spacer(),
              Text(
                'Verify Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'We have sent a code to your Email',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Text(
                _maskedEmail,
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              // visible resend countdown line
              if (_secondsLeft > 0)
                Text(
                  'Resend available in ${_secondsLeft}s',
                  style: TextStyle(color: AppColors.accent, fontSize: 12.sp),
                ),
              SizedBox(height: 50.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) => _otpBox(i)),
              ),
              SizedBox(height: 50.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Verify',
                  backgroundColor: AppColors.accent,
                  onPressed: _onVerify,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(
                      Size(double.infinity, 48.h),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        // still visible on dark background when disabled
                        return Colors.white.withAlpha(20);
                      }
                      return Colors.white;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.white70;
                      }
                      return Colors.black;
                    }),
                    elevation: WidgetStateProperty.all(0),
                  ),
                  onPressed: _secondsLeft == 0 ? _onResend : null,
                  child: Text(
                    'Send Again',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
