// ignore_for_file: unused_local_variable

import 'package:firebase_messaging/firebase_messaging.dart';

/// Local test helper to simulate Firebase notifications
/// Use this during development to test notification display
class NotificationTestHelper {
  static Future<void> sendTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification',
    Map<String, String> data = const {},
  }) async {
    // Create a test remote message
    final remoteMessage = RemoteMessage(
      notification: RemoteNotification(title: title, body: body),
      data: data,
      sentTime: DateTime.now(),
      from: 'test-sender',
      messageId: 'test-${DateTime.now().millisecondsSinceEpoch}',
    );

    print('📬 Sending test notification: $title');
    // In production, this would come from Firebase backend
    // For testing, you can manually trigger the message handler
  }

  /// Test callback that simulates onMessage
  static void simulateIncomingNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) {
    print('📨 [TEST] Simulated incoming notification');
    print('  Title: $title');
    print('  Body: $body');
    if (data != null) print('  Data: $data');
  }
}
