# Backend Implementation Plan for Digaxy

Based on `adigarson api.json`, I will implement a **Django** backend with **Django REST Framework (DRF)**.

## 1. Project Structure

- **Project Name**: `digaxy_backend`
- **Location**: `./backend/`
- **Database**: SQLite (default for dev), compatible with PostgreSQL.

## 2. Applications & Models

### A. Authentication (`users` app)

**Endpoints**: `/auth/customer/...`, `/auth/driver/...`, `/helper/...`, `/auth/login`, `/auth/signup`, etc.
**Models**:

- **CustomUser**: Extends standard user with common fields (`email`, `phone_number`, `role`).
- **CustomerProfile**: Specific customer fields.
- **DriverProfile**: `driver_license_number`, `vehicle_number`, `vehicle_type`, `documents` (images).
- **HelperProfile**: Specific helper fields.
  **Features**:
- JWT Authentication (using `simplejwt`).
- OTP Verification (`/auth/otp/send`, `/auth/otp/verify`).
- Password Management (Reset, Change).

### B. Logistics (`logistics` app)

**Endpoints**: `/customer/parcels/...`, `/deal/...`
**Models**:

- **Parcel**:
  - Fields: `pickup_date`, `pickup_address`, `drop_address`, `price`, `vehicle_type`, `parcel_type`, `status` (Pending/cancelled/delivered), `lat/long`.
  - Relations: ForeignKey to `User` (customer).
- **Deal**:
  - Fields: `is_accepted`.
  - Relations: ForeignKey to `Parcel`, ForeignKey to `User` (driver).

### C. Core / Support (`core` app)

**Endpoints**: `/feedback/...`, `/notifications/...`, `/checkout/...`
**Models**:

- **Feedback**: `message`, `rating`, `feedback_type`, `user`.
- **Notification**: `title`, `message`, `is_read`, `user`.
- **Payment**: Basic placeholder for `/checkout/payment/`.

## 3. Technology Stack

- **Framework**: Django 5.x, Django REST Framework.
- **Authentication**: JWT (`djangorestframework-simplejwt`).
- **Documentation**: Swagger/OpenAPI (auto-generated).
- **Media**: Handling image uploads for profile pictures and documents.

## 4. Next Steps

1.  Initialize Django project.
2.  Implement User models and Auth endpoints.
3.  Implement Parcel and Deal models.
4.  Implement Feedback and Notifications.
