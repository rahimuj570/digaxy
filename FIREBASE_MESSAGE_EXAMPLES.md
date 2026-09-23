// Backend Firebase Message Examples
// Use these examples to send notifications from your backend

// 1. PARCEL ACCEPTED NOTIFICATION
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...", // Device FCM token from your database
"notification": {
"title": "Parcel Accepted ✅",
"body": "Pickup from 123 Main St, Downtown"
},
"data": {
"parcel_id": "p_5f8c2d4e9a1b3c",
"parcel_numeric_id": "1234",
"type": "parcel_accepted",
"action_url": "/driver/task/active"
}
}

// 2. DELIVERY COMPLETED NOTIFICATION
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "Delivery Confirmed 🎉",
"body": "Drop-off at 456 Oak Ave completed successfully"
},
"data": {
"parcel_id": "p_5f8c2d4e9a1b3c",
"parcel_numeric_id": "1234",
"type": "delivery_completed",
"action_url": "/driver/home"
}
}

// 3. PARCEL REASSIGNMENT NOTIFICATION
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "New Parcel Assignment",
"body": "High priority delivery assigned to you"
},
"data": {
"parcel_id": "p_7g9d3e5f0b2c4a",
"parcel_numeric_id": "5678",
"type": "parcel_assigned",
"priority": "high"
}
}

// 4. PICKUP LOCATION UPDATE
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "Pickup Location Update",
"body": "Please confirm pickup address before heading out"
},
"data": {
"parcel_id": "p_5f8c2d4e9a1b3c",
"parcel_numeric_id": "1234",
"type": "pickup_update",
"action": "confirm"
}
}

// 5. URGENT MESSAGE - HIGH PRIORITY
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "⚠️ Urgent - Delivery Issue",
"body": "Customer not available at location. Call support."
},
"data": {
"parcel_id": "p_5f8c2d4e9a1b3c",
"parcel_numeric_id": "1234",
"type": "urgent_alert",
"priority": "high",
"support_number": "+1234567890"
},
"priority": "high" // Send immediately, don't wait for battery optimization
}

// 6. COMMENT FROM CUSTOMER
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "Customer Comment",
"body": "Customer: Please leave package on porch"
},
"data": {
"parcel_id": "p_5f8c2d4e9a1b3c",
"parcel_numeric_id": "1234",
"type": "customer_comment",
"message": "Please leave package on porch"
}
}

// 7. PAYMENT/WITHDRAWAL UPDATE
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "Payment Processed",
"body": "₹250.00 credited for completed deliveries"
},
"data": {
"parcel_id": "",
"parcel_numeric_id": "",
"type": "payment_processed",
"amount": "250.00",
"currency": "INR"
}
}

// 8. DRIVER SUPPORT REQUEST
{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "Support Available",
"body": "Need help? Tap to chat with support"
},
"data": {
"parcel_id": "",
"parcel_numeric_id": "",
"type": "support_available",
"action_url": "/driver/notifications"
}
}

// BACKEND IMPLEMENTATION EXAMPLES

// ============================================
// JAVASCRIPT / NODE.JS EXAMPLE
// ============================================
const admin = require('firebase-admin');

const message = {
notification: {
title: 'Parcel Accepted ✅',
body: 'Pickup from 123 Main St, Downtown'
},
data: {
parcel_id: 'p_5f8c2d4e9a1b3c',
parcel_numeric_id: '1234',
type: 'parcel_accepted'
}
};

// Send to single device
admin.messaging().sendToDevice('DEVICE_FCM_TOKEN', message)
.then(response => {
console.log('Successfully sent message:', response);
})
.catch(error => {
console.log('Error sending message:', error);
});

// Send to multiple devices (topic subscription)
admin.messaging().sendToTopic('drivers', message)
.then(response => {
console.log('Successfully sent message to topic:', response);
});

// ============================================
// PYTHON EXAMPLE
// ============================================
from firebase_admin import credentials, messaging

# Send to single device

message = messaging.Message(
notification=messaging.Notification(
title='Parcel Accepted ✅',
body='Pickup from 123 Main St, Downtown',
),
data={
'parcel_id': 'p_5f8c2d4e9a1b3c',
'parcel_numeric_id': '1234',
'type': 'parcel_accepted',
},
token='DEVICE_FCM_TOKEN',
)

response = messaging.send(message)
print(f'Successfully sent message: {response}')

# ============================================

// C# / .NET EXAMPLE
// ============================================
var message = new Message()
{
Notification = new Notification()
{
Title = "Parcel Accepted ✅",
Body = "Pickup from 123 Main St, Downtown",
},
Data = new Dictionary<string, string>()
{
{ "parcel_id", "p_5f8c2d4e9a1b3c" },
{ "parcel_numeric_id", "1234" },
{ "type", "parcel_accepted" },
},
Token = "DEVICE_FCM_TOKEN",
};

string response = await FirebaseMessaging.DefaultInstance.SendAsync(message);
Console.WriteLine($"Successfully sent message: {response}");

// ============================================
// REST API EXAMPLE (cURL)
// ============================================
curl -X POST https://fcm.googleapis.com/fcm/send \
 -H "Content-Type: application/json" \
 -H "Authorization: key=YOUR_SERVER_API_KEY" \
 -d '{
"to": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...",
"notification": {
"title": "Parcel Accepted ✅",
"body": "Pickup from 123 Main St, Downtown"
},
"data": {
"parcel_id": "p_5f8c2d4e9a1b3c",
"parcel_numeric_id": "1234",
"type": "parcel_accepted"
}
}'

// Get SERVER_API_KEY from Firebase Console:
// Project Settings → Cloud Messaging → Server API Key

// ============================================
// DATABASE SCHEMA FOR FCM TOKENS
// ============================================

-- Users/Drivers Table Addition
ALTER TABLE drivers ADD COLUMN fcm_token VARCHAR(500);
ALTER TABLE drivers ADD COLUMN fcm_token_updated_at TIMESTAMP;

-- Example Query to get driver's token
SELECT fcm_token FROM drivers WHERE driver_id = 'driver_123';

-- Store token when driver logs in (app sends it)
UPDATE drivers SET
fcm_token = 'cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy...',
fcm_token_updated_at = NOW()
WHERE driver_id = 'driver_123';

// ============================================
// API ENDPOINT EXAMPLE
// ============================================

// POST /api/drivers/{driverId}/fcm-token
// Request:
{
"fcm_token": "cUdHCEp3TtiPh5e6kDa:APA91bGkI5WwXGy..."
}

// Response:
{
"success": true,
"message": "FCM token stored"
}

// Then when parcel is accepted:
// 1. Query: SELECT fcm_token FROM drivers WHERE driver_id = ?
// 2. Get token from database
// 3. Send FCM message to that token
// 4. Log delivery status in notifications_log table

// ============================================
// FREQUENCY RECOMMENDATIONS
// ============================================

// 🟢 OK - Can send frequently

- Parcel accepted/assigned
- Delivery completed
- Urgent customer messages
- Payment updates

// 🟡 MODERATE - Send sparingly (max 1-2 per hour)

- Pickup location changes
- Driver motivational messages
- App update notifications

// 🔴 AVOID - Causes battery drain / app uninstalls

- Every second
- Duplicate messages within 5 minutes
- Promotional messages (use in-app instead)
- Testing messages in production (use test devices only)

// ============================================
// MONITORING / DEBUGGING
// ============================================

// Log all sent messages:
{
"timestamp": "2024-01-15T10:30:00Z",
"driver_id": "driver_123",
"fcm_token": "cUdHCEp3TtiPh5e6kDa...",
"message_type": "parcel_accepted",
"parcel_id": "p_5f8c2d4e9a1b3c",
"delivery_status": "sent",
"response_code": 200
}

// Track failures for retry:
{
"timestamp": "2024-01-15T10:30:00Z",
"driver_id": "driver_123",
"fcm_token": "cUdHCEp3TtiPh5e6kDa...",
"failure_reason": "InvalidRegistrationToken",
"action": "refresh_token" // Ask app to send new token
}
