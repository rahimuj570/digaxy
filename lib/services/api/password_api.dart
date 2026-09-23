part of 'api_service.dart';

extension PasswordApi on ApiService {
  /// Calls: POST /auth/password/reset/
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) {
    return postJson(
      '/auth/password/reset/',
      body: {
        'email': email,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  /// Calls: POST /auth/password/change/
  ///
  /// This endpoint requires authentication.
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String accessToken,
  }) {
    final authHeaders = <String, String>{
      'Authorization': 'Bearer $accessToken',
    };

    return postJson(
      '/auth/password/change/',
      headers: authHeaders,
      body: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }
}
