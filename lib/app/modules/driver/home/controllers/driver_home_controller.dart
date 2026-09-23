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
    final pickupLat = _toDouble(parcel['ping']);
    final pickupLng = _toDouble(parcel['pong']);
    final dropLat = _toDouble(parcel['ding']);
    final dropLng = _toDouble(parcel['dong']);

    if (pickupLat == null ||
        pickupLng == null ||
        dropLat == null ||
        dropLng == null) {
      return {
        ...parcel,
        'gm_distance_text': (parcel['estimated_distance_km'] ?? '--')
            .toString(),
        'gm_eta_text': (parcel['estimated_time_minutes'] ?? '--').toString(),
      };
    }

    try {
      final uri =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '$pickupLat,$pickupLng',
            'destination': '$dropLat,$dropLng',
            'mode': 'driving',
            'key': ApiKeys.googleMapsApiKey,
          });
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return parcel;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return parcel;
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty) return parcel;
      final firstRoute = routes.first;
      if (firstRoute is! Map) return parcel;
      final legs = firstRoute['legs'];
      if (legs is! List || legs.isEmpty) return parcel;
      final firstLeg = legs.first;
      if (firstLeg is! Map) return parcel;

      final distanceText = (firstLeg['distance'] is Map)
          ? ((firstLeg['distance']['text'] ?? '').toString())
          : '';
      final durationText = (firstLeg['duration'] is Map)
          ? ((firstLeg['duration']['text'] ?? '').toString())
          : '';

      return {
        ...parcel,
        'gm_distance_text': distanceText.isEmpty
            ? (parcel['estimated_distance_km'] ?? '--').toString()
            : distanceText,
        'gm_eta_text': durationText.isEmpty
            ? (parcel['estimated_time_minutes'] ?? '--').toString()
            : durationText,
      };
    } catch (_) {
      return {
        ...parcel,
        'gm_distance_text': (parcel['estimated_distance_km'] ?? '--')
            .toString(),
        'gm_eta_text': (parcel['estimated_time_minutes'] ?? '--').toString(),
      };
    }
  }

  double? _toDouble(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}
