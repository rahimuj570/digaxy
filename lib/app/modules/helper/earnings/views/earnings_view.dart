import 'package:digaxy/app/modules/helper/earnings/widgets/earnings_content.dart';
import 'package:digaxy/app/modules/helper/earnings/controllers/earnings_controller.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelperEarningsView extends StatelessWidget {
  const HelperEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available when this view is embedded directly
    if (!Get.isRegistered<HelperEarningsController>()) {
      Get.lazyPut<HelperEarningsController>(() => HelperEarningsController());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Row(
          children: [
            Text(
              'Earnings',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      body: const SafeArea(child: HelperEarningsContent()),
    );
  }
}
