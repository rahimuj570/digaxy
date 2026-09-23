part of 'api_service.dart';

extension AiSupportApi on ApiService {
  /// Calls: POST /ai-support/
  ///
  /// Request body:
  /// { "message": "...", "state": { ... }? }
  ///
  /// Returns normalized map:
  /// {
  ///   "response": String,
  ///   "state": Map<String, dynamic>?
  /// }
  Future<Map<String, dynamic>> aiSupport({
    required String message,
    Map<String, dynamic>? state,
  }) async {
    final response = await postJson(
      '/ai-support/',
      body: {'user_message': message, if (state != null) 'state': state},
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return <String, dynamic>{
        'response': (data['response'] ?? '').toString(),
        'state': data['state'] is Map
            ? Map<String, dynamic>.from(data['state'] as Map)
            : null,
      };
    }

    return <String, dynamic>{
      'response': (response['message'] ?? '').toString(),
      'state': null,
    };
  }
}
