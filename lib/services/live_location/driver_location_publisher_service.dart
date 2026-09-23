import 'dart:async';

import 'package:digaxy/services/live_location/driver_location_update_socket_service.dart';
import 'package:digaxy/services/live_location/parcel_live_location_socket_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DriverLocationPublisherService extends GetxService {
  final _box = GetStorage();
  StreamSubscription<Position>? _positionSub;
  Timer? _heartbeatTimer;
  bool _started = false;

  final isOnline = true.obs;
  double? _lastLatitude;
  double? _lastLongitude;

  String get currentStatus => isOnline.value ? 'Online' : 'Offline';

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read('driver_is_online') as bool?;
    if (saved != null) {
      isOnline.value = saved;
    }
  }

  Future<void> setOnline(bool online) async {
    isOnline.value = online;
    _box.write('driver_is_online', online);

    final socket = Get.isRegistered<DriverLocationUpdateSocketService>()
        ? Get.find<DriverLocationUpdateSocketService>()
        : Get.put(DriverLocationUpdateSocketService(), permanent: true);

    final status = online ? 'Online' : 'Offline';

    if (_lastLatitude != null && _lastLongitude != null) {
      socket.sendCurrentLocation(
        latitude: _lastLatitude!,
        longitude: _lastLongitude!,
        driverStatus: status,
      );
    } else {
      try {
        final current = await Geolocator.getCurrentPosition();
        _lastLatitude = current.latitude;
        _lastLongitude = current.longitude;
        socket.sendCurrentLocation(
          latitude: current.latitude,
          longitude: current.longitude,
          driverStatus: status,
        );
      } catch (_) {}
    }
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final permissionOk = await _ensureLocationPermission();
    if (!permissionOk) {
      _started = false;
      return;
    }

    final socket = Get.isRegistered<DriverLocationUpdateSocketService>()
        ? Get.find<DriverLocationUpdateSocketService>()
        : Get.put(DriverLocationUpdateSocketService(), permanent: true);
    final parcelSocket = Get.isRegistered<ParcelLiveLocationSocketService>()
        ? Get.find<ParcelLiveLocationSocketService>()
        : Get.put(ParcelLiveLocationSocketService(), permanent: true);

    try {
      final current = await Geolocator.getCurrentPosition();
      _lastLatitude = current.latitude;
      _lastLongitude = current.longitude;
      socket.sendCurrentLocation(
        latitude: current.latitude,
        longitude: current.longitude,
        driverStatus: currentStatus,
      );
      if (isOnline.value) {
        parcelSocket.sendLiveLocation(
          latitude: current.latitude,
          longitude: current.longitude,
        );
      }
    } catch (_) {}

    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen((pos) {
          _lastLatitude = pos.latitude;
          _lastLongitude = pos.longitude;
          socket.sendCurrentLocation(
            latitude: pos.latitude,
            longitude: pos.longitude,
            driverStatus: currentStatus,
          );
          if (isOnline.value) {
            parcelSocket.sendLiveLocation(
              latitude: pos.latitude,
              longitude: pos.longitude,
            );
          }
        });

    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final lat = _lastLatitude;
      final lng = _lastLongitude;
      if (lat != null && lng != null) {
        socket.sendCurrentLocation(
          latitude: lat,
          longitude: lng,
          driverStatus: currentStatus,
        );
        if (isOnline.value) {
          parcelSocket.sendLiveLocation(latitude: lat, longitude: lng);
        }
      }
    });
  }

  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    _heartbeatTimer?.cancel();
    super.onClose();
  }
}
