import 'package:digaxy/services/api/api_service.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperTaskActiveController extends GetxController {
  final title = 'New Job Assigned!'.obs;
  final subtitle = 'You have been assigned a new delivery task'.obs;
  final isLoading = false.obs;
  final loadError = ''.obs;

  int? parcelNumericId;
  final parcelId = ''.obs;
  final deliveryStatus = ''.obs;

  final pickupAddress = ''.obs;
  final dropoffAddress = ''.obs;
  final scheduledTime = ''.obs;
  final itemType = ''.obs;
  final item = ''.obs;
  final date = ''.obs;
  final distancePay = ''.obs;
  final totalHelperPay = ''.obs;

  final customerName = ''.obs;
  final customerTax = ''.obs;
  final customerPhone = ''.obs;
  final pickupContactName = ''.obs;
  final pickupContactPhone = ''.obs;
  final dropContactName = ''.obs;
  final dropContactPhone = ''.obs;

  final pickupLat = RxnDouble();
  final pickupLng = RxnDouble();
  final dropLat = RxnDouble();
  final dropLng = RxnDouble();

  final vehicleType = ''.obs;
  final notes = ''.obs;
  final specialInstructions = ''.obs;
  final estimatedDistance = ''.obs;
  final estimatedTime = ''.obs;

  final paymentMethod = ''.obs;
  final transactionId = ''.obs;
  final paymentStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['jobId'] != null) title.value = 'New Job Assigned!';
      if (args['pickup'] != null) pickupAddress.value = args['pickup'].toString();
      if (args['dropoff'] != null) dropoffAddress.value = args['dropoff'].toString();
      if (args['customerPhone'] != null) {
        customerPhone.value = args['customerPhone'].toString();
      }
      if (args['customerName'] != null) {
        customerName.value = args['customerName'].toString();
      }

      parcelNumericId = _resolveParcelNumericId(args);
      if (parcelNumericId != null) {
        _loadParcelDetails(parcelNumericId!);
      }
    }
  }

  int? _resolveParcelNumericId(Map args) {
    final candidates = [
      args['parcel_id'],
      args['parcelId'],
      args['parcelNumericId'],
      args['parcel_numeric_id'],
      args['jobId'],
    ];

    for (final value in candidates) {
      final parsed = int.tryParse(value?.toString().trim() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<void> _loadParcelDetails(int id) async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    try {
      isLoading.value = true;
      loadError.value = '';
      final data = await api.fetchParcelDetails(id: id);

      parcelId.value = (data['parcel_id'] ?? data['id'] ?? '').toString();
      deliveryStatus.value = (data['delivery_status'] ?? '').toString();

      pickupAddress.value = (data['pickup_address'] ?? pickupAddress.value).toString();
      dropoffAddress.value = (data['drop_address'] ?? dropoffAddress.value).toString();

      pickupLat.value = _toDouble(data['ping']);
      pickupLng.value = _toDouble(data['pong']);
      dropLat.value = _toDouble(data['ding']);
      dropLng.value = _toDouble(data['dong']);

      pickupContactName.value = (data['pickup_user_name'] ?? '').toString();
      pickupContactPhone.value = (data['phone_number'] ?? '').toString();
      dropContactName.value = (data['drop_user_name'] ?? '').toString();
      dropContactPhone.value = (data['drop_number'] ?? '').toString();

      customerName.value = pickupContactName.value.isNotEmpty
          ? pickupContactName.value
          : customerName.value;
      customerPhone.value = pickupContactPhone.value.isNotEmpty
          ? pickupContactPhone.value
          : (dropContactPhone.value.isNotEmpty
                ? dropContactPhone.value
                : customerPhone.value);

      final pickupDate = (data['pickup_date'] ?? '').toString();
      final pickupTime = (data['pickup_time'] ?? '').toString();
      if (pickupDate.isNotEmpty || pickupTime.isNotEmpty) {
        scheduledTime.value = [
          if (pickupDate.isNotEmpty) pickupDate,
          if (pickupTime.isNotEmpty) pickupTime,
        ].join(' ');
      }

      itemType.value = (data['percel_type'] ?? 'Standard').toString();
      item.value = (data['percel_type'] ?? 'Package').toString();
      date.value = pickupDate.isNotEmpty ? pickupDate : date.value;

      final priceText = (data['price'] ?? '').toString().trim();
      if (priceText.isNotEmpty) {
        final amount = double.tryParse(priceText);
        totalHelperPay.value = amount != null
            ? '\$${amount.toStringAsFixed(2)}'
            : '\$$priceText';
      }

      final estimatedDistanceValue =
          (data['estimated_distance_km'] ?? '').toString().trim();
      estimatedDistance.value = estimatedDistanceValue;
      if (estimatedDistanceValue.isNotEmpty) {
        distancePay.value = '$estimatedDistanceValue km';
      }

      estimatedTime.value = (data['estimated_time_minutes'] ?? '').toString().trim();
      vehicleType.value = (data['vehicle_type'] ?? '').toString();
      notes.value = (data['notes'] ?? '').toString();
      specialInstructions.value =
          (data['special_instructions'] ?? '').toString();

      final payment = (data['payment_method'] ?? '').toString().trim();
      if (payment.isNotEmpty) paymentMethod.value = payment;

      final transaction = (data['transaction_id'] ?? '').toString().trim();
      if (transaction.isNotEmpty) transactionId.value = transaction;

      final payStatus = (data['payment_status'] ?? '').toString().trim();
      if (payStatus.isNotEmpty) paymentStatus.value = payStatus;
    } catch (e) {
      loadError.value = 'Failed to load full task details.';
    } finally {
      isLoading.value = false;
    }
  }

  double? _toDouble(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> callCustomer() async {
    final raw = customerPhone.value.trim();
    if (raw.isEmpty) {
      Get.snackbar('Call', 'Customer phone number is missing');
      return;
    }

    final normalized = _normalizedPhone(raw);
    final telUri = Uri(scheme: 'tel', path: normalized);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar('Call', 'Unable to open dialer for $raw');
  }

  Future<void> messageCustomer() async {
    final raw = customerPhone.value.trim();
    if (raw.isEmpty) {
      Get.snackbar('Message', 'Customer phone number is missing');
      return;
    }

    final normalized = _normalizedPhone(raw);
    final smsUri = Uri(scheme: 'sms', path: normalized);

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar('Message', 'Unable to open messages for $raw');
  }

  String _normalizedPhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}
