import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class HelperRegistrationView extends StatefulWidget {
  const HelperRegistrationView({super.key});

  @override
  State<HelperRegistrationView> createState() => _HelperRegistrationViewState();
}

class _HelperRegistrationViewState extends State<HelperRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _skillLifting = false;
  bool _skillLoading = true;

  String? _availability;
  String? _workRadius;

  @override
  void dispose() {
    _nameCtrl.dispose(); 
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Show themed confirmation dialog then navigate back to helper home
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 56.w, color: AppColors.accent),
                SizedBox(height: 12.h),
                Text(
                  'Registration Submitted',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Thank you — we will review your application and contact you soon.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    // Close dialog and go Home
                    Get.back();
                    Get.offAllNamed(Routes.HELPER_HOME);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    String hint, {
    TextEditingController? controller,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28.r),
            borderSide: BorderSide(color: AppColors.accent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28.r),
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
          suffixIcon: suffix,
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Helper Registration Form',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field('Full Name', controller: _nameCtrl),
                _field('Phone Number', controller: _phoneCtrl),
                // ID upload placeholder
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID / Passport Upload',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        Icon(Icons.cloud_upload, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.only(bottom: 18.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photo Upload',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        Icon(Icons.cloud_upload, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 6.h),
                Text(
                  'Select Skills',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _SkillToggle(
                      selected: _skillLifting,
                      label: 'Lifting',
                      onTap: () =>
                          setState(() => _skillLifting = !_skillLifting),
                    ),
                    SizedBox(width: 18.w),
                    _SkillToggle(
                      selected: _skillLoading,
                      label: 'Loading',
                      onTap: () =>
                          setState(() => _skillLoading = !_skillLoading),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),
                // Availability dropdown
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _availability,
                      hint: Text(
                        'Availability',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      style: TextStyle(color: AppColors.textPrimary),
                      items: ['Full time', 'Part time', 'Weekends']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _availability = v),
                      isExpanded: true,
                      dropdownColor: AppColors.background,
                    ),
                  ),
                ),

                // Work radius dropdown
                Container(
                  margin: EdgeInsets.only(bottom: 18.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _workRadius,
                      hint: Text(
                        'Work Radius',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      style: TextStyle(color: AppColors.textPrimary),
                      items: ['5 km', '10 km', '25 km']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _workRadius = v),
                      isExpanded: true,
                      dropdownColor: AppColors.background,
                    ),
                  ),
                ),

                PrimaryButton(
                  label: 'Submit for Registration',
                  onPressed: _submit,
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillToggle extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _SkillToggle({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.accent : Colors.transparent,
              border: Border.all(color: AppColors.accent),
            ),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 12.w,
                    color: selected ? Colors.black : AppColors.accent,
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
