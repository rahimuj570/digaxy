import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoverPrivacyView extends StatelessWidget {
  const MoverPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: _bulletedList([
            'We collect personal information needed to provide and improve the service.',
            'Information may be used for identity verification, payments and support.',
            'We keep personal data secure and retain it only as long as necessary.',
            'By using the service you agree to collection and use as described.',
            'Replace this placeholder with the final privacy policy text.',
          ]),
        ),
      ),
    );
  }

  Widget _bulletedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((text) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h, right: 8.w),
                child: Text(
                  '•',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.3),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
