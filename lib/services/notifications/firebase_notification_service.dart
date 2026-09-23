import 'dart:async';
import 'dart:convert';

import 'package:digaxy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Top-level function to handle background messages (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  print(
    '🔔 Background FCM received: ${message.notification?.title ?? message.data['title'] ?? message.data['message'] ?? 'Notification'}',
  );
}

/// Service to handle Firebase Cloud Messaging (FCM) for native push notifications.
class FirebaseNotificationService extends GetxService {
  static const String _androidChannelId = 'digaxy_high_importance_channel';
  static const String _androidChannelName = 'Digaxy Notifications';

  late FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _onMessage;
  StreamSubscription<RemoteMessage>? _onMessageOpenedApp;
  StreamSubscription<String>? _tokenRefreshSub;

  final onNotificationReceived = Rx<RemoteMessage?>(null);
  final onNotificationTapped = Rx<RemoteMessage?>(null);
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      print('🔔 Initializing Firebase Notifications...');
      _messaging = FirebaseMessaging.instance;

      await _initializeLocalNotifications();

      // Request notification permissions for iOS & Android 13+
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('🔔 Notification permission status: ${settings.authorizationStatus}');

      // Enable foreground display options on iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token and store it
      final token = await _messaging.getToken();
      if (token != null) {
        print('🔔 FCM Token: $token');
        GetStorage().write('fcm_token', token);
      }

      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        print('🔔 FCM Token refreshed: $newToken');
        GetStorage().write('fcm_token', newToken);
      });

      // Handle notification when app is launched from terminated state via tap
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('🎯 App opened from terminated state via FCM: ${initialMessage.notification?.title}');
        onNotificationTapped.value = initialMessage;
        _handleNotificationTap(initialMessage);
      }

      // Handle notifications when app is in foreground
      _onMessage = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          '📨 Notification received in foreground: ${message.notification?.title ?? message.data['title'] ?? message.data['message']}',
        );
        onNotificationReceived.value = message;
        _displayNativeNotification(message);
      });

      // Handle notification tap when app is in background
      _onMessageOpenedApp = FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) {
        print('🎯 Notification tapped from background: ${message.notification?.title}');
        onNotificationTapped.value = message;
        _handleNotificationTap(message);
      });

      print('✅ Firebase Notifications initialized successfully');
    } catch (e, st) {
      print('❌ Firebase notification initialization error: $e\n$st');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            if (data is Map<String, dynamic>) {
              _handleNotificationTap(RemoteMessage(data: data));
            }
          } catch (_) {}
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'High importance notifications for Digaxy',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Display native notification in system notification center
  Future<void> _displayNativeNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ??
        data['title']?.toString() ??
        data['notification_title']?.toString() ??
        'New Notification';

    final body = notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        data['subtitle']?.toString() ??
        data['description']?.toString() ??
        '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    print('📲 Displaying native notification: $title - $body');
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'High importance notifications for Digaxy',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle user tapping notification
  void _handleNotificationTap(RemoteMessage message) {
    final parcelId = (message.data['parcel_id'] ?? message.data['parcelId'] ?? '').toString();
    final parcelNumericId = (message.data['parcel_numeric_id'] ?? message.data['parcel_pk'] ?? message.data['parcel_id'] ?? '').toString();

    print('🎯 Handling notification navigation: numeric=$parcelNumericId uuid=$parcelId');

    if (parcelId.isNotEmpty || parcelNumericId.isNotEmpty) {
      Get.toNamed(
        '/driver/task/active',
        arguments: {
          'parcel_id': parcelId,
          'parcel_numeric_id': parcelNumericId,
        },
      );
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        GetStorage().write('fcm_token', token);
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic for batch notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  @override
  void onClose() {
    _onMessage?.cancel();
    _onMessageOpenedApp?.cancel();
    _tokenRefreshSub?.cancel();
    super.onClose();
  }
}
