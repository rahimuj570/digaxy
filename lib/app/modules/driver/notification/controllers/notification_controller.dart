import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/notifications/notification_inbox_service.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final recentNotifications = <Map<String, String>>[].obs;
  final notifications = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();

    final inbox = Get.isRegistered<NotificationInboxService>()
        ? Get.find<NotificationInboxService>()
        : Get.put(NotificationInboxService(), permanent: true);
    recentNotifications.assignAll(inbox.recentNotifications);
    recentNotifications.bindStream(inbox.recentNotifications.stream);
    inbox.startListening();

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    try {
      final resp = await api.fetchNotificationsList(page: 1, pageSize: 50);
      final results = resp['results'];
      if (results is List) {
        notifications.assignAll(
          results
              .whereType<Map>()
              .map<Map<String, String>>(_mapNotification)
              .toList(),
        );
      }
    } catch (_) {
      // Keep existing list if fetch fails
    }
  }

  Map<String, String> _mapNotification(Map raw) {
    final title = (raw['title'] ?? 'Notification').toString().trim().isEmpty
        ? 'Notification'
        : (raw['title'] ?? 'Notification').toString();
    final subtitle =
        (raw['message'] ??
                raw['subtitle'] ??
                raw['description'] ??
                raw['body'] ??
                '')
            .toString();
    final time = _formatTime(
      (raw['time'] ?? raw['created_at'] ?? '').toString(),
    );

    final data = raw['data'];
    final dataMap = data is Map ? data : const <String, dynamic>{};

    String extractFirst(List<dynamic> candidates) {
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    String extractNumeric(List<dynamic> candidates) {
      for (final value in candidates) {
        final text = value?.toString().trim() ?? '';
        if (int.tryParse(text) != null) return text;
      }
      return '';
    }

    final parcelId = extractFirst([
      raw['parcel_id'],
      raw['parcelId'],
      dataMap['parcel_id'],
      dataMap['parcelId'],
      dataMap['parcel_uuid'],
      dataMap['parcel'],
    ]);

    final parcelNumericId = extractNumeric([
      raw['parcel_id'],
      raw['parcelId'],
      raw['parcel_numeric_id'],
      dataMap['parcel_id'],
      dataMap['parcelId'],
      dataMap['parcel_numeric_id'],
      dataMap['parcel_pk'],
    ]);

    return {
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'parcel_id': parcelId,
      'parcel_numeric_id': parcelNumericId,
    };
  }

  String _formatTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return 'Now';

    try {
      final dt = DateTime.parse(text).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[dt.month - 1];
      final hour24 = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final amPm = hour24 >= 12 ? 'PM' : 'AM';
      return '$day $month, $hour12:$minute $amPm';
    } catch (_) {
      return text;
    }
  }

  void markAllRead() {
    // placeholder: would mark notifications as read
  }
}
