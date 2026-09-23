# Firebase Cloud Messaging Setup Guide

This guide explains how to set up Firebase Cloud Messaging (FCM) for native push notifications in the Digaxy app.

## Overview

The app now uses **Firebase Cloud Messaging (FCM)** instead of in-app snackbars for notifications:

- ✅ **Native system notifications** (Android notification tray, iOS notification center)
- ✅ **No more app crashes** from snackbar operations
- ✅ **Works when app is backgrounded** (iOS/Android native behavior)
- ✅ **Production-ready** notification delivery

## Files Added/Modified

### New Files

- `lib/services/notifications/firebase_notification_service.dart` - FCM initialization and handling
- `lib/firebase_options.dart` - Firebase configuration (needs your project credentials)
- `lib/services/notifications/notification_test_helper.dart` - Test helper for development
- `android/app/google-services.json` - Android Firebase config (needs your values)
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config (needs your values)

### Modified Files

- `pubspec.yaml` - Added `firebase_core` and `firebase_messaging` dependencies
- `lib/main.dart` - Initialize Firebase before app startup
- `lib/services/notifications/notification_inbox_service.dart` - Replaced snackbars with native notifications
- `android/build.gradle.kts` - Added Google Services plugin
- `android/app/build.gradle.kts` - Applied Google Services plugin

## Setup Steps

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select your existing "digaxy" project
3. Enable **Cloud Messaging** in your project settings

### Step 2: Configure Android

#### Get google-services.json

1. In Firebase Console, go to **Project Settings** → **Service Accounts**
2. Download `google-services.json` for your Android app
3. Place it at: `android/app/google-services.json`

#### Update firebase_options.dart (Android Section)

Replace the `android` section with your actual Firebase credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',           // From google-services.json
  appId: '1:YOUR_SENDER_ID:android:YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'digaxy',
  databaseURL: 'https://digaxy.firebaseio.com',
  storageBucket: 'digaxy.appspot.com',
);
```

### Step 3: Configure iOS

#### Get GoogleService-Info.plist

1. In Firebase Console, go to **Project Settings** → **Your Apps** → iOS app
2. Download `GoogleService-Info.plist`
3. Open `ios/Runner.xcworkspace` (not .xcodeproj) in Xcode
4. Drag `GoogleService-Info.plist` into the **Runner** folder
5. Make sure it's added to the **Runner** target

#### Update firebase_options.dart (iOS Section)

Replace the `ios` section with your actual Firebase credentials:

```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: '1:YOUR_SENDER_ID:ios:YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'digaxy',
  databaseURL: 'https://digaxy.firebaseio.com',
  storageBucket: 'digaxy.appspot.com',
  iosBundleId: 'com.nishan.digaxy',
);
```

### Step 4: Install Dependencies

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter pub get
```

### Step 5: Build & Test

#### Android

```bash
flutter run -d android-device
```

#### iOS

```bash
flutter run -d iphone
```

## How It Works

### Architecture

```
Notification Flow:
┌─────────────────────┐
│  Your Backend API   │
│  (Send FCM message) │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Firebase Cloud    │
│    Messaging        │
└──────────┬──────────┘
           │
           ├─→ (Foreground) → FirebaseMessaging.onMessage
           │                  → Native notification + in-app banner
           │
           ├─→ (Background) → System tray
           │
           └─→ (Terminated) → Wake app + handle tap
```

### When App is in Foreground

1. Firebase delivers message to app
2. `FirebaseNotificationService` listens via `FirebaseMessaging.onMessage`
3. Native notification appears in status bar
4. User can tap to navigate to parcel

### When App is in Background

1. Firebase delivers message to device
2. Native notification appears (no app code running)
3. User taps notification
4. App wakes up
5. `FirebaseMessaging.onMessageOpenedApp` triggers navigation

### When App is Terminated

1. Firebase holds notification in queue
2. Native notification appears
3. User taps notification
4. App launches
5. `onMessageOpenedApp` handler navigates to correct parcel

## Sending Notifications from Backend

Your backend should send FCM messages like this:

```json
{
  "to": "FCM_DEVICE_TOKEN",
  "notification": {
    "title": "Parcel Accepted",
    "body": "New delivery: 123 Main St"
  },
  "data": {
    "parcel_id": "abc123xyz",
    "parcel_numeric_id": "456",
    "type": "parcel_accepted"
  }
}
```

## Testing Notifications

### Option 1: Use Firebase Console (Easiest)

1. Go to Firebase Console → Cloud Messaging
2. Send test message
3. Select your device
4. Enter title/body
5. Click Send
   ✓ Notification should appear on device

### Option 2: Use Backend API

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test",
      "body": "Test notification"
    }
  }'
```

### Option 3: Local Testing (Development)

```dart
// In your code:
import 'package:digaxy/services/notifications/notification_test_helper.dart';

// Simulate notification
NotificationTestHelper.simulateIncomingNotification(
  title: 'Parcel Accepted',
  body: 'Pickup from 123 Main St',
  data: {'parcel_numeric_id': '456'},
);
```

## Troubleshooting

### Notifications not showing up?

**Check 1: Verify FCM Token**

```dart
final token = await _messaging.getToken();
print('Your FCM Token: $token');
```

Send this token to your backend for testing.

**Check 2: Verify Permissions (iOS)**

- Settings → Digaxy → Notifications → Allow Notifications

**Check 3: Verify Permissions (Android)**

- Settings → Apps → Digaxy → Notifications → Allow

**Check 4: Check Firebase Console**

- Verify Cloud Messaging is enabled
- Check Cloud Messaging metrics

**Check 5: Check Logcat (Android)**

```bash
flutter logs
```

Look for messages starting with "🔔" or "❌"

**Check 6: Verify google-services.json**

- Must be in `android/app/` directory
- Must contain your project credentials

## FAQ

**Q: Will users see notifications when app is closed?**
A: Yes! Firebase handles this at the OS level. Notifications will appear in the system notification center.

**Q: Can I customize the notification appearance?**
A: Yes. See `firebase_notification_service.dart` → `_handleNotificationTap()` for custom routing.

**Q: What if user doesn't have internet?**
A: FCM queues notifications and delivers them when device comes online.

**Q: Do I need to handle notifications in both channels (websocket + FCM)?**
A: Websocket is for real-time in-app updates. FCM is for system notifications. Both work together now.

## Rollback (if needed)

If you need to go back to snackbars:

1. Revert `notification_inbox_service.dart` to use `Get.showSnackbar()`
2. Remove Firebase dependencies from `pubspec.yaml`
3. Remove Firebase imports from `main.dart`

## Next Steps

1. ✅ Code changes complete
2. ⏳ **YOU DO:** Update `lib/firebase_options.dart` with your project credentials
3. ⏳ **YOU DO:** Download and place `google-services.json` in `android/app/`
4. ⏳ **YOU DO:** Download and place `GoogleService-Info.plist` in `ios/Runner/` (via Xcode)
5. ⏳ **YOU DO:** Run `flutter clean && flutter pub get`
6. ⏳ **YOU DO:** Test on Android and iOS devices
7. ⏳ **YOU DO:** Share FCM token with your backend for push testing

## Production Checklist

- [ ] Firebase project created and FCM enabled
- [ ] google-services.json placed correctly for Android
- [ ] GoogleService-Info.plist added via Xcode for iOS
- [ ] firebase_options.dart updated with real credentials
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App compiles without errors (`flutter build apk`, `flutter build ios`)
- [ ] Notifications tested on real Android device
- [ ] Notifications tested on real iOS device
- [ ] Backend configured to send FCM messages
- [ ] User permissions tested (Android/iOS notification settings)
- [ ] Notification tap navigation works
- [ ] Works with app in foreground, background, and terminated states
