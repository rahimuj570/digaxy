part of 'api_service.dart';

extension LoginApi on ApiService {
  /// Calls: POST /auth/login/
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await postJson(
      '/auth/login/',
      body: {'email': email, 'password': password},
    );
  }
}
