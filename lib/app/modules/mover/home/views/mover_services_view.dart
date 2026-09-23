import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class MoverServicesView extends StatelessWidget {
  const MoverServicesView({super.key});

  Widget _serviceRowWithIcon(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: ListTile(
        onTap: () {
          // Merge previous draft (vehicle) with service selection and log
          final previous = (Get.arguments ?? {}) as Map;
          final payload = {...previous, 'service': label};
          debugPrint('Draft after service select: $payload');

          Get.toNamed(Routes.MOVER_CONTACT_DETAILS, arguments: payload);
        },
        leading: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Icon(icon, size: 20.w, color: AppColors.textSecondary),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Home moving', 'icon': Icons.home},
      {'name': 'Apartment moving', 'icon': Icons.apartment},
      {'name': 'College moving', 'icon': Icons.school},
      {'name': 'Storage moving', 'icon': Icons.inventory_2},
      {'name': 'Office moving', 'icon': Icons.business},
      {'name': 'Furniture delivery', 'icon': Icons.chair},
      {'name': 'FB Marketplace delivery', 'icon': Icons.shopping_bag},
      {'name': 'Application delivery', 'icon': Icons.description},
      {'name': 'Junk removal', 'icon': Icons.delete_outline},
      {'name': 'Donation pick up', 'icon': Icons.volunteer_activism},
      {'name': 'Labor only', 'icon': Icons.handyman},
      {'name': 'Craigslist delivery', 'icon': Icons.local_shipping},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        // show a concise question in the appbar
        title: Text(
          'Services',
          style: TextStyle(
            color: AppColors.textHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6.h),
            Text(
              'Choose the service that fits your move',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (c, i) => _serviceRowWithIcon(
                  c,
                  services[i]['name'] as String,
                  services[i]['icon'] as IconData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
