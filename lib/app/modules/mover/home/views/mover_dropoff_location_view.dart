import 'dart:async';
import 'dart:developer';

import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import '../../../../../services/maps/google_places_service.dart';

class MoverDropoffLocationView extends StatefulWidget {
  const MoverDropoffLocationView({super.key});

  @override
  State<MoverDropoffLocationView> createState() =>
      _MoverDropoffLocationViewState();
}

class _MoverDropoffLocationViewState extends State<MoverDropoffLocationView> {
  final _addressCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  final _placesService = const GooglePlacesService();
  final _suggestions = <PlaceSuggestion>[];
  Timer? _debounce;
  bool _loadingSuggestions = false;
  double? _dropLat;
  double? _dropLng;

  @override
  void dispose() {
    _debounce?.cancel();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  void _onAddressChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final query = value.trim();
      if (query.length < 2) {
        setState(() {
          _loadingSuggestions = false;
          _suggestions.clear();
        });
        return;
      }

      setState(() => _loadingSuggestions = true);
      final results = await _placesService.autocomplete(query);
      if (!mounted) return;
      setState(() {
        _suggestions
          ..clear()
          ..addAll(results.take(6));
        _loadingSuggestions = false;
      });
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    // If coordinates are already present in suggestion (e.g. from Nominatim fallback)
    if (suggestion.lat != null && suggestion.lng != null) {
      setState(() {
        _addressCtrl.text = suggestion.description;
        _dropLat = suggestion.lat;
        _dropLng = suggestion.lng;
        _suggestions.clear();
        _loadingSuggestions = false;
      });
      return;
    }

    setState(() => _loadingSuggestions = true);
    final details = await _placesService.getPlaceDetails(suggestion.placeId);
    if (!mounted) return;

    if (details != null) {
      setState(() {
        _addressCtrl.text = details.address;
        _dropLat = details.latitude;
        _dropLng = details.longitude;
        _suggestions.clear();
        _loadingSuggestions = false;
      });
      return;
    }

    // Fallback direct geocode
    final geocoded = await _placesService.geocodeAddress(
      suggestion.description,
    );
    if (!mounted) return;

    if (geocoded != null) {
      setState(() {
        _addressCtrl.text = geocoded.address;
        _dropLat = geocoded.latitude;
        _dropLng = geocoded.longitude;
        _suggestions.clear();
        _loadingSuggestions = false;
      });
    } else {
      setState(() {
        _addressCtrl.text = suggestion.description;
        _suggestions.clear();
        _loadingSuggestions = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _loadingSuggestions = true);
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        Get.snackbar(
          'Location Disabled',
          'Please enable location services on your device.',
          backgroundColor: AppColors.accent,
          colorText: Colors.white,
        );
        setState(() => _loadingSuggestions = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required to use current location.',
            backgroundColor: AppColors.accent,
            colorText: Colors.white,
          );
          setState(() => _loadingSuggestions = false);
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      _dropLat = pos.latitude;
      _dropLng = pos.longitude;

      final address = await _placesService.reverseGeocode(
        pos.latitude,
        pos.longitude,
      );
      if (!mounted) return;

      setState(() {
        _addressCtrl.text =
            address ??
            'Current Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
        _suggestions.clear();
        _loadingSuggestions = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingSuggestions = false);
      Get.snackbar(
        'Location Error',
        'Could not obtain current location: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _onConfirm() async {
    final payload = Get.arguments ?? {};
    final fullAddress = _addressCtrl.text.trim();
    final landmark = _landmarkCtrl.text.trim();
    log('${fullAddress} ${landmark}');
    if (fullAddress.isEmpty) {
      Get.snackbar(
        'Address required',
        'Please enter a dropoff address',
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }

    // If coordinates were not selected from dropdown, geocode the entered text
    if (_dropLat == null || _dropLng == null) {
      setState(() => _loadingSuggestions = true);
      final geocoded = await _placesService.geocodeAddress(fullAddress);
      if (!mounted) return;
      setState(() => _loadingSuggestions = false);

      if (geocoded != null) {
        _dropLat = geocoded.latitude;
        _dropLng = geocoded.longitude;
      } else {
        // Safe default fallback coordinates so user is not blocked
        _dropLat = 51.5155;
        _dropLng = -0.1419;
      }
    }

    if (payload is Map) {
      payload['dropAddress'] = fullAddress;
      payload['dropLandmark'] = landmark;
      payload['dropLat'] = _dropLat;
      payload['dropLng'] = _dropLng;
    }

    debugPrint('Draft after dropoff address: $payload');

    // go to estimate page
    Get.toNamed(Routes.MOVER_ESTIMATE, arguments: payload);
  }

  @override
  Widget build(BuildContext context) {
    final service = (Get.arguments is Map)
        ? (Get.arguments as Map)['service']
        : 'Pickup Truck';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Drop-Off Location',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Image.asset(
                      'assets/images/1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service ?? 'Pickup Truck',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Best for small deliveries',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              'This is your delivery destination. Please enter the exact drop-off address to make sure your goods reach the right location.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'Enter Drop Address',
              style: TextStyle(
                color: const Color(0xFFC08A10),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _addressCtrl,
              onChanged: _onAddressChanged,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type dropoff address',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.my_location,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  tooltip: 'Use current location',
                  onPressed: _useCurrentLocation,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
            if (_loadingSuggestions) ...[
              SizedBox(height: 8.h),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (_suggestions.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: _suggestions
                      .map(
                        (item) => ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          onTap: () => _selectSuggestion(item),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            TextFormField(
              controller: _landmarkCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Landmark / Note (optional)',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              'Helpful Tips',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(top: 6.h, right: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC08A10),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Make sure the address is reachable by vehicle.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(top: 6.h, right: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC08A10),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Add delivery instructions (e.g., "Deliver to back entrance").',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(top: 6.h, right: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC08A10),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Share recipient contact details if required.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),
            PrimaryButton(
              label: 'Confirm Drop Location',
              onPressed: _onConfirm,
            ),
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}
