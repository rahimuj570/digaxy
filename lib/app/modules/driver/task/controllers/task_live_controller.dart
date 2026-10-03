import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/live_location/driver_location_update_socket_service.dart';
import 'package:digaxy/services/live_location/parcel_live_location_socket_service.dart';
import 'package:digaxy/shared/api_keys.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskLiveController extends GetxController {
  final title = 'Live Movement'.obs;
  final from = ''.obs;
  final to = ''.obs;
  final distance = '--'.obs;
  final eta = '--'.obs;
  final customerName = ''.obs;

  GoogleMapController? mapController;

  final pickupAddress = ''.obs;
  final dropoffAddress = ''.obs;
  final parcelId = ''.obs;
  final parcelNumericId = RxnInt();

  final pickupContactName = ''.obs;
  final pickupContactPhone = ''.obs;
  final dropContactName = ''.obs;
  final dropContactPhone = ''.obs;
  final parcelStatus = ''.obs;
  final parcelType = ''.obs;
  final vehicleType = ''.obs;
  final price = ''.obs;
  final pickupDate = ''.obs;
  final pickupTime = ''.obs;
  final isLoadingDetails = false.obs;
  final detailsError = ''.obs;

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
        pickupContactName.value = '${args['customerName']}';
      }
      if (args['pickupContactName'] != null) {
        pickupContactName.value = '${args['pickupContactName']}';
      }
      if (args['pickupContactPhone'] != null) {
        pickupContactPhone.value = '${args['pickupContactPhone']}';
      }
      if (args['dropContactName'] != null) {
        dropContactName.value = '${args['dropContactName']}';
      }
      if (args['dropContactPhone'] != null) {
        dropContactPhone.value = '${args['dropContactPhone']}';
      }
      if (args['deliveryStatus'] != null) {
        parcelStatus.value = '${args['deliveryStatus']}';
      }

      final parsedId =
          (args['parcel_id'] ?? args['parcelId'] ?? args['jobId'] ?? args['id'] ?? '')
              .toString()
              .trim();
      if (parsedId.isNotEmpty) {
        parcelId.value = parsedId;
      }

      final numericId = _resolveParcelNumericId(args);
      if (numericId != null) {
        parcelNumericId.value = numericId;
        _loadParcelDetails(numericId);
      }

      if (pickupLat.value == null) pickupLat.value = _toDouble(args['pickupLat']);
      if (pickupLng.value == null) pickupLng.value = _toDouble(args['pickupLng']);
      if (dropLat.value == null) dropLat.value = _toDouble(args['dropLat']);
      if (dropLng.value == null) dropLng.value = _toDouble(args['dropLng']);

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

  int? _resolveParcelNumericId(Map args) {
    final candidates = [
      args['parcelNumericId'],
      args['parcel_numeric_id'],
      args['parcelId'],
      args['parcel_id'],
      args['id'],
      args['jobId'],
    ];

    for (final value in candidates) {
      final parsed = int.tryParse(value?.toString().trim() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<void> _loadParcelDetails(int id) async {
    try {
      isLoadingDetails.value = true;
      detailsError.value = '';
      final data = await _api.fetchParcelDetails(id: id);

      final pId = (data['parcel_id'] ?? data['id'] ?? id).toString();
      if (pId.isNotEmpty) {
        parcelId.value = pId;
      }
      title.value = 'Live - Parcel #$id';

      if (pickupAddress.value.isEmpty || pickupAddress.value == 'N/A') {
        pickupAddress.value = (data['pickup_address'] ?? '').toString();
      }
      if (dropoffAddress.value.isEmpty || dropoffAddress.value == 'N/A') {
        dropoffAddress.value = (data['drop_address'] ?? '').toString();
      }

      if (pickupLat.value == null) pickupLat.value = _toDouble(data['ping']);
      if (pickupLng.value == null) pickupLng.value = _toDouble(data['pong']);
      if (dropLat.value == null) dropLat.value = _toDouble(data['ding']);
      if (dropLng.value == null) dropLng.value = _toDouble(data['dong']);

      if ((data['pickup_user_name'] ?? '').toString().isNotEmpty) {
        pickupContactName.value = (data['pickup_user_name']).toString();
        customerName.value = pickupContactName.value;
      }
      if ((data['phone_number'] ?? '').toString().isNotEmpty) {
        pickupContactPhone.value = (data['phone_number']).toString();
      }
      if ((data['drop_user_name'] ?? '').toString().isNotEmpty) {
        dropContactName.value = (data['drop_user_name']).toString();
      }
      if ((data['drop_number'] ?? '').toString().isNotEmpty) {
        dropContactPhone.value = (data['drop_number']).toString();
      }

      final st = (data['delivery_status'] ?? '').toString();
      if (st.isNotEmpty) {
        parcelStatus.value = st;
        final statusLower =
            st.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
        if (statusLower == 'on_the_way' ||
            statusLower == 'onway' ||
            statusLower == 'picked_up' ||
            statusLower == 'pickup_done') {
          isPickedUp.value = true;
        }
      }

      parcelType.value = (data['percel_type'] ?? '').toString();
      vehicleType.value = (data['vehicle_type'] ?? '').toString();
      price.value = (data['price'] ?? '').toString();
      pickupDate.value = (data['pickup_date'] ?? '').toString();
      pickupTime.value = (data['pickup_time'] ?? '').toString();

      from.value = pickupAddress.value;
      to.value = dropoffAddress.value;

      _updateDistanceAndHint();
      _refreshRoute(force: true);
      _connectSockets();
    } catch (e) {
      detailsError.value = 'Failed to load details: $e';
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      Get.snackbar('Notice', 'No phone number available');
      return;
    }
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar('Notice', 'Could not open phone dialer for $phoneNumber');
      }
    } catch (_) {
      Get.snackbar('Notice', 'Could not make call to $phoneNumber');
    }
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

  Future<bool> confirmDropoff() async {
    final id = parcelNumericId.value;
    if (id == null) {
      Get.snackbar('Error', 'Missing parcel numeric id');
      return false;
    }
    if (dropoffPhotoPath.value.isEmpty) {
      Get.snackbar('Required', 'Take drop-off photo first');
      return false;
    }

    try {
      isSubmittingDropoff.value = true;
      await _api.uploadDropoffProofImage(
        id: id,
        imagePath: dropoffPhotoPath.value,
        action: 'send_otp',
      );
      Get.snackbar('Success', 'OTP sent successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSubmittingDropoff.value = false;
    }
  }

  Future<bool> confirmDropoffWithOtp(String otp) async {
    final id = parcelNumericId.value;
    if (id == null) {
      Get.snackbar('Error', 'Missing parcel numeric id');
      return false;
    }
    if (dropoffPhotoPath.value.isEmpty) {
      Get.snackbar('Required', 'Take drop-off photo first');
      return false;
    }
    final cleanOtp = otp.trim();
    if (cleanOtp.length < 4) {
      Get.snackbar('Required', 'Please enter a valid 4-digit OTP');
      return false;
    }

    try {
      isSubmittingDropoff.value = true;
      await _api.uploadDropoffProofImage(
        id: id,
        imagePath: dropoffPhotoPath.value,
        action: 'verify_otp',
        otp: cleanOtp,
      );
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      }
      Get.snackbar('Success', 'Delivery completed successfully');
      await Future.delayed(const Duration(milliseconds: 900));
      final role = (GetStorage().read('user_role') as String?)?.toLowerCase();
      if (role == 'helper') {
        Get.offAllNamed(Routes.HELPER_HOME);
      } else {
        Get.offAllNamed(Routes.DRIVER_HOME);
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSubmittingDropoff.value = false;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    Future.delayed(const Duration(milliseconds: 300), () {
      fitRouteBounds();
    });
  }

  void fitRouteBounds({double padding = 60.0}) {
    if (mapController == null) return;
    final points = <LatLng>[];
    if (routePoints.isNotEmpty) {
      points.addAll(routePoints);
    } else {
      if (currentLat.value != null && currentLng.value != null) {
        points.add(LatLng(currentLat.value!, currentLng.value!));
      }
      final targetLat = isPickedUp.value ? dropLat.value : pickupLat.value;
      final targetLng = isPickedUp.value ? dropLng.value : pickupLng.value;
      if (targetLat != null && targetLng != null) {
        points.add(LatLng(targetLat, targetLng));
      }
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 15),
        ),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    try {
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          padding,
        ),
      );
    } catch (_) {}
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
    fitRouteBounds();
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
      fitRouteBounds();
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
