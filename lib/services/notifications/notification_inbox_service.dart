import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:digaxy/services/notifications/firebase_notification_service.dart';
import 'package:digaxy/services/notifications/notification_socket_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationInboxService extends GetxService {
  static const _storageKey = 'notification_recent_inbox';
  static const _maxItems = 100;

  final _box = GetStorage();
  final recentNotifications = <Map<String, String>>[].obs;

  StreamSubscription<Map<String, String>>? _socketSub;
  StreamSubscription<RemoteMessage?>? _fcmSub;
  bool _started = false;
  String _lastNotificationKey = '';
  DateTime? _lastNotificationAt;

  Future<void> startListening() async {
    if (_started) return;
    _started = true;

    print('📪 Starting notification inbox service...');
    _loadFromStorage();

    // Initialize Firebase notifications (native push)
    final fcmService = Get.isRegistered<FirebaseNotificationService>()
        ? Get.find<FirebaseNotificationService>()
        : Get.put(FirebaseNotificationService(), permanent: true);
    print('📪 Initializing FCM service...');
    await fcmService.initialize();
    print('📪 FCM service initialized');

    _fcmSub = fcmService.onNotificationReceived.stream.listen((message) {
      if (message == null) return;

      final data = message.data;
      _push({
        'title':
            message.notification?.title ??
            data['title']?.toString() ??
            'Notification',
        'subtitle':
            message.notification?.body ?? data['body']?.toString() ?? '',
        'time': 'Now',
        'parcel_id':
            data['parcel_id']?.toString() ?? data['parcelId']?.toString() ?? '',
        'parcel_numeric_id':
            data['parcel_numeric_id']?.toString() ??
            data['parcelId']?.toString() ??
            '',
      });
    });

    // Start listening to websocket notifications (for real-time updates)
    final socket = Get.isRegistered<NotificationSocketService>()
        ? Get.find<NotificationSocketService>()
        : Get.put(NotificationSocketService(), permanent: true);

    try {
      await socket.connect();
    } catch (e) {
      print('❌ Notification websocket connect failed: $e');
    }

    _socketSub = socket.messages.listen((payload) {
      _push(payload);
    });
  }

  void _push(Map<String, String> payload) {
    final normalized = {
      'title': (payload['title'] ?? 'Notification').toString(),
      'subtitle': (payload['subtitle'] ?? '').toString(),
      'time': (payload['time'] ?? 'Now').toString(),
      'parcel_id': (payload['parcel_id'] ?? '').toString(),
      'parcel_numeric_id': (payload['parcel_numeric_id'] ?? '').toString(),
    };

    final dedupeKey = _dedupeKey(normalized);
    if (recentNotifications.isNotEmpty &&
        _dedupeKey(recentNotifications.first) == dedupeKey) {
      return;
    }

    recentNotifications.insert(0, normalized);
    if (recentNotifications.length > _maxItems) {
      recentNotifications.removeRange(_maxItems, recentNotifications.length);
    }
    _persistToStorage();
    _sendNativeNotification(normalized);
  }

  /// Send native OS notification (Android system tray, iOS notification center)
  void _sendNativeNotification(Map<String, String> payload) {
    final title = payload['title']?.trim().isNotEmpty == true
        ? payload['title']!
        : 'Notification';
    final subtitle = payload['subtitle']?.trim() ?? '';
    final notificationKey = _dedupeKey(payload);
    final now = DateTime.now();

    // Dedupe: don't send same notification within 4 seconds
    final recentlyShownSame =
        _lastNotificationKey == notificationKey &&
        _lastNotificationAt != null &&
        now.difference(_lastNotificationAt!).inSeconds < 4;
    if (recentlyShownSame) {
      return;
    }

    try {
      // Firebase messaging automatically displays native notifications
      // This is handled by the FCM service listening to onMessage
      print('📲 Queued native notification: $title - $subtitle');
      _lastNotificationKey = notificationKey;
      _lastNotificationAt = now;
    } catch (e) {
      print('❌ Error sending native notification: $e');
    }
  }

  String _dedupeKey(Map<String, String> payload) {
    return '${payload['parcel_numeric_id'] ?? ''}|${payload['parcel_id'] ?? ''}|${payload['title'] ?? ''}|${payload['subtitle'] ?? ''}|${payload['time'] ?? ''}';
  }

  void _loadFromStorage() {
    final raw = _box.read(_storageKey);
    if (raw is! List) return;

    final restored = raw
        .whereType<Map>()
        .map<Map<String, String>>(
          (item) => {
            'title': (item['title'] ?? 'Notification').toString(),
            'subtitle': (item['subtitle'] ?? '').toString(),
            'time': (item['time'] ?? '').toString(),
            'parcel_id': (item['parcel_id'] ?? '').toString(),
            'parcel_numeric_id': (item['parcel_numeric_id'] ?? '').toString(),
          },
        )
        .toList();

    recentNotifications.assignAll(restored);
  }

  void _persistToStorage() {
    _box.write(_storageKey, recentNotifications.toList());
  }

  @override
  void onClose() {
    _socketSub?.cancel();
    _fcmSub?.cancel();
    super.onClose();
  }
}
