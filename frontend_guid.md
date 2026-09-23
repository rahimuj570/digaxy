# Frontend Integration Guide

## Authentication

Use the JWT access token returned by the login API for REST requests:

```http
Authorization: Bearer <access_token>
```

WebSocket authentication accepts the same token either as a query parameter or as an Authorization header. The query parameter is recommended for mobile clients:

```text
wss://<host>/ws/notifications/?token=<access_token>
wss://<host>/ws/user/current/location/?token=<access_token>
```

## Driver location and availability

Every driver or helper must connect to `/ws/user/current/location/` and send a location update after connecting and whenever the device location changes:

```json
{
  "latitude": 23.8103,
  "longitude": 90.4125,
  "driver_status": "Online"
}
```

Valid statuses are `Online` and `Offline`. A driver is eligible for nearby parcel matching only when:

- the user role is `Driver`;
- `driver_status` is `Online`;
- both location coordinates are present; and
- the driver is within 10 km of the parcel pickup coordinates.

The server replies with `location_update_ack` after a successful update. Keep the connection alive and send a fresh location when the driver moves.

## Driver notifications

Connect to `/ws/notifications/` before creating or accepting work. The server sends:

```json
{
  "type": "new_parcel_notification",
  "parcel_id": 12,
  "parcel_uuid": "...",
  "pickup_location": {"latitude": 23.8103, "longitude": 90.4125},
  "drop_location": {"latitude": 23.7806, "longitude": 90.4070},
  "pickup_address": "...",
  "drop_address": "...",
  "vehicle_type": "Van",
  "parcel_type": "Medium",
  "price": "250.00"
}
```

The notification is also stored in the database. Therefore, the app should load the driver's notification list on startup and use the WebSocket for real-time updates. If the driver was offline when an order was created, the backend re-checks nearby open parcels when the driver reconnects and submits a location update.

## Accepting a parcel and live tracking

The nearby parcel notification does not assign the parcel to the driver. The driver must first accept it:

```http
POST /api/deal/accept/list/create/
Authorization: Bearer <access_token>
Content-Type: application/json
```

```json
{"parcel": 2}
```

Use the numeric database `id` from the notification's `parcel_id` field. After the API returns `201`, the parcel is assigned to that driver and its status becomes `Accepted`. Only then should the app open the parcel live-location socket:

```text
wss://<host>/ws/live/location/<parcel_id>/?token=<access_token>
```

Send location updates on that socket only after assignment:

```json
{
  "latitude": 37.421998,
  "longitude": -122.084000
}
```

The live-location socket is for an assigned parcel, not for discovering nearby orders. Before acceptance it returns `PARCEL_NOT_ASSIGNED`; use `/ws/notifications/` for new delivery opportunities.

## Customer parcel flow

Create a parcel with pickup and drop coordinates:

```http
POST /api/customer/parcels/create/
```

The required pickup coordinate fields are `ping` (latitude) and `pong` (longitude). Drop coordinates are `ding` and `dong`.

After delivery, start payment with:

```http
POST /api/checkout/payment/
```

```json
{"parcel_id": "<parcel_uuid>"}
```

Open the returned `checkout_url` in the mobile browser or an in-app browser. Do not mark payment as successful from the success URL. The backend marks payment successful only after receiving and verifying the Stripe webhook at:

```text
POST /api/webhook/stripe/
```

## WebSocket client example

```javascript
const token = accessToken;
const notifications = new WebSocket(
  `wss://${host}/ws/notifications/?token=${encodeURIComponent(token)}`
);
const location = new WebSocket(
  `wss://${host}/ws/user/current/location/?token=${encodeURIComponent(token)}`
);

location.onopen = () => {
  location.send(JSON.stringify({
    latitude: 23.8103,
    longitude: 90.4125,
    driver_status: "Online"
  }));
};

notifications.onmessage = (event) => {
  const message = JSON.parse(event.data);
  if (message.type === "new_parcel_notification") {
    // Update the driver's delivery opportunity list.
  }
};
```

Use `wss://` in production and `ws://` only for local development. Close both sockets on logout and send `driver_status: "Offline"` before disconnecting when possible.