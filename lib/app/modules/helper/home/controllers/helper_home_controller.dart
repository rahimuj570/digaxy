import 'dart:convert';

import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/api_keys.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HelperHomeController extends GetxController {
  final isLoadingActive = true.obs;
  final activeLoadError = ''.obs;
  final activeDeliveries = <Map<String, dynamic>>[].obs;
  final helperName = 'Helper'.obs;
  final isOnline = true.obs;

  late final ApiService _api;
  late final GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();
    _box = GetStorage();
    _loadHelperName();
    refreshActiveDeliveries();
  }

  void _loadHelperName() {
    final authSession = _box.read('auth_session');
    if (authSession is Map<String, dynamic>) {
      final data = authSession['data'];
      if (data is Map<String, dynamic>) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          final username = user['username'] ?? user['name'];
          if (username is String && username.isNotEmpty) {
            helperName.value = username;
            return;
          }
        }

        final username = data['username'] ?? data['name'];
        if (username is String && username.isNotEmpty) {
          helperName.value = username;
          return;
        }
      }
    }

    final storedUsername = _box.read('username');
    if (storedUsername is String && storedUsername.isNotEmpty) {
      helperName.value = storedUsername;
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

  void toggleOnlineStatus(bool value) {
    isOnline.value = value;
  }
}
