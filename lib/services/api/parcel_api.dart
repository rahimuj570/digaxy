part of 'api_service.dart';

extension ParcelApi on ApiService {
  String _currentRole() {
    final role = (GetStorage().read('user_role') as String?)?.toLowerCase();
    return role ?? '';
  }

  Future<Map<String, dynamic>> _getRoleAwareParcels({
    required String customerPath,
    required String driverPath,
    String? helperPath,
    required int page,
    required int pageSize,
    bool? isPaid,
  }) async {
    final role = _currentRole();
    final hasToken =
        (GetStorage().read('access_token') as String?)?.isNotEmpty == true;
    final query = {'page': '$page', 'page_size': '$pageSize'};
    if (isPaid != null) {
      query['is_paid'] =
          isPaid.toString()[0].toUpperCase() + isPaid.toString().substring(1);
    }

    if (_enableLogging) {
      debugPrint(
        '[ParcelAPI] role=$role hasToken=$hasToken customerPath=$customerPath driverPath=$driverPath helperPath=$helperPath',
      );
    }

    if (role == 'helper' && helperPath != null) {
      try {
        if (_enableLogging) {
          debugPrint('[ParcelAPI] Trying helper endpoint first: $helperPath');
        }
        return await getJson(helperPath, queryParameters: query);
      } on ApiException catch (e) {
        if (_enableLogging) {
          debugPrint(
            '[ParcelAPI] Helper endpoint failed (${e.statusCode}); trying driver fallback: $driverPath',
          );
        }
        try {
          return await getJson(driverPath, queryParameters: query);
        } catch (_) {
          return await getJson(customerPath, queryParameters: query);
        }
      }
    }

    if (role == 'driver' || role == 'helper') {
      try {
        if (_enableLogging) {
          debugPrint('[ParcelAPI] Trying driver endpoint first for $role: $driverPath');
        }
        return await getJson(driverPath, queryParameters: query);
      } on ApiException catch (e) {
        if (_enableLogging) {
          debugPrint(
            '[ParcelAPI] Driver endpoint failed (${e.statusCode}); trying customer fallback: $customerPath',
          );
        }
        return await getJson(customerPath, queryParameters: query);
      }
    }

    try {
      if (_enableLogging) {
        debugPrint('[ParcelAPI] Trying customer endpoint first: $customerPath');
      }
      return await getJson(customerPath, queryParameters: query);
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        if (_enableLogging) {
          debugPrint(
            '[ParcelAPI] Customer endpoint forbidden; trying driver fallback: $driverPath',
          );
        }
        return await getJson(driverPath, queryParameters: query);
      }
      rethrow;
    }
  }

  /// Create a new parcel/job
  /// POST /customer/parcels/create/
  Future<Map<String, dynamic>> createParcel({
    required Map<String, dynamic> parcelData,
  }) async {
    return await postJson('/customer/parcels/create/', body: parcelData);
  }

  /// Get pending parcels or helper available requests
  Future<Map<String, dynamic>> fetchPendingParcels({
    int page = 1,
    int pageSize = 20,
    bool? isPaid,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/parcels/pending/',
      driverPath: '/driver/parcels/pending/',
      helperPath: '/helper/parcels/available/',
      page: page,
      pageSize: pageSize,
      isPaid: isPaid,
    );
  }

  /// Helper Job Feed: GET /api/helper/parcels/available/
  Future<Map<String, dynamic>> fetchAvailableHelperParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await getJson(
        '/helper/parcels/available/',
        queryParameters: {'page': '$page', 'page_size': '$pageSize'},
      );
    } on ApiException catch (_) {
      try {
        return await getJson(
          '/helper/requests/available/',
          queryParameters: {'page': '$page', 'page_size': '$pageSize'},
        );
      } catch (_) {
        return await fetchPendingParcels(page: page, pageSize: pageSize);
      }
    }
  }

  /// Get active (onway) parcels
  Future<Map<String, dynamic>> fetchOnwayParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/onway-parcels/',
      driverPath: '/driver/onway-parcels/',
      helperPath: '/helper/parcels/onway/',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get accepted parcels list
  Future<Map<String, dynamic>> fetchAcceptedParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/accepted-parcels/',
      driverPath: '/driver/accepted-parcels/',
      helperPath: '/helper/parcels/accepted/',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get delivered (completed) parcels
  Future<Map<String, dynamic>> fetchDeliveredParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/parcels/delivered/',
      driverPath: '/driver/parcels/delivered/',
      helperPath: '/helper/parcels/delivered/',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get cancelled parcels
  Future<Map<String, dynamic>> fetchCancelledParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/parcels/cancelled/',
      driverPath: '/driver/parcels/cancelled/',
      helperPath: '/helper/parcels/cancelled/',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get payment due parcels
  Future<Map<String, dynamic>> fetchPaymentDueParcels({
    int page = 1,
    int pageSize = 20,
    bool? isPaid,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/parcels/pending/',
      driverPath: '/driver/parcels/pending/',
      helperPath: '/helper/parcels/available/',
      page: page,
      pageSize: pageSize,
      isPaid: isPaid,
    );
  }

  /// Get parcel details by id
  /// GET /helper/parcels/{id}/ or /customer/parcels/{id}/
  Future<Map<String, dynamic>> fetchParcelDetails({required int id}) async {
    final role = _currentRole();
    if (role == 'helper') {
      try {
        return await getJson('/helper/parcels/$id/');
      } on ApiException catch (_) {
        return await getJson('/customer/parcels/$id/');
      }
    }
    return await getJson('/customer/parcels/$id/');
  }

  /// Helper accept parcel request: POST /api/helper/parcels/{id}/accept/
  Future<Map<String, dynamic>> acceptHelperParcel({required int id}) async {
    return await postJson('/helper/parcels/$id/accept/', body: const {});
  }

  /// Helper cancel accepted deal: POST /api/helper/parcels/{id}/cancel-deal/
  Future<Map<String, dynamic>> cancelHelperDeal({required int id}) async {
    return await postJson('/helper/parcels/$id/cancel-deal/', body: const {});
  }

  /// Update parcel delivery status
  /// PATCH /customer/parcels/{id}/
  Future<Map<String, dynamic>> updateParcelDeliveryStatus({
    required int id,
    required String deliveryStatus,
  }) async {
    return await patchJson(
      '/customer/parcels/$id/',
      body: {'delivery_status': deliveryStatus},
    );
  }

  /// Upload pickup proof image (Driver only)
  /// PATCH multipart /driver/parcels/{id}/pickup/
  Future<Map<String, dynamic>> uploadPickupProofImage({
    required int id,
    required String imagePath,
  }) async {
    return await patchMultipart(
      '/driver/parcels/$id/pickup/',
      fields: {'parcel': '$id'},
      files: {'images': imagePath},
    );
  }

  /// Upload dropoff proof image (Driver only)
  /// PATCH multipart /driver/parcels/{id}/dropoff/
  Future<Map<String, dynamic>> uploadDropoffProofImage({
    required int id,
    required String imagePath,
    String action = 'verify_otp',
    String? otp,
  }) async {
    return await patchMultipart(
      '/driver/parcels/$id/dropoff/',
      fields: {
        'action': action,
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      },
      files: {'images': imagePath},
    );
  }

  /// Accept or reject a task/deal for a parcel
  /// POST /deal/accept/list/create/
  Future<Map<String, dynamic>> submitDealAcceptance({
    required int parcelId,
    required bool isAccepted,
  }) async {
    return await postJson(
      '/deal/accept/list/create/',
      body: {'parcel': parcelId, 'is_accepted': isAccepted},
    );
  }

  /// Cancel a parcel by ID
  /// PATCH /customer/parcel/cancel/{id}/
  Future<Map<String, dynamic>> cancelParcel({required int id}) async {
    final role = _currentRole();
    if (role == 'helper') {
      try {
        return await cancelHelperDeal(id: id);
      } catch (_) {}
    }
    return await patchJson('/customer/parcel/cancel/$id/', body: const {});
  }

  /// Create payment checkout
  /// POST /checkout/payment/
  Future<Map<String, dynamic>> createPaymentCheckout({
    required String parcelId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    final body = {
      'parcel_id': parcelId,
      'success_url': ?successUrl,
      'cancel_url': ?cancelUrl,
    };
    return await postJson('/checkout/payment/', body: body);
  }
}
