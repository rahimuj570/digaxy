part of 'api_service.dart';

extension AuthApi on ApiService {
  /// Calls: POST /auth/signup/
  ///
  /// Note: This project’s backend expects username/email/password at the
  /// top-level JSON (not nested under a `data` object).
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String role,
  }) {
    return postJson(
      '/auth/signup/',
      body: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  /// Calls: POST /auth/customer/signup/
  ///
  /// Dedicated endpoint for customer (mover) signup with specific validation.
  Future<Map<String, dynamic>> customerSignup({
    required String username,
    required String email,
    required String password,
  }) {
    return postJson(
      '/auth/customer/signup/',
      body: {'username': username, 'email': email, 'password': password},
    );
  }

  /// Calls: POST /auth/driver/signup/
  ///
  /// Dedicated endpoint for driver signup with multipart form-data.
  /// Includes file uploads for license images, NID, passport, and vehicle registration.
  Future<Map<String, dynamic>> driverSignup({
    required String username,
    required String email,
    required String password,
    required String driverLicenseNumber,
    required String driverVehicleNumber,
    String? vehicleType,
    Map<String, String>? files, // field name -> file path
  }) {
    final fields = {
      'username': username,
      'email': email,
      'password': password,
      'driver_license_number': driverLicenseNumber,
      'driver_vehicle_number': driverVehicleNumber,
    };

    if (vehicleType != null && vehicleType.isNotEmpty) {
      fields['vehicle_type'] = vehicleType;
    }

    return postMultipart(
      '/auth/driver/signup/',
      fields: fields,
      files: files ?? {},
    );
  }

  /// Calls: POST /auth/helper/signup/
  ///
  /// Dedicated endpoint for helper signup.
  Future<Map<String, dynamic>> helperSignup({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    String? profilePicture,
  }) {
    return postJson(
      '/auth/helper/signup/',
      body: {
        'username': username,
        'email': email,
        'password': password,
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (profilePicture != null) 'profile_picture': profilePicture,
      },
    );
  }

  /// Calls: GET /auth/helper/profile/me/
  Future<Map<String, dynamic>> getHelperProfile() {
    return getJson('/auth/helper/profile/me/');
  }

  /// Calls: PUT /auth/helper/profile/me/
  Future<Map<String, dynamic>> updateHelperProfile({
    String? username,
    String? fullName,
    String? phoneNumber,
    String? userGender,
    String? dateOfBirth,
  }) {
    return putJson(
      '/auth/helper/profile/me/',
      body: {
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (userGender != null) 'usergender': userGender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      },
    );
  }

  /// Calls: PATCH /auth/helper/profile/me/
  /// Multipart form-data update for helper profile.
  Future<Map<String, dynamic>> updateHelperProfileMultipart({
    String? username,
    String? fullName,
    String? phoneNumber,
    String? userGender,
    String? dateOfBirth,
    String? profilePicturePath,
  }) {
    final fields = <String, String>{
      if (username != null && username.trim().isNotEmpty)
        'username': username.trim(),
      if (fullName != null && fullName.trim().isNotEmpty)
        'full_name': fullName.trim(),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phone_number': phoneNumber.trim(),
      if (userGender != null && userGender.trim().isNotEmpty)
        'usergender': userGender.trim(),
      if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
        'date_of_birth': dateOfBirth.trim(),
    };

    final files = <String, String>{
      if (profilePicturePath != null && profilePicturePath.trim().isNotEmpty)
        'profile_picture': profilePicturePath.trim(),
    };

    return patchMultipart(
      '/auth/helper/profile/me/',
      fields: fields,
      files: files,
    );
  }

  /// Calls: GET /auth/customer/profile/
  Future<Map<String, dynamic>> getCustomerProfile() {
    return getJson('/auth/customer/profile/');
  }

  /// Calls: GET /auth/driver/profile/
  Future<Map<String, dynamic>> getDriverProfile() {
    return getJson('/auth/driver/profile/');
  }

  /// Calls: PATCH /auth/driver/profile/
  /// Multipart form-data update for driver profile.
  Future<Map<String, dynamic>> updateDriverProfileMultipart({
    String? username,
    String? email,
    String? phoneNumber,
    String? vehicleType,
    String? driverVehicleNumber,
    String? profilePicturePath,
  }) {
    final fields = <String, String>{
      if (username != null && username.trim().isNotEmpty)
        'username': username.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phone_number': phoneNumber.trim(),
      if (vehicleType != null && vehicleType.trim().isNotEmpty)
        'vehicle_type': vehicleType.trim(),
      if (driverVehicleNumber != null && driverVehicleNumber.trim().isNotEmpty)
        'driver_vehicle_number': driverVehicleNumber.trim(),
    };

    final files = <String, String>{
      if (profilePicturePath != null && profilePicturePath.trim().isNotEmpty)
        'profile_picture': profilePicturePath.trim(),
    };

    return patchMultipart(
      '/auth/driver/profile/',
      fields: fields,
      files: files,
    );
  }

  /// Calls: PUT /auth/customer/profile/
  Future<Map<String, dynamic>> updateCustomerProfile({
    String? username,
    String? fullName,
    String? phoneNumber,
    String? userGender,
    String? dateOfBirth,
  }) {
    return putJson(
      '/auth/customer/profile/',
      body: {
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (userGender != null) 'usergender': userGender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      },
    );
  }

  /// Calls: PATCH /auth/customer/profile/
  /// Multipart form-data update for customer (mover) profile.
  Future<Map<String, dynamic>> updateCustomerProfileMultipart({
    String? username,
    String? fullName,
    String? phoneNumber,
    String? userGender,
    String? dateOfBirth,
    String? profilePicturePath,
  }) {
    final fields = <String, String>{
      if (username != null && username.trim().isNotEmpty)
        'username': username.trim(),
      if (fullName != null && fullName.trim().isNotEmpty)
        'full_name': fullName.trim(),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phone_number': phoneNumber.trim(),
      if (userGender != null && userGender.trim().isNotEmpty)
        'usergender': userGender.trim(),
      if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
        'date_of_birth': dateOfBirth.trim(),
    };

    final files = <String, String>{
      if (profilePicturePath != null && profilePicturePath.trim().isNotEmpty)
        'profile_picture': profilePicturePath.trim(),
    };

    return patchMultipart(
      '/auth/customer/profile/',
      fields: fields,
      files: files,
    );
  }
}
