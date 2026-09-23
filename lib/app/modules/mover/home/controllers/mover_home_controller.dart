import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/maps/google_places_service.dart';

class MoverHomeController extends GetxController {
  final userName = 'Mover'.obs;
  final count = 0.obs;

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
    _loadUserName();
    fetchProfile();
    fetchCurrentLocation();
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

  void _loadUserName() {
    final authSession = _box.read('auth_session');
    if (authSession is Map) {
      final data = (authSession['data'] is Map)
          ? authSession['data'] as Map
          : authSession;
      final user = (data['user'] is Map) ? data['user'] as Map : data;

      final name = _resolveName(user);
      if (name != null) {
        userName.value = name;
        return;
      }
    }

    final storedName = _box.read('full_name') ??
        _box.read('surname') ??
        _box.read('username') ??
        _box.read('name');
    if (storedName is String && storedName.trim().isNotEmpty) {
      userName.value = storedName.trim();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final data = await _api.getCustomerProfile();
      final name = _resolveName(data);
      if (name != null) {
        userName.value = name;
      }
    } catch (_) {}
  }

  String? _resolveName(Map user) {
    for (final key in [
      'surname',
      'last_name',
      'full_name',
      'name',
      'username',
      'first_name',
    ]) {
      final val = user[key];
      if (val is String && val.trim().isNotEmpty) {
        return val.trim();
      }
    }
    return null;
  }

  void increment() => count.value++;
}
