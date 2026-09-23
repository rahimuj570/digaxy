import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class SocketLogger {
  SocketLogger._();

  static bool enableLogging = kDebugMode;

  static void logConnect({
    required String serviceName,
    required Uri uri,
  }) {
    if (!enableLogging) return;

    final safeUri = _sanitizeUri(uri);
    final buffer = StringBuffer();
    buffer.writeln('┌─── 🔌 [WS CONNECT] ──────────────────────────────────────────');
    buffer.writeln('│ Service : $serviceName');
    buffer.writeln('│ URL     : $safeUri');
    buffer.write('└───────────────────────────────────────────────────────────────');
    _printLog(buffer.toString(), tag: 'WS.CONNECT');
  }

  static void logSend({
    required String serviceName,
    required Uri? uri,
    required Object payload,
  }) {
    if (!enableLogging) return;

    final safeUri = uri != null ? _sanitizeUri(uri) : 'unknown';
    final buffer = StringBuffer();
    buffer.writeln('┌─── 🚀 [WS SEND / REQUEST] ────────────────────────────────────');
    buffer.writeln('│ Service : $serviceName');
    buffer.writeln('│ URL     : $safeUri');
    buffer.writeln('│ Payload :');
    final formattedBody = _prettyPrintObject(_redact(payload));
    for (final line in formattedBody.split('\n')) {
      buffer.writeln('│   $line');
    }
    buffer.write('└───────────────────────────────────────────────────────────────');
    _printLog(buffer.toString(), tag: 'WS.SEND');
  }

  static void logReceive({
    required String serviceName,
    required Uri? uri,
    required Object message,
  }) {
    if (!enableLogging) return;

    final safeUri = uri != null ? _sanitizeUri(uri) : 'unknown';
    final buffer = StringBuffer();
    buffer.writeln('┌─── 📩 [WS MESSAGE / RESPONSE] ────────────────────────────────');
    buffer.writeln('│ Service : $serviceName');
    buffer.writeln('│ URL     : $safeUri');
    buffer.writeln('│ Message :');
    final formattedBody = _prettyPrintObject(message);
    for (final line in formattedBody.split('\n')) {
      buffer.writeln('│   $line');
    }
    buffer.write('└───────────────────────────────────────────────────────────────');
    _printLog(buffer.toString(), tag: 'WS.RECEIVE');
  }

  static void logError({
    required String serviceName,
    required Uri? uri,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!enableLogging) return;

    final safeUri = uri != null ? _sanitizeUri(uri) : 'unknown';
    final buffer = StringBuffer();
    buffer.writeln('┌─── ❌ [WS ERROR] ─────────────────────────────────────────────');
    buffer.writeln('│ Service : $serviceName');
    buffer.writeln('│ URL     : $safeUri');
    buffer.writeln('│ Error   : $error');
    if (stackTrace != null) {
      buffer.writeln('│ StackTrace:');
      final traceLines = stackTrace.toString().split('\n').take(5);
      for (final line in traceLines) {
        if (line.trim().isNotEmpty) {
          buffer.writeln('│   $line');
        }
      }
    }
    buffer.write('└───────────────────────────────────────────────────────────────');
    _printLog(buffer.toString(), tag: 'WS.ERROR', isError: true);
  }

  static void logDisconnect({
    required String serviceName,
    required Uri? uri,
    String? reason,
  }) {
    if (!enableLogging) return;

    final safeUri = uri != null ? _sanitizeUri(uri) : 'unknown';
    final buffer = StringBuffer();
    buffer.writeln('┌─── 🔌 [WS DISCONNECTED] ──────────────────────────────────────');
    buffer.writeln('│ Service : $serviceName');
    buffer.writeln('│ URL     : $safeUri');
    if (reason != null && reason.isNotEmpty) {
      buffer.writeln('│ Reason  : $reason');
    }
    buffer.write('└───────────────────────────────────────────────────────────────');
    _printLog(buffer.toString(), tag: 'WS.DISCONNECT');
  }

  static Uri _sanitizeUri(Uri uri) {
    if (!uri.queryParameters.containsKey('token')) return uri;
    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return uri;

    final safeToken = token.length > 15 ? '${token.substring(0, 10)}... (truncated)' : '***';
    final newQuery = Map<String, String>.from(uri.queryParameters);
    newQuery['token'] = safeToken;
    return uri.replace(queryParameters: newQuery);
  }

  static String _prettyPrintObject(Object? object) {
    if (object == null) return 'null';
    if (object is String) {
      final trimmed = object.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          return const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          return object;
        }
      }
      return object;
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(object);
    } catch (_) {
      return object.toString();
    }
  }

  static Object _redact(Object body) {
    if (body is Map) {
      return body.map((key, value) {
        final k = key.toString().toLowerCase();
        if (k.contains('password') ||
            k.contains('token') ||
            k.contains('secret')) {
          return MapEntry(key, '***');
        }
        if (value is Map || value is List) {
          return MapEntry(key, _redact(value as Object));
        }
        return MapEntry(key, value);
      });
    }
    if (body is List) {
      return body.map((e) {
        if (e is Map || e is List) return _redact(e as Object);
        return e;
      }).toList();
    }
    return body;
  }

  static void _printLog(String message, {required String tag, bool isError = false}) {
    final formatted = isError
        ? message.split('\n').map((line) => '\x1B[31m$line\x1B[0m').join('\n')
        : message;

    developer.log(
      formatted,
      name: isError ? '\x1B[31m$tag\x1B[0m' : tag,
      level: isError ? 1000 : 800,
    );
  }
}
