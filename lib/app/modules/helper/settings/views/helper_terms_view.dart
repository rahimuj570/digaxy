import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelperTermsView extends StatelessWidget {
  const HelperTermsView({super.key});
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
          'Terms & Condition',
          style: TextStyle(color: AppColors.textHeadline),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: _bulletedList([
            'These Terms govern your access to and use of the platform.',
            'Users must comply with local laws and not misuse the service.',
            'We may update terms and notify users of significant changes.',
            'This is placeholder text — replace with final legal copy later.',
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
