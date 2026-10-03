import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/notifications/notification_inbox_service.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    final inbox = Get.isRegistered<NotificationInboxService>()
        ? Get.find<NotificationInboxService>()
        : Get.put(NotificationInboxService(), permanent: true);
    inbox.startListening();

    loadNotifications();
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    try {
      final resp = await api.fetchNotificationsList(page: 1, pageSize: 50);
      final results = resp['results'];
      if (results is List) {
        final remoteItems = results
            .whereType<Map>()
            .map<Map<String, dynamic>>(_mapNotification)
            .toList();

        notifications.assignAll(remoteItems);
      }
    } catch (_) {
      // Keep existing list if remote fetch fails
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _mapNotification(Map raw) {
    final title = (raw['title'] ?? 'Notification').toString().trim().isEmpty
        ? 'Notification'
        : (raw['title'] ?? 'Notification').toString().trim();
    final subtitle = (raw['message'] ??
            raw['subtitle'] ??
            raw['description'] ??
            raw['body'] ??
            '')
        .toString()
        .trim();
    final createdAt = (raw['created_at'] ?? raw['time'] ?? '').toString();
    final time = _formatTime(createdAt);

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
      raw['parcel'],
      dataMap['parcel_id'],
      dataMap['parcelId'],
      dataMap['parcel_uuid'],
      dataMap['parcel'],
    ]);

    final parcelNumericId = extractNumeric([
      raw['parcel_id'],
      raw['parcelId'],
      raw['parcel'],
      raw['parcel_numeric_id'],
      raw['parcel_pk'],
      dataMap['parcel_id'],
      dataMap['parcelId'],
      dataMap['parcel_numeric_id'],
      dataMap['parcel_pk'],
    ]);

    final isRead = raw['is_read'] == true;

    return {
      'id': raw['id'],
      'title': title,
      'subtitle': subtitle,
      'message': subtitle,
      'time': time,
      'created_at_raw': createdAt,
      'parcel_id': parcelId,
      'parcel_numeric_id': parcelNumericId,
      'is_read': isRead,
    };
  }

  String _formatTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';

    try {
      final dt = DateTime.parse(text).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24 && now.day == dt.day) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final min = dt.minute.toString().padLeft(2, '0');
        return '$hour:$min $ampm';
      }
      if (diff.inDays <= 1 || (now.day - dt.day == 1 && diff.inHours < 48)) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final min = dt.minute.toString().padLeft(2, '0');
        return 'Yesterday, $hour:$min $ampm';
      }
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
        'Dec'
      ];
      final month = months[dt.month - 1];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month, $hour:$min $ampm';
    } catch (_) {
      return text;
    }
  }

  void markAllRead() {
    for (var i = 0; i < notifications.length; i++) {
      final updated = Map<String, dynamic>.from(notifications[i]);
      updated['is_read'] = true;
      notifications[i] = updated;
    }
  }
}
