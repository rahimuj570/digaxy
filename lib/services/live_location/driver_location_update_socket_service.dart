import 'dart:async';
import 'dart:convert';

import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/websocket/socket_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverLocationUpdateSocketService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _socketSub;
  Timer? _reconnectTimer;
  bool _manualDisconnect = false;
  Uri? _currentUri;
  Uri get currentUri => _currentUri ??= _resolveUri();
  final connectionStatus = 'disconnected'.obs;

  void _setStatus(String status) {
    connectionStatus.value = status;
  }

  final _messagesController = StreamController<Map<String, dynamic>>.broadcast(
    sync: true,
  );

  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  Future<void> connect() async {
    _setStatus('connecting');
    _manualDisconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _socketSub?.cancel();
    _socketSub = null;
    _channel = null;

    final uri = _resolveUri();
    _currentUri = uri;

    SocketLogger.logConnect(
      serviceName: 'DriverLocationUpdateSocketService',
      uri: uri,
    );

    try {
      _channel = WebSocketChannel.connect(uri);

      _socketSub = _channel!.stream.listen(
        _onMessage,
        onError: (err, stackTrace) {
          SocketLogger.logError(
            serviceName: 'DriverLocationUpdateSocketService',
            uri: currentUri,
            error: err,
            stackTrace: stackTrace is StackTrace ? stackTrace : null,
          );
          _setStatus('error');
          _scheduleReconnect();
        },
        onDone: () {
          SocketLogger.logDisconnect(
            serviceName: 'DriverLocationUpdateSocketService',
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
        serviceName: 'DriverLocationUpdateSocketService',
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
      serviceName: 'DriverLocationUpdateSocketService',
      uri: currentUri,
      reason: 'Manual disconnect',
    );
    _setStatus('disconnected');
  }

  void sendCurrentLocation({
    required double latitude,
    required double longitude,
    String driverStatus = 'Online',
  }) {
    final payload = {
      'latitude': latitude,
      'longitude': longitude,
      'driver_status': driverStatus,
    };
    SocketLogger.logSend(
      serviceName: 'DriverLocationUpdateSocketService',
      uri: currentUri,
      payload: payload,
    );
    _channel?.sink.add(jsonEncode(payload));
  }

  void _onMessage(dynamic data) {
    SocketLogger.logReceive(
      serviceName: 'DriverLocationUpdateSocketService',
      uri: currentUri,
      message: data,
    );

    try {
      if (data is String && data.trim().isNotEmpty) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          _messagesController.add(decoded);
          return;
        }
      }
      if (data is Map<String, dynamic>) {
        _messagesController.add(data);
      }
    } catch (_) {
      _messagesController.add({'message': data?.toString() ?? ''});
    }
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) return;

    _setStatus('reconnecting');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      connect().catchError((_) {});
    });
  }

  Uri _resolveUri() {
    const explicit = String.fromEnvironment('WS_DRIVER_LOCATION_URL');
    if (explicit.isNotEmpty) {
      return Uri.parse(explicit).replace(
        queryParameters: _authQuery(Uri.parse(explicit).queryParameters),
      );
    }

    final apiBase = Uri.parse(ApiConfig.baseUrl);

    return Uri(
      scheme: apiBase.scheme == 'https' ? 'wss' : 'ws',
      host: apiBase.host,
      port: apiBase.hasPort ? apiBase.port : null,
      path: '/ws/user/current/location/',
      queryParameters: _authQuery(null),
    );
  }

  Map<String, String>? _authQuery(Map<String, String>? existing) {
    final token = GetStorage().read('access_token')?.toString();
    final base = <String, String>{...?existing};
    if (token != null && token.isNotEmpty) {
      base['token'] = token;
    }
    return base.isEmpty ? null : base;
  }

  @override
  void onClose() {
    disconnect();
    _messagesController.close();
    super.onClose();
  }
}
