import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../../../../services/api/api_service.dart';
import 'driver_signup_view.dart';
import 'verify_email_view.dart';
import '../../../../shared/widgets/primary_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
// import '../../../../shared/widgets/social_button.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isHelper = false;

  @override
  void initState() {
    super.initState();
    // Check if user is signing up as driver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
    });
  }

  void _checkUserRole() {
    try {
      final box = GetStorage();
      final role = (box.read('user_role') as String?)?.toLowerCase();
      if (role == 'driver' && mounted) {
        Get.off(() => const DriverSignupView());
      } else if (role == 'helper' && mounted) {
        setState(() {
          _isHelper = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking user role: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing info',
        'Please enter username, email, and password',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      if (_isHelper) {
        await controller.helperSignup(
          username: username,
          email: email,
          password: password,
          fullName: fullName.isNotEmpty ? fullName : null,
          phoneNumber: phone.isNotEmpty ? phone : null,
        );
      } else {
        await controller.signup(
          username: username,
          email: email,
          password: password,
        );
      }
      Get.to(
        () => const VerifyEmailView(),
        arguments: {'email': email, 'password': password},
      );
    } catch (e) {
      // Show full error details in Debug Console.
      debugPrint('Signup error: $e');

      final message = (e is ApiException) ? e.message : e.toString();
      Get.snackbar(
        'Sign up failed',
        message,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                            'assets/icons/auth_signup.svg',
                          ),
                        ),
                      ),

                      // SizedBox(height: 6.h),
                      if (_isHelper) ...[
                        Text(
                          'Full Name',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        PrimaryTextField(
                          key: const ValueKey('full_name_field'),
                          controller: _fullNameController,
                          hint: 'Enter your full name',
                          obscure: false,
                          keyboardType: TextInputType.name,
                          prefixIcon: const Icon(Icons.badge),
                        ),
                        SizedBox(height: 22.h),
                      ],

                      Text(
                        'Username',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      PrimaryTextField(
                        key: const ValueKey('username_field'),
                        controller: _usernameController,
                        hint: 'Enter your username',
                        obscure: false,
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      SizedBox(height: 22.h),
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
                        key: const ValueKey('email_field'),
                        controller: _emailController,
                        hint: 'Enter your email',
                        obscure: false,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      SizedBox(height: 22.h),

                      if (_isHelper) ...[
                        Text(
                          'Phone',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        PrimaryTextField(
                          key: const ValueKey('phone_field'),
                          controller: _phoneController,
                          hint: 'Enter your phone number',
                          obscure: false,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        SizedBox(height: 22.h),
                      ],

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

                      SizedBox(height: 22.h),
                      Obx(
                        () => PrimaryButton(
                          label: 'Sign Up',
                          loading: controller.loading.value,
                          onPressed: controller.loading.value
                              ? null
                              : _onSignup,
                        ),
                      ),
                      // SizedBox(height: 12.h),
                      // // or divider
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
                      //
                      // // login with google button
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: SocialButton(
                      //     svgAsset: 'assets/icons/google_white_logo.svg',
                      //     label: 'Continue with Google',
                      //     onPressed: () {},
                      //     backgroundColor: Colors.white12,
                      //   ),
                      // ),
                      SizedBox(height: 12.h),
                      // already have an account button
                      Center(
                        child: TextButton(
                          onPressed: () => Get.toNamed(Routes.AUTH_LOGIN),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Log In',
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
    );
  }
}
