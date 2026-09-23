import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/live_location/parcel_live_location_socket_service.dart';

class TaskDetailController extends GetxController {
  final title = 'Task Details'.obs;
  final assignedAt = ''.obs;
  final deliveryId = ''.obs;
  final isLoading = false.obs;
  final isConfirming = false.obs;
  final isTrackMode = false.obs;
  final showActionButton = true.obs;
  final loadError = ''.obs;
  int? _parcelIdForConfirm;
  bool _forceTrackMode = false;
  bool _fromCompletedSource = false;

  final pickupAddress = ''.obs;
  final dropoffAddress = ''.obs;
  final pickupContactName = ''.obs;
  final pickupContactPhone = ''.obs;
  final dropContactName = ''.obs;
  final dropContactPhone = ''.obs;
  final parcelStatus = ''.obs;
  final pickupDate = ''.obs;
  final pickupTime = ''.obs;
  final pickupLat = RxnDouble();
  final pickupLng = RxnDouble();
  final dropLat = RxnDouble();
  final dropLng = RxnDouble();

  final items = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _fromCompletedSource = args['fromCompleted'] == true;
      _forceTrackMode = args['fromAccepted'] == true;
      isTrackMode.value = _forceTrackMode;
      showActionButton.value = !_fromCompletedSource;
      final parcelNumericId = _resolveParcelNumericId(args);
      if (parcelNumericId != null) {
        _loadParcelDetails(parcelNumericId);
      } else {
        loadError.value = 'Parcel id not found in notification data.';
      }
    } else {
      loadError.value = 'Parcel id not found in notification data.';
    }
  }

  int? _resolveParcelNumericId(Map args) {
    final candidates = [
      args['parcel_id'],
      args['parcelId'],
      args['parcelNumericId'],
      args['parcel_numeric_id'],
    ];

    for (final value in candidates) {
      final parsed = int.tryParse(value?.toString().trim() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<void> _loadParcelDetails(int parcelId) async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    try {
      isLoading.value = true;
      loadError.value = '';
      final data = await api.fetchParcelDetails(id: parcelId);

      _parcelIdForConfirm =
          _resolveParcelNumericId({'parcel_id': data['parcel_id']}) ?? parcelId;

      title.value = 'Task - Parcel #$parcelId';
      deliveryId.value = (data['parcel_id'] ?? data['id'] ?? '').toString();

      final createdAt = (data['created_at'] ?? '').toString();
      assignedAt.value = createdAt.isNotEmpty
          ? 'Assigned at ${_formatDateTime(createdAt)}'
          : '';

      pickupAddress.value = (data['pickup_address'] ?? '').toString();
      dropoffAddress.value = (data['drop_address'] ?? '').toString();

      pickupLat.value = _toDouble(data['ping']);
      pickupLng.value = _toDouble(data['pong']);
      dropLat.value = _toDouble(data['ding']);
      dropLng.value = _toDouble(data['dong']);

      pickupContactName.value = (data['pickup_user_name'] ?? '').toString();
      pickupContactPhone.value = (data['phone_number'] ?? '').toString();
      dropContactName.value = (data['drop_user_name'] ?? '').toString();
      dropContactPhone.value = (data['drop_number'] ?? '').toString();

      parcelStatus.value = (data['delivery_status'] ?? '').toString();
      final completedByStatus = _isCompletedStatus(parcelStatus.value);
      if (_fromCompletedSource || completedByStatus) {
        showActionButton.value = false;
        isTrackMode.value = false;
      }
      if (!_forceTrackMode && showActionButton.value) {
        isTrackMode.value = _shouldTrackByStatus(parcelStatus.value);
      }
      pickupDate.value = (data['pickup_date'] ?? '').toString();
      pickupTime.value = (data['pickup_time'] ?? '').toString();

      final estimatedDistance = (data['estimated_distance_km'] ?? '')
          .toString()
          .trim();
      final estimatedTime = (data['estimated_time_minutes'] ?? '')
          .toString()
          .trim();

      items.assignAll([
        if (parcelStatus.value.trim().isNotEmpty)
          'Status: ${parcelStatus.value}',
        if (pickupDate.value.trim().isNotEmpty)
          'Pickup Date: ${pickupDate.value}',
        if (pickupTime.value.trim().isNotEmpty)
          'Pickup Time: ${pickupTime.value}',
        if ((data['percel_type'] ?? '').toString().trim().isNotEmpty)
          'Type: ${(data['percel_type']).toString()}',
        if ((data['vehicle_type'] ?? '').toString().trim().isNotEmpty)
          'Vehicle: ${(data['vehicle_type']).toString()}',
        if ((data['price'] ?? '').toString().trim().isNotEmpty)
          'Price: ${(data['price']).toString()}',
        if (estimatedDistance.isNotEmpty)
          'Estimated Distance: $estimatedDistance km',
        if (estimatedTime.isNotEmpty) 'Estimated Time: $estimatedTime min',
        if ((data['notes'] ?? '').toString().trim().isNotEmpty)
          'Notes: ${(data['notes']).toString()}',
        if ((data['special_instructions'] ?? '').toString().trim().isNotEmpty)
          'Special Instructions: ${(data['special_instructions']).toString()}',
      ]);
    } catch (e) {
      loadError.value = 'Failed to load parcel details.';
      debugPrint('Failed to load parcel details: $e');
      title.value = 'Task Details';
      assignedAt.value = '';
      deliveryId.value = '';
      pickupAddress.value = '';
      dropoffAddress.value = '';
      pickupLat.value = null;
      pickupLng.value = null;
      dropLat.value = null;
      dropLng.value = null;
      pickupContactName.value = '';
      pickupContactPhone.value = '';
      dropContactName.value = '';
      dropContactPhone.value = '';
      parcelStatus.value = '';
      pickupDate.value = '';
      pickupTime.value = '';
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  bool _shouldTrackByStatus(String status) {
    final normalized = status
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .trim();
    return normalized == 'onway' ||
        normalized == 'on_the_way' ||
        normalized == 'delivered' ||
        normalized == 'completed' ||
        normalized == 'picked_up' ||
        normalized == 'pickup_done';
  }

  bool _isCompletedStatus(String status) {
    final normalized = status
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .trim();
    return normalized == 'delivered' || normalized == 'completed';
  }

  String _formatDateTime(String raw) {
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final year = parsed.year.toString();
      final hour24 = parsed.hour;
      final minute = parsed.minute.toString().padLeft(2, '0');
      final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final suffix = hour24 >= 12 ? 'PM' : 'AM';
      return '$day/$month/$year $hour12:$minute $suffix';
    } catch (_) {
      return raw;
    }
  }

  double? _toDouble(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void confirmTask() {
    if (isTrackMode.value) {
      goToTrack();
      return;
    }
    _confirmTaskInternal();
  }

  void goToTrack() {
    final parcelNumericIdText = (_parcelIdForConfirm ?? 0).toString();
    final parcelUuid = deliveryId.value.trim();
    Get.toNamed(
      Routes.DRIVER_TASK_LIVE,
      arguments: {
        if (parcelNumericIdText != '0') 'parcelId': parcelNumericIdText,
        if (parcelUuid.isNotEmpty) 'parcel_id': parcelUuid,
        if (deliveryId.value.isNotEmpty) 'jobId': deliveryId.value,
        'pickup': pickupAddress.value,
        'dropoff': dropoffAddress.value,
        if (pickupLat.value != null) 'pickupLat': pickupLat.value,
        if (pickupLng.value != null) 'pickupLng': pickupLng.value,
        if (dropLat.value != null) 'dropLat': dropLat.value,
        if (dropLng.value != null) 'dropLng': dropLng.value,
        'customerName': pickupContactName.value,
      },
    );
  }

  Future<void> _confirmTaskInternal() async {
    if (isConfirming.value) return;

    final parcelId = _parcelIdForConfirm;
    if (parcelId == null) {
      AppSnackbar.error(
        'Error',
        'parcel_id is missing. Unable to confirm task.',
      );
      return;
    }

    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    try {
      isConfirming.value = true;
      await api.submitDealAcceptance(parcelId: parcelId, isAccepted: true);

      final parcelSocket = Get.isRegistered<ParcelLiveLocationSocketService>()
          ? Get.find<ParcelLiveLocationSocketService>()
          : Get.put(ParcelLiveLocationSocketService(), permanent: true);
      try {
        await parcelSocket.connect(parcelId: parcelId.toString());
      } catch (_) {}

      AppSnackbar.success('Confirmed', 'Task accepted successfully.');

      Get.toNamed(
        Routes.DRIVER_TASK_ACTIVE,
        arguments: {
          'jobId': deliveryId.value,
          'parcel_id': parcelId.toString(),
          'pickup': pickupAddress.value,
          'dropoff': dropoffAddress.value,
          'customerName': pickupContactName.value,
          'customerPhone': pickupContactPhone.value,
        },
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to confirm task. Please try again.');
      debugPrint('Failed to confirm task: $e');
    } finally {
      isConfirming.value = false;
    }
  }
}
