part of 'api_service.dart';

extension SupportApi on ApiService {
  /// POST /support/submit/
  /// Body: { "message": "..." }
  Future<Map<String, dynamic>> submitSupport({required String message}) async {
    return await postJson(
      '/support/submit/',
      body: {'message': message},
    );
  }
}
