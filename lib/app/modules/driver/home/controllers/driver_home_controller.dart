import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/api_keys.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';
import 'package:digaxy/services/maps/google_places_service.dart';

import 'package:digaxy/services/live_location/driver_location_publisher_service.dart';

class DriverHomeController extends GetxController {
  final isLoadingActive = true.obs;
  final activeLoadError = ''.obs;
  final activeDeliveries = <Map<String, dynamic>>[].obs;
  final driverName = 'Driver'.obs;

  final isOnline = true.obs;

  final currentAddress = 'Detecting location...'.obs;
  final currentLatitude = RxnDouble();
  final currentLongitude = RxnDouble();
  final isLoadingLocation = false.obs;

  late final ApiService _api;
  late final GetStorage _box;
  final _placesService = const GooglePlacesService();

  @override
  void onInit() {
    super.onInit();
    _api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();
    _box = GetStorage();
    _loadOnlineStatus();
    _loadDriverName();
    refreshActiveDeliveries();
    fetchCurrentLocation();
  }

  void _loadOnlineStatus() {
    final saved = _box.read('driver_is_online') as bool?;
    if (saved != null) {
      isOnline.value = saved;
    }
  }

  void toggleOnlineStatus() {
    setOnlineStatus(!isOnline.value);
  }

  void setOnlineStatus(bool value) {
    isOnline.value = value;
    _box.write('driver_is_online', value);
    if (Get.isRegistered<DriverLocationPublisherService>()) {
      Get.find<DriverLocationPublisherService>().setOnline(value);
    }
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        currentAddress.value = 'Location service disabled';
        isLoadingLocation.value = false;
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress.value = 'Location permission denied';
          isLoadingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress.value = 'Location permission denied';
        isLoadingLocation.value = false;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      currentLatitude.value = pos.latitude;
      currentLongitude.value = pos.longitude;

      final address = await _placesService.reverseGeocode(
        pos.latitude,
        pos.longitude,
      );

      if (address != null && address.trim().isNotEmpty) {
        currentAddress.value = address.trim();
      } else {
        currentAddress.value =
            'Current Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
      }
    } catch (e) {
      if (currentAddress.value == 'Detecting location...') {
        currentAddress.value = 'Location unavailable';
      }
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void _loadDriverName() {
    // Extract username from stored auth session
    final authSession = _box.read('auth_session');
    if (authSession is Map<String, dynamic>) {
      final data = authSession['data'];
      if (data is Map<String, dynamic>) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          final username = user['username'] ?? user['name'];
          if (username is String && username.isNotEmpty) {
            driverName.value = username;
            return;
          }
        }
        // Try top-level username/name
        final username = data['username'] ?? data['name'];
        if (username is String && username.isNotEmpty) {
          driverName.value = username;
          return;
        }
      }
    }
    // Fallback: try reading username directly from storage
    final storedUsername = _box.read('username');
    if (storedUsername is String && storedUsername.isNotEmpty) {
      driverName.value = storedUsername;
    }
  }

  Future<void> refreshActiveDeliveries() async {
    try {
      isLoadingActive.value = true;
      activeLoadError.value = '';

      final onway = await _fetchList(
        () => _api.fetchOnwayParcels(page: 1, pageSize: 20),
      );
      final accepted = await _fetchList(
        () => _api.fetchAcceptedParcels(page: 1, pageSize: 20),
      );

      final combined = <Map<String, dynamic>>[...onway, ...accepted];
      final enriched = <Map<String, dynamic>>[];

      for (final parcel in combined) {
        final withDetails = await _mergeDetails(parcel);
        final withMetrics = await _attachRouteMetrics(withDetails);
        enriched.add(withMetrics);
      }

      activeDeliveries.assignAll(enriched);
    } catch (_) {
      activeLoadError.value = 'Failed to load active deliveries';
      activeDeliveries.clear();
    } finally {
      isLoadingActive.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchList(
    Future<Map<String, dynamic>> Function() loader,
  ) async {
    final response = await loader();
    final results = response['results'];
    if (results is! List) return <Map<String, dynamic>>[];
    return results
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> _mergeDetails(Map<String, dynamic> base) async {
    final id = int.tryParse((base['id'] ?? '').toString());
    if (id == null) return base;

    try {
      final details = await _api.fetchParcelDetails(id: id);
      return {...base, ...details};
    } catch (_) {
      return base;
    }
  }

  Future<Map<String, dynamic>> _attachRouteMetrics(
    Map<String, dynamic> parcel,
  ) async {
    final pickupLat = _toDouble(
      parcel['ping'] ??
          parcel['pickup_lat'] ??
          parcel['pickup_latitude'] ??
          parcel['pickupLatitude'],
    );
    final pickupLng = _toDouble(
      parcel['pong'] ??
          parcel['pickup_lng'] ??
          parcel['pickup_longitude'] ??
          parcel['pickupLongitude'],
    );
    final dropLat = _toDouble(
      parcel['ding'] ??
          parcel['drop_lat'] ??
          parcel['dropoff_latitude'] ??
          parcel['dropoffLatitude'] ??
          parcel['drop_latitude'],
    );
    final dropLng = _toDouble(
      parcel['dong'] ??
          parcel['drop_lng'] ??
          parcel['dropoff_longitude'] ??
          parcel['dropoffLongitude'] ??
          parcel['drop_longitude'],
    );

    String distanceText = _formatDistance(
      parcel['estimated_distance_km'] ??
          parcel['estimated_distance'] ??
          parcel['distance'],
    );
    String etaText = _formatEta(
      parcel['estimated_time_minutes'] ??
          parcel['estimated_time'] ??
          parcel['estimated_duration'] ??
          parcel['eta'] ??
          parcel['duration'],
    );

    if (pickupLat != null &&
        pickupLng != null &&
        dropLat != null &&
        dropLng != null) {
      // Fallback calculation via Geolocator
      if (distanceText == '--' || distanceText.isEmpty) {
        final distMeters = Geolocator.distanceBetween(
          pickupLat,
          pickupLng,
          dropLat,
          dropLng,
        );
        final distKm = distMeters / 1000.0;
        distanceText = '${distKm.toStringAsFixed(1)} km';
        if (etaText == '--' || etaText.isEmpty) {
          final estMinutes = (distKm / 35.0 * 60).round().clamp(1, 9999);
          etaText = estMinutes >= 60
              ? '${estMinutes ~/ 60} hr ${estMinutes % 60} mins'
              : '$estMinutes mins';
        }
      }

      // High-accuracy Google Directions API call
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/directions/json',
          {
            'origin': '$pickupLat,$pickupLng',
            'destination': '$dropLat,$dropLng',
            'mode': 'driving',
            'key': ApiKeys.googleMapsApiKey,
          },
        );
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final routes = decoded['routes'];
            if (routes is List && routes.isNotEmpty) {
              final firstRoute = routes.first;
              if (firstRoute is Map) {
                final legs = firstRoute['legs'];
                if (legs is List && legs.isNotEmpty) {
                  final firstLeg = legs.first;
                  if (firstLeg is Map) {
                    final gDist = firstLeg['distance']?['text']?.toString();
                    final gDur = firstLeg['duration']?['text']?.toString();
                    if (gDist != null && gDist.trim().isNotEmpty) {
                      distanceText = gDist.trim();
                    }
                    if (gDur != null && gDur.trim().isNotEmpty) {
                      etaText = gDur.trim();
                    }
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    return {
      ...parcel,
      'gm_distance_text': distanceText.isEmpty ? '--' : distanceText,
      'gm_eta_text': etaText.isEmpty ? '--' : etaText,
    };
  }

  String _formatDistance(dynamic raw) {
    if (raw == null) return '--';
    final str = raw.toString().trim();
    if (str.isEmpty || str == '--') return '--';
    if (str.toLowerCase().contains('km') ||
        str.toLowerCase().contains('mi') ||
        str.toLowerCase().contains('m')) {
      return str;
    }
    final numVal = double.tryParse(str);
    if (numVal != null) {
      return '${numVal.toStringAsFixed(1)} km';
    }
    return str;
  }

  String _formatEta(dynamic raw) {
    if (raw == null) return '--';
    final str = raw.toString().trim();
    if (str.isEmpty || str == '--') return '--';
    if (str.toLowerCase().contains('min') ||
        str.toLowerCase().contains('hr') ||
        str.toLowerCase().contains('sec')) {
      return str;
    }
    final numVal = int.tryParse(str) ?? double.tryParse(str)?.round();
    if (numVal != null) {
      if (numVal >= 60) {
        final hrs = numVal ~/ 60;
        final mins = numVal % 60;
        return mins > 0 ? '$hrs hr $mins mins' : '$hrs hr';
      }
      return '$numVal mins';
    }
    return str;
  }

  double? _toDouble(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}
