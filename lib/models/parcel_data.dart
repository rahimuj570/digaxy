/// Model for parcel/job creation request
class ParcelData {
  final String vehicleType;
  final String pickupDate;
  final String pickupTime;
  final String pickupUserName;
  final String pickupPhoneNumber;
  final String pickupAddress;
  final String dropUserName;
  final String dropPhoneNumber;
  final String dropAddress;
  final String price;
  final String? notes;
  final String? specialInstructions;
  final String? parcelType;
  final String? pickupLatitude;
  final String? pickupLongitude;
  final String? dropoffLatitude;
  final String? dropoffLongitude;
  final String? estimatedDistanceKm;
  final String? estimatedTimeMinutes;
  final bool takeHelper;

  ParcelData({
    required this.vehicleType,
    required this.pickupDate,
    required this.pickupTime,
    required this.pickupUserName,
    required this.pickupPhoneNumber,
    required this.pickupAddress,
    required this.dropUserName,
    required this.dropPhoneNumber,
    required this.dropAddress,
    required this.price,
    this.notes,
    this.specialInstructions,
    this.parcelType,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.estimatedDistanceKm,
    this.estimatedTimeMinutes,
    this.takeHelper = false,
  });

  /// Convert to JSON format for API request
  Map<String, dynamic> toJson() {
    return {
      'vehicle_type': vehicleType,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'pickup_user_name': pickupUserName,
      'phone_number': pickupPhoneNumber,
      'pickup_address': pickupAddress,
      'drop_user_name': dropUserName,
      'drop_number': dropPhoneNumber,
      'drop_address': dropAddress,
      'price': price,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (specialInstructions != null && specialInstructions!.isNotEmpty)
        'special_instructions': specialInstructions,
      if (parcelType != null && parcelType!.isNotEmpty)
        'percel_type': parcelType,
      if (pickupLatitude != null && pickupLatitude!.isNotEmpty)
        'ping': pickupLatitude,
      if (pickupLongitude != null && pickupLongitude!.isNotEmpty)
        'pong': pickupLongitude,
      if (dropoffLatitude != null && dropoffLatitude!.isNotEmpty)
        'ding': dropoffLatitude,
      if (dropoffLongitude != null && dropoffLongitude!.isNotEmpty)
        'dong': dropoffLongitude,
      if (estimatedDistanceKm != null && estimatedDistanceKm!.isNotEmpty)
        'estimated_distance_km': estimatedDistanceKm,
      if (estimatedTimeMinutes != null && estimatedTimeMinutes!.isNotEmpty)
        'estimated_time_minutes': estimatedTimeMinutes,
      'take_helper': takeHelper,
    };
  }
}
