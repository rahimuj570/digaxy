import 'package:digaxy/services/live_location/driver_location_update_socket_service.dart';
import 'package:digaxy/services/live_location/driver_location_publisher_service.dart';
import 'package:digaxy/services/live_location/parcel_live_location_socket_service.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/notifications/notification_inbox_service.dart';
import 'package:digaxy/services/notifications/notification_socket_service.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WebSocketBootstrapService extends GetxService {
  final _box = GetStorage();
  StreamSubscription<Map<String, String>>? _notificationSub;

  Future<void> connectForAuthenticatedUser() async {
    final isLoggedIn = (_box.read('is_logged_in') as bool?) ?? false;
    if (!isLoggedIn) return;

    final notificationSocket = Get.isRegistered<NotificationSocketService>()
        ? Get.find<NotificationSocketService>()
        : Get.put(NotificationSocketService(), permanent: true);
    try {
      await notificationSocket.connect();
    } catch (_) {}

    final inbox = Get.isRegistered<NotificationInboxService>()
        ? Get.find<NotificationInboxService>()
        : Get.put(NotificationInboxService(), permanent: true);
    try {
      await inbox.startListening();
    } catch (_) {}

    final role = (_box.read('user_role') as String?)?.toLowerCase();
    if (role == 'driver' || role == 'helper') {
      final driverLocationSocket =
          Get.isRegistered<DriverLocationUpdateSocketService>()
          ? Get.find<DriverLocationUpdateSocketService>()
          : Get.put(DriverLocationUpdateSocketService(), permanent: true);
      try {
        await driverLocationSocket.connect();
      } catch (_) {}

      final locationPublisher =
          Get.isRegistered<DriverLocationPublisherService>()
          ? Get.find<DriverLocationPublisherService>()
          : Get.put(DriverLocationPublisherService(), permanent: true);
      try {
        await locationPublisher.start();
      } catch (_) {}

      try {
        await _connectAcceptedParcelLiveSocket();
      } catch (_) {}

      _notificationSub ??= notificationSocket.messages.listen((payload) {
        final parcelId = _extractParcelIdFromNotification(payload);
        if (parcelId == null || parcelId.isEmpty) return;

        final parcelSocket = Get.isRegistered<ParcelLiveLocationSocketService>()
            ? Get.find<ParcelLiveLocationSocketService>()
            : Get.put(ParcelLiveLocationSocketService(), permanent: true);

        parcelSocket.connect(parcelId: parcelId).catchError((_) {});
      });
    }
  }

  String? _extractParcelIdFromNotification(Map<String, String> payload) {
    final parcelNumeric = (payload['parcel_numeric_id'] ?? '').trim();
    if (parcelNumeric.isNotEmpty) return parcelNumeric;

    final parcelId = (payload['parcel_id'] ?? '').trim();
    if (parcelId.isNotEmpty) return parcelId;

    return null;
  }

  Future<void> _connectAcceptedParcelLiveSocket() async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : Get.put(ApiService(), permanent: true);

    final response = await api.fetchAcceptedParcels(page: 1, pageSize: 1);
    final parcelId = _extractFirstAcceptedParcelId(response);
    if (parcelId == null || parcelId.isEmpty) return;

    final parcelSocket = Get.isRegistered<ParcelLiveLocationSocketService>()
        ? Get.find<ParcelLiveLocationSocketService>()
        : Get.put(ParcelLiveLocationSocketService(), permanent: true);

    await parcelSocket.connect(parcelId: parcelId);
  }

  String? _extractFirstAcceptedParcelId(Map<String, dynamic> response) {
    final payload = (response['data'] is Map<String, dynamic>)
        ? (response['data'] as Map<String, dynamic>)
        : response;

    final listCandidates = [
      payload['results'],
      payload['parcels'],
      payload['items'],
      payload['data'],
    ];

    for (final candidate in listCandidates) {
      if (candidate is List && candidate.isNotEmpty) {
        final first = candidate.first;
        if (first is Map) {
          final parcelId =
              (first['parcel_id'] ?? first['id'] ?? first['parcel'])
                  ?.toString()
                  .trim();
          if (parcelId != null && parcelId.isNotEmpty) return parcelId;
        }
      }
    }

    final directId =
        (payload['parcel_id'] ?? payload['id'] ?? payload['parcel'])
            ?.toString()
            .trim();
    if (directId != null && directId.isNotEmpty) return directId;

    return null;
  }

  @override
  void onClose() {
    _notificationSub?.cancel();
    _notificationSub = null;
    super.onClose();
  }
}
