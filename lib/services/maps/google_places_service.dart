import 'dart:convert';
import 'dart:developer' as developer;

import 'package:digaxy/shared/api_keys.dart';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String placeId;
  final String description;
  final double? lat;
  final double? lng;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.lat,
    this.lng,
  });
}

class PlaceLocationResult {
  final String address;
  final double latitude;
  final double longitude;

  const PlaceLocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class GooglePlacesService {
  const GooglePlacesService();

  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    // 1. Try Google Places Autocomplete
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {'input': trimmed, 'key': ApiKeys.googleMapsApiKey},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final status = (decoded['status'] ?? '').toString();
          if (status == 'OK') {
            final predictions = decoded['predictions'];
            if (predictions is List && predictions.isNotEmpty) {
              return predictions
                  .whereType<Map>()
                  .map(
                    (item) => PlaceSuggestion(
                      placeId: (item['place_id'] ?? '').toString(),
                      description: (item['description'] ?? '').toString(),
                    ),
                  )
                  .where(
                    (item) =>
                        item.placeId.isNotEmpty && item.description.isNotEmpty,
                  )
                  .toList();
            }
          } else if (status != 'ZERO_RESULTS') {
            developer.log(
              'Google Places Autocomplete status: $status (${decoded['error_message'] ?? ''})',
              name: 'PlacesService',
            );
          }
        }
      }
    } catch (e) {
      developer.log('Google Places Autocomplete exception: $e', name: 'PlacesService');
    }

    // 2. Fallback to OpenStreetMap Nominatim
    return _nominatimAutocomplete(trimmed);
  }

  Future<PlaceLocationResult?> getPlaceDetails(String placeId) async {
    final trimmed = placeId.trim();
    if (trimmed.isEmpty) return null;

    // Check if placeId is an OSM fallback with embedded coords: "osm_{lat}_{lng}_{encodedAddress}"
    if (trimmed.startsWith('osm_')) {
      final parts = trimmed.split('_');
      if (parts.length >= 3) {
        final lat = double.tryParse(parts[1]);
        final lng = double.tryParse(parts[2]);
        final address = parts.length > 3
            ? Uri.decodeComponent(parts.sublist(3).join('_'))
            : 'Selected Location';
        if (lat != null && lng != null) {
          return PlaceLocationResult(
            address: address,
            latitude: lat,
            longitude: lng,
          );
        }
      }
    }

    // 1. Try Google Place Details API
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': trimmed,
          'fields': 'formatted_address,geometry',
          'key': ApiKeys.googleMapsApiKey,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] == 'OK') {
          final result = decoded['result'];
          if (result is Map) {
            final formattedAddress = (result['formatted_address'] ?? '').toString();
            final geometry = result['geometry'];
            if (geometry is Map) {
              final location = geometry['location'];
              if (location is Map) {
                final lat = double.tryParse((location['lat'] ?? '').toString());
                final lng = double.tryParse((location['lng'] ?? '').toString());
                if (lat != null && lng != null) {
                  return PlaceLocationResult(
                    address: formattedAddress,
                    latitude: lat,
                    longitude: lng,
                  );
                }
              }
            }
          }
        }
      }
    } catch (e) {
      developer.log('Google Place Details exception: $e', name: 'PlacesService');
    }

    return null;
  }

  /// Geocode an address string directly into coordinates and formatted address
  Future<PlaceLocationResult?> geocodeAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;

    // 1. Try Google Geocoding API
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {'address': trimmed, 'key': ApiKeys.googleMapsApiKey},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] == 'OK') {
          final results = decoded['results'];
          if (results is List && results.isNotEmpty) {
            final first = results.first;
            if (first is Map) {
              final formattedAddress = (first['formatted_address'] ?? trimmed).toString();
              final geometry = first['geometry'];
              if (geometry is Map) {
                final location = geometry['location'];
                if (location is Map) {
                  final lat = double.tryParse((location['lat'] ?? '').toString());
                  final lng = double.tryParse((location['lng'] ?? '').toString());
                  if (lat != null && lng != null) {
                    return PlaceLocationResult(
                      address: formattedAddress,
                      latitude: lat,
                      longitude: lng,
                    );
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      developer.log('Google Geocode exception: $e', name: 'PlacesService');
    }

    // 2. Fallback to Nominatim search
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': trimmed,
        'format': 'json',
        'limit': '1',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DigaxyApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is Map) {
            final lat = double.tryParse((first['lat'] ?? '').toString());
            final lng = double.tryParse((first['lon'] ?? '').toString());
            final name = (first['display_name'] ?? trimmed).toString();
            if (lat != null && lng != null) {
              return PlaceLocationResult(
                address: name,
                latitude: lat,
                longitude: lng,
              );
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Reverse geocode coordinates to an address string
  Future<String?> reverseGeocode(double lat, double lng) async {
    // 1. Try Google Reverse Geocoding
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {'latlng': '$lat,$lng', 'key': ApiKeys.googleMapsApiKey},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] == 'OK') {
          final results = decoded['results'];
          if (results is List && results.isNotEmpty) {
            final first = results.first;
            if (first is Map && first['formatted_address'] != null) {
              return first['formatted_address'].toString();
            }
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to Nominatim Reverse Geocoding
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DigaxyApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['display_name'] != null) {
          return decoded['display_name'].toString();
        }
      }
    } catch (_) {}

    return null;
  }

  Future<List<PlaceSuggestion>> _nominatimAutocomplete(String query) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '6',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DigaxyApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) {
                final lat = double.tryParse((item['lat'] ?? '').toString());
                final lng = double.tryParse((item['lon'] ?? '').toString());
                final displayName = (item['display_name'] ?? '').toString();
                final placeId = 'osm_${lat}_${lng}_${Uri.encodeComponent(displayName)}';
                return PlaceSuggestion(
                  placeId: placeId,
                  description: displayName,
                  lat: lat,
                  lng: lng,
                );
              })
              .where((s) => s.description.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      developer.log('Nominatim Autocomplete exception: $e', name: 'PlacesService');
    }

    return const [];
  }
}

