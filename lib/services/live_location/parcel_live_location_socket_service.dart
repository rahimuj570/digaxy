import 'dart:async';
import 'dart:convert';

import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/services/websocket/socket_logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ParcelLiveLocation {
  final double? latitude;
  final double? longitude;
  final String? message;
  final Map<String, dynamic> raw;

  const ParcelLiveLocation({
    required this.latitude,
    required this.longitude,
    required this.message,
    required this.raw,
  });
}

class ParcelLiveLocationSocketService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _socketSub;
  Timer? _reconnectTimer;
  bool _manualDisconnect = false;
  String? _activeParcelId;
  Uri? _currentUri;
  Uri? get currentUri =>
      _currentUri ??
      (_activeParcelId != null ? _resolveUri(parcelId: _activeParcelId!) : null);
  final connectionStatus = 'disconnected'.obs;

  bool get isConnected => _channel != null && _activeParcelId != null;

  void _setStatus(String status) {
    connectionStatus.value = status;
  }

  final _updatesController = StreamController<ParcelLiveLocation>.broadcast(
    sync: true,
  );

  Stream<ParcelLiveLocation> get updates => _updatesController.stream;

  Future<void> connect({required String parcelId}) async {
    _setStatus('connecting');
    final cleaned = parcelId.trim();
    if (cleaned.isEmpty) return;

    _activeParcelId = cleaned;
    _manualDisconnect = false;

    await _socketSub?.cancel();
    _socketSub = null;
    _channel = null;

    final uri = _resolveUri(parcelId: cleaned);
    _currentUri = uri;

    SocketLogger.logConnect(
      serviceName: 'ParcelLiveLocationSocketService (Parcel: #$cleaned)',
      uri: uri,
    );

    try {
      _channel = WebSocketChannel.connect(uri);

      _socketSub = _channel!.stream.listen(
        _onMessage,
        onError: (err, stackTrace) {
          SocketLogger.logError(
            serviceName: 'ParcelLiveLocationSocketService (Parcel: #$_activeParcelId)',
            uri: currentUri,
            error: err,
            stackTrace: stackTrace is StackTrace ? stackTrace : null,
          );
          _setStatus('error');
          _scheduleReconnect();
        },
        onDone: () {
          SocketLogger.logDisconnect(
            serviceName: 'ParcelLiveLocationSocketService (Parcel: #$_activeParcelId)',
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
        serviceName: 'ParcelLiveLocationSocketService (Parcel: #$_activeParcelId)',
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
      serviceName: 'ParcelLiveLocationSocketService (Parcel: #$_activeParcelId)',
      uri: currentUri,
      reason: 'Manual disconnect',
    );
    _activeParcelId = null;
    _setStatus('disconnected');
  }

  void sendLiveLocation({required double latitude, required double longitude}) {
    if (_activeParcelId == null || _channel == null) {
      return;
    }
    final payload = {
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
    };
    SocketLogger.logSend(
      serviceName: 'ParcelLiveLocationSocketService (Parcel: #$_activeParcelId)',
      uri: currentUri,
      payload: payload,
    );
    _channel?.sink.add(jsonEncode(payload));
  }

  void _onMessage(dynamic data) {
    SocketLogger.logReceive(
      serviceName: 'ParcelLiveLocationSocketService (Parcel: #$_activeParcelId)',
      uri: currentUri,
      message: data,
    );
    try {
      Map<String, dynamic> payload;

      if (data is String && data.trim().isNotEmpty) {
        final decoded = jsonDecode(data);
        if (decoded is! Map<String, dynamic>) return;
        payload = decoded;
      } else if (data is Map<String, dynamic>) {
        payload = data;
      } else {
        return;
      }

      final lat = _toDouble(payload['latitude'] ?? payload['lat']);
      final lng = _toDouble(payload['longitude'] ?? payload['lng']);
      final msg = payload['message']?.toString();

      _updatesController.add(
        ParcelLiveLocation(
          latitude: lat,
          longitude: lng,
          message: msg,
          raw: payload,
        ),
      );
    } catch (_) {
      // ignore malformed messages
    }
  }

  double? _toDouble(dynamic value) {
    return double.tryParse((value ?? '').toString());
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) return;
    final parcelId = _activeParcelId;
    if (parcelId == null || parcelId.isEmpty) return;

    _setStatus('reconnecting');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      connect(parcelId: parcelId).catchError((_) {});
    });
  }

  Uri _resolveUri({required String parcelId}) {
    const explicitBase = String.fromEnvironment('WS_LIVE_LOCATION_BASE_URL');
    if (explicitBase.isNotEmpty) {
      final explicit = Uri.parse(explicitBase);
      final normalized = explicit.path.endsWith('/')
          ? explicit.path
          : '${explicit.path}/';
      return explicit.replace(
        path: '$normalized$parcelId/',
        queryParameters: _authQuery(explicit.queryParameters),
      );
    }

    final apiBase = Uri.parse(ApiConfig.baseUrl);

    return Uri(
      scheme: apiBase.scheme == 'https' ? 'wss' : 'ws',
      host: apiBase.host,
      port: apiBase.hasPort ? apiBase.port : null,
      path: '/ws/live/location/$parcelId/',
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
    _updatesController.close();
    super.onClose();
  }
}
