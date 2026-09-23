import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/notifications/notification_inbox_service.dart';
import 'package:get/get.dart';

class MoverNotificationsController extends GetxController {
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
    final title =
        (raw['title'] ?? raw['message'] ?? raw['body'] ?? 'Notification')
            .toString();
    final subtitle = (raw['subtitle'] ?? raw['description'] ?? '').toString();
    final time = (raw['time'] ?? raw['created_at'] ?? '').toString();
    return {'title': title, 'subtitle': subtitle, 'time': time};
  }
}
