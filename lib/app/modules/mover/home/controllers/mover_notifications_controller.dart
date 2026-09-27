import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/notifications/notification_inbox_service.dart';
import 'package:get/get.dart';

class MoverNotificationsController extends GetxController {
  final isLoading = false.obs;
  final recentNotifications = <Map<String, dynamic>>[].obs;
  final previousNotifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final inbox = Get.isRegistered<NotificationInboxService>()
        ? Get.find<NotificationInboxService>()
        : Get.put(NotificationInboxService(), permanent: true);
    inbox.startListening();

    loadNotifications();
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
        final allItems = results
            .whereType<Map>()
            .map<Map<String, dynamic>>(_mapNotification)
            .toList();

        _categorizeNotifications(allItems);
      }
    } catch (_) {
      // Keep existing list on failure
    } finally {
      isLoading.value = false;
    }
  }

  void _categorizeNotifications(List<Map<String, dynamic>> items) {
    final now = DateTime.now();
    final recent = <Map<String, dynamic>>[];
    final previous = <Map<String, dynamic>>[];

    for (final item in items) {
      final rawDate = item['created_at_raw']?.toString();
      DateTime? dt;
      if (rawDate != null && rawDate.isNotEmpty) {
        try {
          dt = DateTime.parse(rawDate).toLocal();
        } catch (_) {}
      }

      // If created today or within the last 24 hours, classify as Recent
      if (dt != null) {
        final diff = now.difference(dt);
        final isToday = dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
        if (isToday || diff.inHours < 24) {
          recent.add(item);
        } else {
          previous.add(item);
        }
      } else {
        recent.add(item);
      }
    }

    recentNotifications.assignAll(recent);
    previousNotifications.assignAll(previous);
  }

  Map<String, dynamic> _mapNotification(Map raw) {
    final id = raw['id'];
    final parcelId = raw['parcel_id'] ?? raw['parcel'];
    final parcelUuid = (raw['parcel_uuid'] ?? '').toString();
    final title = (raw['title'] ?? 'Notification').toString().trim();
    final message = (raw['message'] ?? raw['body'] ?? raw['subtitle'] ?? '')
        .toString()
        .trim();
    final isRead = raw['is_read'] == true;
    final createdAt = (raw['created_at'] ?? '').toString();

    // Extract OTP if present in message or title
    String otp = '';
    final otpMatch = RegExp(r'(?:OTP is|OTP:?)\s*(\d{4,6})', caseSensitive: false)
        .firstMatch('$title $message');
    if (otpMatch != null) {
      otp = otpMatch.group(1) ?? '';
    }

    return {
      'id': id,
      'parcel_id': parcelId,
      'parcel': parcelId,
      'parcel_uuid': parcelUuid,
      'title': title,
      'message': message,
      'is_read': isRead,
      'otp': otp,
      'created_at_raw': createdAt,
      'time': _formatTime(createdAt),
    };
  }

  String _formatTime(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dt.month - 1];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month, $hour:$min $ampm';
    } catch (_) {
      return raw;
    }
  }
}
