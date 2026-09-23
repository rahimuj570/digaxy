import 'dart:async';
import 'dart:convert';

import 'package:digaxy/shared/api_keys.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/live_location/driver_location_update_socket_service.dart';
import 'package:digaxy/services/live_location/parcel_live_location_socket_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class TaskLiveController extends GetxController {
  final title = 'Live Movement'.obs;
  final from = ''.obs;
  final to = ''.obs;
  final distance = '--'.obs;
  final eta = '--'.obs;
  final customerName = ''.obs;
  final customerTax = 'TAX 2345'.obs;

  final pickupAddress = ''.obs;
  final dropoffAddress = ''.obs;
  final parcelId = ''.obs;
  final parcelNumericId = RxnInt();

  final pickupLat = RxnDouble();
  final pickupLng = RxnDouble();
  final dropLat = RxnDouble();
  final dropLng = RxnDouble();
  final currentLat = RxnDouble();
  final currentLng = RxnDouble();

  final isPickedUp = false.obs;
  final pickupPhotoPath = ''.obs;
  final dropoffPhotoPath = ''.obs;
  final isSubmittingPickup = false.obs;
  final isSubmittingDropoff = false.obs;

  final navigationHint = 'Navigating to pickup point'.obs;
  final currentLocationLabel = 'Waiting location permission...'.obs;
  final trackingLocationLabel = 'Waiting tracking stream...'.obs;
  final routePoints = <LatLng>[].obs;
  final isLoadingRoute = false.obs;
  final isMapFullscreen = false.obs;

  DateTime? _lastRouteFetchAt;

  final ImagePicker _imagePicker = ImagePicker();

  Timer? _locationTicker;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<Map<String, dynamic>>? _driverSocketSub;
  StreamSubscription<ParcelLiveLocation>? _trackingSub;

  late final ApiService _api;
  late final DriverLocationUpdateSocketService _driverSocket;
  late final ParcelLiveLocationSocketService _trackingSocket;

  @override
  void onInit() {
    super.onInit();

    _api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    _driverSocket = Get.isRegistered<DriverLocationUpdateSocketService>()
        ? Get.find<DriverLocationUpdateSocketService>()
        : Get.put(DriverLocationUpdateSocketService(), permanent: true);

    _trackingSocket = Get.isRegistered<ParcelLiveLocationSocketService>()
        ? Get.find<ParcelLiveLocationSocketService>()
        : Get.put(ParcelLiveLocationSocketService(), permanent: true);

    final args = Get.arguments;
    if (args is Map) {
      if (args['pickup'] != null) pickupAddress.value = '${args['pickup']}';
      if (args['dropoff'] != null) dropoffAddress.value = '${args['dropoff']}';
      if (args['customerName'] != null) {
        customerName.value = '${args['customerName']}';
      }
      final parsedId =
          (args['parcel_id'] ?? args['parcelId'] ?? args['jobId'] ?? '')
              .toString()
              .trim();
      if (parsedId.isNotEmpty) {
        parcelId.value = parsedId;
      }

      final numericId = int.tryParse((args['parcelId'] ?? '').toString());
      if (numericId != null) {
        parcelNumericId.value = numericId;
      }

      pickupLat.value = _toDouble(args['pickupLat']);
      pickupLng.value = _toDouble(args['pickupLng']);
      dropLat.value = _toDouble(args['dropLat']);
      dropLng.value = _toDouble(args['dropLng']);

      final pickedFlag = args['isPickedUp'];
      if (pickedFlag is bool) {
        isPickedUp.value = pickedFlag;
      } else {
        final statusText = (args['deliveryStatus'] ?? '')
            .toString()
            .toLowerCase()
            .replaceAll('-', '_')
            .replaceAll(' ', '_');
        if (statusText == 'on_the_way' ||
            statusText == 'onway' ||
            statusText == 'picked_up' ||
            statusText == 'pickup_done') {
          isPickedUp.value = true;
        }
      }
    }

    from.value = pickupAddress.value;
    to.value = dropoffAddress.value;

    _refreshRoute(force: true);

    _connectSockets();
    _startLocationTracking();
  }

  void _connectSockets() {
    try {
      _driverSocket.connect();
    } catch (e) {
      currentLocationLabel.value = 'Driver socket connection failed';
    }
    _driverSocketSub = _driverSocket.messages.listen((message) {
      final status = message['message']?.toString();
      if (status != null && status.isNotEmpty) {
        currentLocationLabel.value = status;
      }
    });

    if (parcelId.value.isNotEmpty) {
      try {
        _trackingSocket.connect(parcelId: parcelId.value);
      } catch (e) {
        trackingLocationLabel.value = 'Tracking socket connection failed';
      }
      _trackingSub = _trackingSocket.updates.listen((event) {
        final lat = event.latitude;
        final lng = event.longitude;
        if (lat != null && lng != null) {
          trackingLocationLabel.value =
              'Tracked: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
        } else if (event.message != null && event.message!.isNotEmpty) {
          trackingLocationLabel.value = event.message!;
        }
      });
    } else {
      trackingLocationLabel.value = 'No parcel id for live tracking socket';
    }
  }

  Future<void> _startLocationTracking() async {
    final position = await _getCurrentPosition();
    if (position != null) {
      _applyCurrentPosition(position.latitude, position.longitude);
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (pos) {
            _applyCurrentPosition(pos.latitude, pos.longitude);
          },
        );

    _locationTicker?.cancel();
    _pushCurrentLocation();
    _locationTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      _pushCurrentLocation();
    });
  }

  void _applyCurrentPosition(double lat, double lng) {
    currentLat.value = lat;
    currentLng.value = lng;
    _updateDistanceAndHint();
    _refreshRoute();
  }

  void _updateDistanceAndHint() {
    final lat = currentLat.value;
    final lng = currentLng.value;
    if (lat == null || lng == null) {
      distance.value = '--';
      eta.value = '--';
      return;
    }

    final targetLat = isPickedUp.value ? dropLat.value : pickupLat.value;
    final targetLng = isPickedUp.value ? dropLng.value : pickupLng.value;

    if (targetLat == null || targetLng == null) {
      distance.value = '--';
      eta.value = '--';
      navigationHint.value = isPickedUp.value
          ? 'Navigating to drop-off point'
          : 'Navigating to pickup point';
      return;
    }

    final meters = Geolocator.distanceBetween(lat, lng, targetLat, targetLng);
    final km = meters / 1000;
    distance.value = '${km.toStringAsFixed(2)} km';

    final etaMinutes = ((km / 30) * 60).clamp(1, 180).round();
    eta.value = '$etaMinutes mins';

    if (!isPickedUp.value) {
      navigationHint.value = meters <= 80
          ? 'You are at pickup point. Capture and confirm pickup.'
          : 'Navigating to pickup point';
    } else {
      navigationHint.value = meters <= 80
          ? 'You are at drop-off point. Capture and confirm delivery.'
          : 'Navigating to drop-off point';
    }
  }

  Future<void> _pushCurrentLocation() async {
    var latitude = currentLat.value;
    var longitude = currentLng.value;

    if (latitude == null || longitude == null) {
      final position = await _getCurrentPosition();
      if (position != null) {
        _applyCurrentPosition(position.latitude, position.longitude);
        latitude = position.latitude;
        longitude = position.longitude;
      }
    }

    if (latitude == null || longitude == null) {
      currentLocationLabel.value = 'Waiting current location...';
      return;
    }

    try {
      _driverSocket.sendCurrentLocation(
        latitude: latitude,
        longitude: longitude,
        driverStatus: 'Online',
      );
    } catch (_) {}

    if (parcelId.value.isNotEmpty) {
      try {
        _trackingSocket.sendLiveLocation(
          latitude: latitude,
          longitude: longitude,
        );
      } catch (_) {}
    }

    currentLocationLabel.value =
        'Sent: ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  Future<void> capturePickupPhoto() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.camera);
      if (file != null) {
        pickupPhotoPath.value = file.path;
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not capture pickup photo');
    }
  }

  Future<void> confirmPickup() async {
    final id = parcelNumericId.value;
    if (id == null) {
      Get.snackbar('Error', 'Missing parcel numeric id');
      return;
    }
    if (pickupPhotoPath.value.isEmpty) {
      Get.snackbar('Required', 'Take pickup photo first');
      return;
    }

    try {
      isSubmittingPickup.value = true;
      await _api.uploadPickupProofImage(
        id: id,
        imagePath: pickupPhotoPath.value,
      );
      isPickedUp.value = true;
      _updateDistanceAndHint();
      await _refreshRoute(force: true);
      Get.snackbar('Success', 'Pickup confirmed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm pickup');
    } finally {
      isSubmittingPickup.value = false;
    }
  }

  Future<void> captureDropoffPhoto() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.camera);
      if (file != null) {
        dropoffPhotoPath.value = file.path;
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not capture dropoff photo');
    }
  }

  Future<void> confirmDropoff() async {
    final id = parcelNumericId.value;
    if (id == null) {
      Get.snackbar('Error', 'Missing parcel numeric id');
      return;
    }
    if (dropoffPhotoPath.value.isEmpty) {
      Get.snackbar('Required', 'Take dropoff photo first');
      return;
    }

    try {
      isSubmittingDropoff.value = true;
      await _api.uploadDropoffProofImage(
        id: id,
        imagePath: dropoffPhotoPath.value,
      );
      Get.snackbar('Success', 'Delivery completed');
      await Future.delayed(const Duration(milliseconds: 900));
      Get.offAllNamed('/driver/home');
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm dropoff');
    } finally {
      isSubmittingDropoff.value = false;
    }
  }

  Future<void> openDirections() async {
    final originLat = currentLat.value;
    final originLng = currentLng.value;

    if (originLat == null || originLng == null) {
      Get.snackbar('Location', 'Current location is not available yet');
      return;
    }

    final destinationLat = isPickedUp.value ? dropLat.value : pickupLat.value;
    final destinationLng = isPickedUp.value ? dropLng.value : pickupLng.value;
    final destinationLabel = isPickedUp.value ? 'drop-off' : 'pickup';

    if (destinationLat == null || destinationLng == null) {
      Get.snackbar('Direction', 'No $destinationLabel location found');
      return;
    }

    isMapFullscreen.value = true;
    await _refreshRoute(force: true);
  }

  double? _toDouble(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _refreshRoute({bool force = false}) async {
    double? originLat = currentLat.value;
    double? originLng = currentLng.value;
    double? destLat = isPickedUp.value ? dropLat.value : pickupLat.value;
    double? destLng = isPickedUp.value ? dropLng.value : pickupLng.value;

    if (originLat == null || originLng == null) {
      originLat = pickupLat.value;
      originLng = pickupLng.value;
    }

    if (originLat == null ||
        originLng == null ||
        destLat == null ||
        destLng == null) {
      routePoints.clear();
      return;
    }

    if (!force && _lastRouteFetchAt != null) {
      final elapsed = DateTime.now().difference(_lastRouteFetchAt!);
      if (elapsed.inSeconds < 20) return;
    }

    try {
      isLoadingRoute.value = true;
      final uri =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '$originLat,$originLng',
            'destination': '$destLat,$destLng',
            'mode': 'driving',
            'key': ApiKeys.googleMapsApiKey,
          });

      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) {
        routePoints.clear();
        return;
      }

      final firstRoute = routes.first;
      if (firstRoute is! Map) return;

      final overview = firstRoute['overview_polyline'];
      if (overview is! Map) return;
      final encoded = (overview['points'] ?? '').toString();
      if (encoded.isEmpty) {
        routePoints.clear();
        return;
      }

      routePoints.assignAll(_decodePolyline(encoded));
      _lastRouteFetchAt = DateTime.now();
    } catch (_) {
    } finally {
      isLoadingRoute.value = false;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  Future<Position?> _getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    _locationTicker?.cancel();
    _positionSub?.cancel();
    _driverSocketSub?.cancel();
    _trackingSub?.cancel();
    super.onClose();
  }
}
