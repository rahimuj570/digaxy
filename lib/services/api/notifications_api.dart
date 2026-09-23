part of 'api_service.dart';

extension NotificationsApi on ApiService {
  /// Get notifications list (authenticated)
  /// GET /notifications/list/
  Future<Map<String, dynamic>> fetchNotificationsList({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getJson(
      '/notifications/list/',
      queryParameters: {'page': '$page', 'page_size': '$pageSize'},
    );
  }
}
