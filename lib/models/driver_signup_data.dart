/// Data model for driver signup information
class DriverSignupData {
  final String username;
  final String email;
  final String password;
  final String driverLicenseNumber;
  final String driverVehicleNumber;
  final String? vehicleType; // Car, Bike, Van, Truck, Pickup

  // File paths for documents
  final String? drivingLicenseFrontImage;
  final String? drivingLicenseBackImage;
  final String? driverVehicleRegistrationImage;
  final String? driverNidFrontImage;
  final String? driverNidBackImage;
  final String? driverPassportImage;

  DriverSignupData({
    required this.username,
    required this.email,
    required this.password,
    required this.driverLicenseNumber,
    required this.driverVehicleNumber,
    this.vehicleType,
    this.drivingLicenseFrontImage,
    this.drivingLicenseBackImage,
    this.driverVehicleRegistrationImage,
    this.driverNidFrontImage,
    this.driverNidBackImage,
    this.driverPassportImage,
  });

  /// Convert to API request fields
  Map<String, String> toFields() {
    final fields = {
      'username': username,
      'email': email,
      'password': password,
      'driver_license_number': driverLicenseNumber,
      'driver_vehicle_number': driverVehicleNumber,
    };

    if (vehicleType != null && vehicleType!.isNotEmpty) {
      fields['vehicle_type'] = vehicleType!;
    }

    return fields;
  }

  /// Convert to API request files
  Map<String, String> toFiles() {
    final files = <String, String>{};

    if (drivingLicenseFrontImage != null &&
        drivingLicenseFrontImage!.isNotEmpty) {
      files['driving_license_front_image'] = drivingLicenseFrontImage!;
    }
    if (drivingLicenseBackImage != null &&
        drivingLicenseBackImage!.isNotEmpty) {
      files['driving_license_back_image'] = drivingLicenseBackImage!;
    }
    if (driverVehicleRegistrationImage != null &&
        driverVehicleRegistrationImage!.isNotEmpty) {
      files['driver_vehicle_registration_image'] =
          driverVehicleRegistrationImage!;
    }
    if (driverNidFrontImage != null && driverNidFrontImage!.isNotEmpty) {
      files['driver_nid_front_image'] = driverNidFrontImage!;
    }
    if (driverNidBackImage != null && driverNidBackImage!.isNotEmpty) {
      files['driver_nid_back_image'] = driverNidBackImage!;
    }
    if (driverPassportImage != null && driverPassportImage!.isNotEmpty) {
      files['driver_passport_image'] = driverPassportImage!;
    }

    return files;
  }
}
