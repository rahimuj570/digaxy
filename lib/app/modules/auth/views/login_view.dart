import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/primary_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
// import '../../../../shared/widgets/social_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  // Use implicit animations instead of a manual AnimationController.
  final Duration _animDuration = const Duration(milliseconds: 450);
  bool _visible = false;
  final controller = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ModalRoute<dynamic>? _modalRoute;
  bool _scopedCallbackAdded = false;

  @override
  void initState() {
    super.initState();
    // Start hidden, then reveal on first frame to trigger implicit animations.
    _visible = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register a scoped will-pop callback on the current ModalRoute so
    // system/back button presses run our exit animation before popping.
    final route = ModalRoute.of(context);
    if (_modalRoute != route) {
      // remove previous if present (only if we successfully added it before)
      if (_scopedCallbackAdded) {
        try {
          _modalRoute?.removeScopedWillPopCallback(_onWillPop);
        } catch (_) {}
        _scopedCallbackAdded = false;
      }

      _modalRoute = route;

      // Try to register the scoped callback; if the API is unavailable on
      // this SDK, fall back to wrapping the widget tree in WillPopScope.
      try {
        _modalRoute?.addScopedWillPopCallback(_onWillPop);
        _scopedCallbackAdded = true;
      } catch (_) {
        // API not available — enable fallback
        _scopedCallbackAdded = false;
      }
    }

    // When the route becomes current again (e.g., returning from SignUp),
    // ensure the entry animation runs by setting `_visible = true`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (isCurrent && !_visible) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    // Remove the scoped callback when the widget is disposed.
    if (_scopedCallbackAdded) {
      try {
        _modalRoute?.removeScopedWillPopCallback(_onWillPop);
      } catch (_) {}
      _scopedCallbackAdded = false;
    }

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing info',
        'Please enter email and password',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      await controller.login(email: email, password: password);
    } on ApiException catch (e) {
      debugPrint('Login error: $e');
      // Check if this is a pending driver application (403)
      if (e.statusCode == 403) {
        _showPendingApplicationDialog(e.message);
      } else {
        Get.snackbar(
          'Login failed',
          e.message,
          backgroundColor: AppColors.accent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      Get.snackbar(
        'Login failed',
        e.toString(),
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _playExitAndNavigate(String route) async {
    setState(() {
      _visible = false;
    });
    await Future.delayed(_animDuration);
    Get.toNamed(route);
  }

  Future<bool> _onWillPop() async {
    // play exit animation then allow pop
    setState(() {
      _visible = false;
    });
    await Future.delayed(_animDuration);
    return true;
  }

  /// Show pending application dialog with message from API
  void _showPendingApplicationDialog(String message) {
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
                        message,
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

  @override
  Widget build(BuildContext context) {
    final role = (GetStorage().read('user_role') as String?)?.toLowerCase();
    final roleLabel = (role != null && role.isNotEmpty)
        ? '${role[0].toUpperCase()}${role.substring(1)}'
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: _animDuration,
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.08),
              duration: _animDuration,
              curve: Curves.easeOut,
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 220.h,
                              child: SvgPicture.asset(
                                'assets/icons/auth_login.svg',
                              ),
                            ),
                          ),
                          if (roleLabel != null) ...[
                            SizedBox(height: 8.h),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 14.sp,
                                      color: AppColors.accent,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Logging in as $roleLabel',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 12.h),
                          Text(
                            'Email',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          PrimaryTextField(
                            controller: _emailController,
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Password',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          PrimaryTextField(
                            controller: _passwordController,
                            hint: 'Enter your password',
                            obscure: true,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: const Icon(Icons.visibility_off),
                          ),
                          SizedBox(height: 4.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed(Routes.AUTH_FORGOT),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: Color(0xFFE3E3E3),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Obx(
                            () => PrimaryButton(
                              label: 'Log In',
                              loading: controller.loading.value,
                              onPressed: controller.loading.value
                                  ? null
                                  : _onLogin,
                            ),
                          ),
                          // SizedBox(height: 12.h),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Divider(
                          //         color: AppColors.textHeadline.withAlpha(140),
                          //         thickness: 1,
                          //       ),
                          //     ),
                          //     SizedBox(width: 12.w),
                          //     Text(
                          //       'OR',
                          //       style: TextStyle(
                          //         color: Color(0xFFE3E3E3),
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 12.sp,
                          //       ),
                          //     ),
                          //     SizedBox(width: 12.w),
                          //     Expanded(
                          //       child: Divider(
                          //         color: AppColors.textHeadline.withAlpha(140),
                          //         thickness: 1,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 12.h),
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: SocialButton(
                          //     svgAsset: 'assets/icons/google_white_logo.svg',
                          //     label: 'Continue with Google',
                          //     onPressed: () {},
                          //     backgroundColor: Colors.white12,
                          //   ),
                          // ),
                          SizedBox(height: 18.h),
                          // already have an account button
                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  _playExitAndNavigate('/auth/signup'),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign up',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
