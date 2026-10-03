part of 'api_service.dart';

extension EarningsApi on ApiService {
  /// Helper earnings overview: GET /api/helper/earnings/
  Future<Map<String, dynamic>> fetchHelperEarnings() async {
    try {
      return await getJson('/helper/earnings/');
    } on ApiException catch (e) {
      if (_enableLogging) {
        debugPrint(
          '[EarningsApi] /helper/earnings/ failed (${e.statusCode}), trying /driver/earnings/',
        );
      }
      return await fetchUserEarnings();
    }
  }

  /// Driver / Helper earnings overview
  /// GET /helper/earnings/, /driver/earnings/ or /user/earnings/
  Future<Map<String, dynamic>> fetchUserEarnings() async {
    final role = (GetStorage().read('user_role') as String?)?.toLowerCase();
    if (role == 'helper') {
      try {
        return await getJson('/helper/earnings/');
      } catch (_) {}
    }
    if (role == 'driver' || role == 'helper') {
      try {
        return await getJson('/driver/earnings/');
      } on ApiException catch (e) {
        if (_enableLogging) {
          debugPrint(
            '[EarningsApi] /driver/earnings/ returned ${e.statusCode}, trying fallback to /user/earnings/',
          );
        }
        return await getJson('/user/earnings/');
      }
    }
    return await getJson('/user/earnings/');
  }

  /// Wallet information: GET /api/wallet/info/
  Future<Map<String, dynamic>> fetchWalletInfo() async {
    return await getJson('/wallet/info/');
  }

  /// Request payout: POST /api/wallet/payout/request/
  Future<Map<String, dynamic>> requestWalletPayout({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    final body = {
      'amount': amount,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
    };
    return await postJson('/wallet/payout/request/', body: body);
  }

  /// Payout history: GET /api/wallet/payout/history/
  Future<Map<String, dynamic>> fetchPayoutHistory() async {
    return await getJson('/wallet/payout/history/');
  }

  /// Stripe Connect Onboarding URL: GET /api/wallet/stripe-connect/onboard/
  Future<Map<String, dynamic>> fetchStripeConnectOnboardUrl() async {
    return await getJson('/wallet/stripe-connect/onboard/');
  }
}
