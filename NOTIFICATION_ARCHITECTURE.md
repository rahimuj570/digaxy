# Notification System Architecture Diagram

## Complete Notification Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        BACKEND / SERVER                                  │
│          (Sends FCM messages via Firebase Admin SDK)                     │
└─────────────────────────────┬───────────────────────────────────────────┘
                              │
                              │ FCM Message (JSON)
                              │ {
                              │   "to": "device_fcm_token",
                              │   "notification": {
                              │     "title": "Parcel Accepted",
                              │     "body": "Pickup: 123 Main St"
                              │   },
                              │   "data": {
                              │     "parcel_id": "abc123",
                              │     "parcel_numeric_id": "456"
                              │   }
                              │ }
                              ↓
                 ┌────────────────────────┐
                 │  Firebase Cloud        │
                 │  Messaging (FCM)       │
                 │  Infrastructure        │
                 └────────┬───────────────┘
                          │
                          │ Route to device
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ↓               ↓               ↓
    ┌─────────────┐ ┌─────────────┐ ┌──────────────┐
    │ APP OPEN    │ │ APP IN      │ │ APP          │
    │ (FOREGROUND)│ │ BACKGROUND  │ │ TERMINATED   │
    └─────────────┘ └─────────────┘ └──────────────┘
          │               │               │
          ↓               ↓               ↓
    ┌─────────────────────────────────────────────────┐
    │                  OS LEVEL                       │
    │  (Android/iOS Native Notification System)      │
    │                                                 │
    │  ┌─────────────────────────────────────────┐  │
    │  │ Show Native Notification:               │  │
    │  │ • Status bar alert                      │  │
    │  │ • Notification Center/Tray              │  │
    │  │ • Lock screen badge                     │  │
    │  └─────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────┘
                          │
                    User taps notification
                          │
          ┌───────────────┴───────────────┐
          │                               │
          ↓                               ↓
    ┌──────────────────┐         ┌─────────────────┐
    │ APP IN FOREGROUND│         │ APP TERMINATED  │
    │ (already running)│         │ (not running)   │
    └────────┬─────────┘         └────────┬────────┘
             │                            │
             │ FirebaseMessaging.         │ OS launches app,
             │ onMessageOpenedApp         │ then fires callback
             │ fires immediately          │
             │                            │
             ↓                            ↓
    ┌──────────────────────────────────────────────┐
    │     FirebaseNotificationService              │
    │     _handleNotificationTap()                 │
    │                                              │
    │ Extracts:                                    │
    │ • parcel_id                                  │
    │ • parcel_numeric_id                          │
    │                                              │
    │ Navigates to:                                │
    │ /driver/task/active?parcelId=abc123...       │
    └──────────────┬───────────────────────────────┘
                   │
                   ↓
    ┌──────────────────────────────────────────┐
    │     Task Active Screen                   │
    │     Loads and displays parcel details    │
    │     with pickup/dropoff information      │
    └──────────────────────────────────────────┘
```

## Websocket + Firebase Integration

```
┌────────────────────────────────────────────────────────────┐
│                  REAL-TIME UPDATES                          │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  WebSocket (Notifications)                                 │
│  ↓                                                           │
│  NotificationSocketService (connected)                      │
│  ↓                                                           │
│  Receives: {title, subtitle, parcel_id, ...}               │
│  ↓                                                           │
│  NotificationInboxService                                  │
│  • Stores in localStorage (recent notifications)           │
│  • Dedupes consecutive duplicates (within 4sec)            │
│  • Shows in Notifications screen                           │
│  ↓                                                           │
│  FirebaseNotificationService                               │
│  • Displays native OS notification                         │
│  • Handle tap → navigate to parcel                         │
│                                                              │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│              PUSH NOTIFICATIONS (FCM)                        │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  Backend sends FCM message                                 │
│  ↓                                                           │
│  Firebase Cloud Messaging                                  │
│  ↓                                                           │
│  OS Native Notification (even if websocket disconnected)   │
│  ↓                                                           │
│  FirebaseNotificationService                               │
│  • onMessage (foreground)                                  │
│  • onMessageOpenedApp (tap)                                │
│  ↓                                                           │
│  Navigate to correct parcel screen                         │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

## Lifecycle States

```
STATE: APP FOREGROUND
├─ User has app open
│
├─ WebSocket: ✅ Connected
│  └─ Notifications arrive via websocket
│     ├─ Stored in inbox
│     └─ Native notification displayed
│
├─ FCM: ✅ Receives messages
│  └─ onMessage handler fires
│     └─ Native notification displayed
│
└─ Result: User sees native notification while using app


STATE: APP BACKGROUND
├─ User switched to another app
│  (app state paused, not killed)
│
├─ WebSocket: ❓ May be disconnected by OS
│  └─ Notifications might be missed
│
├─ FCM: ✅ Receives messages
│  └─ OS immediately shows in notification center
│
└─ Result: FCM guarantees notification delivery


STATE: APP TERMINATED
├─ App was force-closed or crashed
│  (app process not running)
│
├─ WebSocket: ❌ Not connected
│
├─ FCM: ✅ Receives messages
│  └─ OS queues in notification center
│  └─ App launches when user taps
│  └─ onMessageOpenedApp handler fires
│
└─ Result: User can see notification and tap to launch app


BATTERY SAVER / DOZE MODE
├─ Device conserving power
│
├─ WebSocket: ⚠️ May timeout (OS kills connections)
│
├─ FCM: ✅ High-priority deliverable
│  └─ OS wakes device for FCM messages
│
└─ Result: FCM more reliable in power-saving modes
```

## Error Handling

```
Notification Delivery Failure Scenarios
└─ FCM Server Error
   └─ Automatic retry by Firebase
   └─ Notification eventually delivered or discarded after TTL

└─ Device Offline
   └─ FCM stores message
   └─ Delivers when device comes online

└─ App Crashes During Notification
   └─ Old approach: Snackbar operation crashes
   └─ New approach: FCM just shows OS notification (no app code)

└─ User Disables Notifications
   └─ OS suppresses notification
   └─ Still appears in app's Notifications tab (websocket)

└─ Token Changed
   └─ Backend gets new token
   └─ Old tokens fail (Firebase discards)
   └─ New token used for future messages
```

## Summary

| Scenario       | WebSocket | FCM | Result                             |
| -------------- | --------- | --- | ---------------------------------- |
| App open       | ✅        | ✅  | Native notification + inbox        |
| Background     | ❓        | ✅  | Native notification guaranteed     |
| Terminated     | ❌        | ✅  | OS notification → tap launches app |
| Flight mode    | ❌        | ❌  | Delivers when online               |
| Permission off | ✅        | ✅  | Appears in inbox tab               |
| App crash      | N/A       | ✅  | No crash from FCM (OS handles)     |

## Key Improvements Over Snackbars

| Aspect                 | Snackbars             | FCM Native              |
| ---------------------- | --------------------- | ----------------------- |
| **Crash Risk**         | 🔴 High (GetX UI ops) | 🟢 Zero (OS handles)    |
| **Offline Delivery**   | ❌ No                 | ✅ Yes (queued by OS)   |
| **Background Support** | ❌ Doesn't work       | ✅ Full support         |
| **Throttling**         | ⚠️ Manual             | ✅ Built-in by platform |
| **User UX**            | 🔴 Jarring popups     | 🟢 Native feel          |
| **Accessibility**      | ⚠️ Can block UI       | ✅ Part of system       |
| **Battery Impact**     | ⚠️ Continuous listen  | 🟢 OS optimized         |
| **Production Ready**   | ❌ No                 | ✅ Yes                  |
