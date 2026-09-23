part of 'api_service.dart';

extension EarningsApi on ApiService {
  /// Driver earnings overview
  /// GET /user/earnings/
  Future<Map<String, dynamic>> fetchUserEarnings() async {
    return await getJson('/user/earnings/');
  }
}
