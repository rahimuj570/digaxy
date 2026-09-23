import 'dart:async';
import 'dart:convert';

import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/websocket/socket_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationSocketService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _socketSub;
  Timer? _reconnectTimer;
  Uri? _currentUri;
  Uri get currentUri => _currentUri ??= _resolveUri(channel: _activeChannel);

  final _messagesController = StreamController<Map<String, String>>.broadcast(
    sync: true,
  );

  Stream<Map<String, String>> get messages => _messagesController.stream;

  String? _activeChannel;
  bool _manualDisconnect = false;
  final connectionStatus = 'disconnected'.obs;

  void _setStatus(String status) {
    connectionStatus.value = status;
  }

  Future<void> connect({String? channel}) async {
    _setStatus('connecting');
    _activeChannel = channel;
    _manualDisconnect = false;

    await _socketSub?.cancel();
    _socketSub = null;
    _channel = null;

    final uri = _resolveUri(channel: channel);
    _currentUri = uri;

    SocketLogger.logConnect(
      serviceName: 'NotificationSocketService',
      uri: uri,
    );

    try {
      _channel = WebSocketChannel.connect(uri);

      _socketSub = _channel!.stream.listen(
        _onMessage,
        onError: (err, stackTrace) {
          SocketLogger.logError(
            serviceName: 'NotificationSocketService',
            uri: currentUri,
            error: err,
            stackTrace: stackTrace is StackTrace ? stackTrace : null,
          );
          _setStatus('error');
          _scheduleReconnect();
        },
        onDone: () {
          SocketLogger.logDisconnect(
            serviceName: 'NotificationSocketService',
            uri: currentUri,
            reason: 'Stream closed / disconnected by server',
          );
          _setStatus('disconnected');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _setStatus('connected');
    } catch (e, st) {
      SocketLogger.logError(
        serviceName: 'NotificationSocketService',
        uri: currentUri,
        error: e,
        stackTrace: st,
      );
      _setStatus('error');
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _socketSub?.cancel();
    _socketSub = null;
    _channel?.sink.close();
    _channel = null;
    SocketLogger.logDisconnect(
      serviceName: 'NotificationSocketService',
      uri: currentUri,
      reason: 'Manual disconnect',
    );
    _setStatus('disconnected');
  }

  void _onMessage(dynamic data) {
    SocketLogger.logReceive(
      serviceName: 'NotificationSocketService',
      uri: currentUri,
      message: data,
    );

    final parsed = _normalizeMessage(data);
    if (parsed != null) {
      _messagesController.add(parsed);
    }
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) return;

    _setStatus('reconnecting');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      connect(channel: _activeChannel).catchError((_) {});
    });
  }

  Map<String, String>? _normalizeMessage(dynamic raw) {
    try {
      if (raw is Map) {
        final eventType = raw['type']?.toString().toLowerCase() ?? '';
        if (eventType == 'connection_established') {
          return null;
        }
        final payload = _extractPayload(raw);
        final parcelId = _extractParcelId(payload);
        final parcelNumericId = _extractParcelNumericId(payload);
        final title = _deriveTitle(payload, eventType);
        final subtitle = _deriveSubtitle(payload, eventType, parcelId);
        return {
          'title': title.trim().isEmpty ? 'Notification' : title,
          'subtitle': subtitle,
          'time': _formatTime(
            (payload['time'] ?? payload['created_at'] ?? 'Now').toString(),
          ),
          'parcel_id': parcelId,
          'parcel_numeric_id': parcelNumericId,
        };
      }

      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final eventType = decoded['type']?.toString().toLowerCase() ?? '';
          if (eventType == 'connection_established') {
            return null;
          }
          final payload = _extractPayload(decoded);
          final parcelId = _extractParcelId(payload);
          final parcelNumericId = _extractParcelNumericId(payload);
          final title = _deriveTitle(payload, eventType);
          final subtitle = _deriveSubtitle(payload, eventType, parcelId);
          return {
            'title': title.trim().isEmpty ? 'Notification' : title,
            'subtitle': subtitle,
            'time': _formatTime(
              (payload['time'] ?? payload['created_at'] ?? 'Now').toString(),
            ),
            'parcel_id': parcelId,
            'parcel_numeric_id': parcelNumericId,
          };
        }

        return {'title': 'Notification', 'subtitle': raw, 'time': 'Now'};
      }
    } catch (_) {
      if (raw is String && raw.trim().isNotEmpty) {
        return {'title': 'Notification', 'subtitle': raw, 'time': 'Now'};
      }
    }

    return null;
  }

  String _deriveTitle(Map payload, String eventType) {
    final explicit = (payload['title'] ?? payload['notification_title'] ?? '')
        .toString()
        .trim();
    if (explicit.isNotEmpty) return explicit;

    if (eventType == 'new_parcel_notification') {
      return 'New Parcel Notification';
    }
    if (eventType == 'new_notification') {
      return 'New Notification';
    }
    return 'Notification';
  }

  String _deriveSubtitle(Map payload, String eventType, String parcelId) {
    final explicit =
        (payload['message'] ??
                payload['subtitle'] ??
                payload['body'] ??
                payload['description'] ??
                '')
            .toString()
            .trim();
    if (explicit.isNotEmpty) return explicit;

    if (parcelId.isNotEmpty && eventType == 'new_parcel_notification') {
      return 'Parcel #$parcelId is available.';
    }
    if (parcelId.isNotEmpty) {
      return 'Parcel #$parcelId update received.';
    }
    return '';
  }

  String _formatTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text.toLowerCase() == 'now') return 'Now';

    try {
      final dt = DateTime.parse(text).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[dt.month - 1];
      final hour24 = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final amPm = hour24 >= 12 ? 'PM' : 'AM';
      return '$day $month, $hour12:$minute $amPm';
    } catch (_) {
      return text;
    }
  }

  Map _extractPayload(Map source) {
    final data = source['data'];
    if (data is Map) return data;
    return source;
  }

  String _extractParcelId(Map source) {
    final candidates = [
      source['parcel_id'],
      source['parcelId'],
      source['parcel_uuid'],
      source['parcel'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _extractParcelNumericId(Map source) {
    final candidates = [
      source['parcel_id'],
      source['parcelId'],
      source['parcel_numeric_id'],
      source['parcel_pk'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim() ?? '';
      if (int.tryParse(text) != null) return text;
    }
    return '';
  }

  Uri _resolveUri({String? channel}) {
    final cleanedChannel = channel?.trim() ?? '';
    const explicit = String.fromEnvironment('WS_NOTIFICATIONS_URL');
    if (explicit.isNotEmpty) {
      final explicitUri = Uri.parse(explicit);
      if (cleanedChannel.isEmpty) {
        return explicitUri;
      }
      final normalizedPath = explicitUri.path.endsWith('/')
          ? explicitUri.path
          : '${explicitUri.path}/';
      return explicitUri.replace(path: '$normalizedPath$cleanedChannel/');
    }

    final apiBase = Uri.parse(ApiConfig.baseUrl);
    final token = GetStorage().read('access_token')?.toString();
    final basePath = cleanedChannel.isEmpty
        ? '/ws/notifications/'
        : '/ws/notifications/$cleanedChannel/';

    return Uri(
      scheme: apiBase.scheme == 'https' ? 'wss' : 'ws',
      host: apiBase.host,
      port: apiBase.hasPort ? apiBase.port : null,
      path: basePath,
      queryParameters: (token != null && token.isNotEmpty)
          ? {'token': token}
          : null,
    );
  }

  @override
  void onClose() {
    disconnect();
    _messagesController.close();
    super.onClose();
  }
}
