import 'package:digaxy/app/modules/driver/notification/widgets/notification_card.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/live_location/driver_location_update_socket_service.dart';
import 'package:digaxy/services/live_location/parcel_live_location_socket_service.dart';
import 'package:digaxy/services/notifications/notification_socket_service.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  List<Map<String, String>> _mergeNotifications(
    List<Map<String, String>> recent,
    List<Map<String, String>> previous,
  ) {
    final merged = <Map<String, String>>[];
    final seen = <String>{};

    void push(Map<String, String> item) {
      final key =
          '${item['parcel_numeric_id'] ?? ''}|${item['parcel_id'] ?? ''}|${item['title'] ?? ''}|${item['subtitle'] ?? ''}|${item['time'] ?? ''}';
      if (seen.add(key)) {
        merged.add(item);
      }
    }

    for (final item in recent) {
      push(item);
    }
    for (final item in previous) {
      push(item);
    }

    return merged;
  }

  String _statusOf<T extends GetxService>() {
    if (!Get.isRegistered<T>()) return 'not_initialized';
    final service = Get.find<T>();

    if (service is NotificationSocketService) {
      return service.connectionStatus.value;
    }
    if (service is DriverLocationUpdateSocketService) {
      return service.connectionStatus.value;
    }
    if (service is ParcelLiveLocationSocketService) {
      return service.connectionStatus.value;
    }
    return 'unknown';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'connected':
        return Colors.greenAccent;
      case 'connecting':
      case 'reconnecting':
        return Colors.amberAccent;
      case 'error':
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  Widget _socketStatusCard() {
    final notif = _statusOf<NotificationSocketService>();
    final driver = _statusOf<DriverLocationUpdateSocketService>();
    final parcel = _statusOf<ParcelLiveLocationSocketService>();

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: _statusColor(value),
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WebSocket Debug',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          row('Notifications', notif),
          row('Driver Location', driver),
          row('Parcel Live', parcel),
        ],
      ),
    );
  }

  void _openDetails(Map<String, String> item) {
    final parcelId = (item['parcel_id'] ?? '').trim();
    final parcelNumericId = (item['parcel_numeric_id'] ?? '').trim();

    Get.toNamed(
      Routes.DRIVER_TASK_DETAIL,
      arguments: {
        if (parcelId.isNotEmpty) 'parcel_id': parcelId,
        if (parcelNumericId.isNotEmpty) 'parcelNumericId': parcelNumericId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.accent),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Notification',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  final recent = controller.recentNotifications;
                  final previous = controller.notifications;
                  final all = _mergeNotifications(recent, previous);

                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _socketStatusCard(),
                        if (all.isEmpty)
                          NotificationCard(
                            title: 'No notifications',
                            subtitle: 'You are all caught up.',
                            time: '',
                          )
                        else
                          ...all.map(
                            (item) => NotificationCard(
                              title: item['title'] ?? 'Notification',
                              subtitle: item['subtitle'] ?? '',
                              time: item['time'] ?? '',
                              onTap: () => _openDetails(item),
                            ),
                          ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
