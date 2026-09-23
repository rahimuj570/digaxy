part of 'api_service.dart';

extension OtpApi on ApiService {
  /// Calls: POST /auth/otp/send/
  Future<Map<String, dynamic>> sendOtp({required String email}) {
    return postJson('/auth/otp/send/', body: {'email': email});
  }

  /// Calls: POST /auth/otp/verify/
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return postJson(
      '/auth/otp/verify/',
      body: {'email': email, 'otp': otp},
    );
  }
}
