part of 'api_service.dart';

extension ParcelApi on ApiService {
  String _currentRole() {
    final role = (GetStorage().read('user_role') as String?)?.toLowerCase();
    return role ?? '';
  }

  Future<Map<String, dynamic>> _getRoleAwareParcels({
    required String customerPath,
    required String driverPath,
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
        '[ParcelAPI] role=$role hasToken=$hasToken customerPath=$customerPath driverPath=$driverPath',
      );
    }

    if (role == 'driver') {
      try {
        if (_enableLogging) {
          debugPrint('[ParcelAPI] Trying driver endpoint first: $driverPath');
        }
        return await getJson(driverPath, queryParameters: query);
      } on ApiException catch (e) {
        if (_enableLogging) {
          debugPrint(
            '[ParcelAPI] Driver endpoint failed (${e.statusCode}); trying customer fallback: $customerPath',
          );
        }
        // Fallback for backends that expose customer-prefixed listing endpoints.
        return await getJson(customerPath, queryParameters: query);
      }
    }

    try {
      if (_enableLogging) {
        debugPrint('[ParcelAPI] Trying customer endpoint first: $customerPath');
      }
      return await getJson(customerPath, queryParameters: query);
    } on ApiException catch (e) {
      // If role in storage is stale/mismatched, this avoids hard failure.
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

  /// Get created parcels
  Future<Map<String, dynamic>> fetchPendingParcels({
    int page = 1,
    int pageSize = 20,
    bool? isPaid,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/parcels/pending/',
      driverPath: '/driver/parcels/pending/',
      page: page,
      pageSize: pageSize,
      isPaid: isPaid,
    );
  }

  /// Get active (onway) parcels
  Future<Map<String, dynamic>> fetchOnwayParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/onway-parcels/',
      driverPath: '/driver/onway-parcels/',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get accepted parcels list for drivers
  /// GET /customer/accepted-parcels/
  Future<Map<String, dynamic>> fetchAcceptedParcels({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _getRoleAwareParcels(
      customerPath: '/customer/accepted-parcels/',
      driverPath: '/driver/accepted-parcels/',
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
      page: page,
      pageSize: pageSize,
      isPaid: isPaid,
    );
  }

  /// Get parcel details by id
  /// GET /customer/parcels/{id}/
  Future<Map<String, dynamic>> fetchParcelDetails({required int id}) async {
    return await getJson('/customer/parcels/$id/');
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

  /// Upload pickup proof image
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

  /// Upload dropoff proof image
  /// PATCH multipart /driver/parcels/{id}/dropoff/
  Future<Map<String, dynamic>> uploadDropoffProofImage({
    required int id,
    required String imagePath,
  }) async {
    return await patchMultipart(
      '/driver/parcels/$id/dropoff/',
      fields: const {},
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
      if (successUrl != null) 'success_url': successUrl,
      if (cancelUrl != null) 'cancel_url': cancelUrl,
    };
    return await postJson('/checkout/payment/', body: body);
  }
}
