import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

part 'auth_api.dart';
part 'login_api.dart';
part 'password_api.dart';
part 'otp_api.dart';
part 'parcel_api.dart';
part 'notifications_api.dart';
part 'earnings_api.dart';
part 'ai_support_api.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://api.digaxy.com/api',
    defaultValue: 'http://10.10.29.119:8300/api',
  );
}

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final Object? body;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl, bool? enableLogging})
    : _client = client ?? http.Client(),
      _baseUrl = _normalizeBaseUrl(baseUrl ?? ApiConfig.baseUrl),
      _enableLogging = enableLogging ?? kDebugMode;

  final http.Client _client;
  final String _baseUrl;
  final bool _enableLogging;

  static String _normalizeBaseUrl(String baseUrl) {
    // Avoid trailing slash so we can safely join paths.
    if (baseUrl.endsWith('/')) return baseUrl.substring(0, baseUrl.length - 1);
    return baseUrl;
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath');
  }

  bool _isPublicAuthEndpoint(String path) {
    final clean = path.toLowerCase();
    return clean.contains('/auth/signup') ||
        clean.contains('/auth/customer/signup') ||
        clean.contains('/auth/driver/signup') ||
        clean.contains('/auth/helper/signup') ||
        clean.contains('/auth/login') ||
        clean.contains('/auth/otp/') ||
        clean.contains('/auth/password/reset');
  }

  Map<String, String> _buildHeaders(
    String path, {
    Map<String, String>? headers,
    bool isJson = true,
  }) {
    final box = GetStorage();
    final accessToken = box.read('access_token');
    final isPublic = _isPublicAuthEndpoint(path);
    final shouldAttachToken =
        accessToken is String && accessToken.isNotEmpty && !isPublic;

    return <String, String>{
      if (isJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (shouldAttachToken) 'Authorization': 'Bearer $accessToken',
      ...?headers,
    };
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path).replace(queryParameters: queryParameters);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: false);

    _logRequest(
      method: 'GET',
      uri: uri,
      headers: authHeaders,
      queryParameters: queryParameters,
    );

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(uri, headers: authHeaders);
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'GET',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'GET',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};

      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'GET',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: false);

    _logRequest(method: 'DELETE', uri: uri, headers: authHeaders);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.delete(uri, headers: authHeaders);
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'DELETE',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'DELETE',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};

      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'DELETE',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Object body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: true);

    _logRequest(method: 'POST', uri: uri, headers: authHeaders, body: body);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.post(
        uri,
        headers: authHeaders,
        body: jsonEncode(body),
      );
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'POST',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};

      // Some APIs return a list/primitive; wrap to keep call sites consistent.
      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'POST',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Object body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: true);

    _logRequest(method: 'PUT', uri: uri, headers: authHeaders, body: body);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.put(
        uri,
        headers: authHeaders,
        body: jsonEncode(body),
      );
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'PUT',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'PUT',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};

      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'PUT',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: true);

    _logRequest(method: 'PATCH', uri: uri, headers: authHeaders, body: body);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.patch(
        uri,
        headers: authHeaders,
        body: body == null ? null : jsonEncode(body),
      );
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'PATCH',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'PATCH',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};

      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'PATCH',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required Map<String, String> files, // field name -> file path
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: false);

    _logRequest(
      method: 'POST [Multipart]',
      uri: uri,
      headers: authHeaders,
      multipartFields: fields,
      multipartFiles: files,
    );

    final stopwatch = Stopwatch()..start();

    try {
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(fields);

      for (final entry in files.entries) {
        try {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value),
          );
        } catch (e) {
          _printLog('Error adding file ${entry.key}: $e', isError: true);
          rethrow;
        }
      }

      request.headers.addAll(authHeaders);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'POST [Multipart]',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'POST [Multipart]',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};

      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'POST [Multipart]',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patchMultipart(
    String path, {
    required Map<String, String> fields,
    required Map<String, String> files,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final authHeaders = _buildHeaders(path, headers: headers, isJson: false);

    _logRequest(
      method: 'PATCH [Multipart]',
      uri: uri,
      headers: authHeaders,
      multipartFields: fields,
      multipartFiles: files,
    );

    final stopwatch = Stopwatch()..start();

    try {
      final request = http.MultipartRequest('PATCH', uri);
      request.fields.addAll(fields);

      for (final entry in files.entries) {
        try {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value),
          );
        } catch (e) {
          _printLog('Error adding file ${entry.key}: $e', isError: true);
          rethrow;
        }
      }

      request.headers.addAll(authHeaders);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      final decoded = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(decoded, response.statusCode);
        _logError(
          method: 'PATCH [Multipart]',
          uri: uri,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          body: decoded ?? response.body,
          errorMessage: errorMessage,
        );

        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          body: decoded ?? response.body,
        );
      }

      _logResponse(
        method: 'PATCH [Multipart]',
        uri: uri,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: decoded ?? response.body,
      );

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded == null) return <String, dynamic>{};
      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      if (e is! ApiException) {
        stopwatch.stop();
        _logException(
          method: 'PATCH [Multipart]',
          uri: uri,
          duration: stopwatch.elapsed,
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  // --- Logging Helpers ---

  void _logRequest({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
    Map<String, String>? multipartFields,
    Map<String, String>? multipartFiles,
  }) {
    if (!_enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─── 🚀 [API REQUEST] ──────────────────────────────────────────',
    );
    buffer.writeln('│ Method  : $method');
    buffer.writeln('│ URL     : $uri');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('│ Params  : $queryParameters');
    }

    if (headers != null && headers.isNotEmpty) {
      final safeHeaders = Map<String, String>.from(headers);
      if (safeHeaders.containsKey('Authorization')) {
        final token = safeHeaders['Authorization']!;
        if (token.length > 20) {
          safeHeaders['Authorization'] =
              '${token.substring(0, 15)}... (truncated)';
        }
      }
      buffer.writeln('│ Headers : $safeHeaders');
    }

    if (body != null) {
      buffer.writeln('│ Body    :');
      final formattedBody = _prettyPrintObject(_redact(body));
      for (final line in formattedBody.split('\n')) {
        buffer.writeln('│   $line');
      }
    }

    if (multipartFields != null && multipartFields.isNotEmpty) {
      buffer.writeln('│ Form Fields: $multipartFields');
    }

    if (multipartFiles != null && multipartFiles.isNotEmpty) {
      buffer.writeln('│ Form Files : $multipartFiles');
    }

    buffer.write(
      '└───────────────────────────────────────────────────────────────',
    );
    _printLog(buffer.toString());
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required Duration duration,
    Object? body,
  }) {
    if (!_enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─── ✅ [API RESPONSE: $statusCode] (${duration.inMilliseconds}ms) ─────────────────────',
    );
    buffer.writeln('│ $method $uri');
    if (body != null) {
      buffer.writeln('│ Body:');
      final formattedBody = _prettyPrintObject(body);
      for (final line in formattedBody.split('\n')) {
        buffer.writeln('│   $line');
      }
    }
    buffer.write(
      '└───────────────────────────────────────────────────────────────',
    );
    _printLog(buffer.toString());
  }

  void _logError({
    required String method,
    required Uri uri,
    required int statusCode,
    required Duration duration,
    required String errorMessage,
    Object? body,
  }) {
    if (!_enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─── ❌ [API ERROR: $statusCode] (${duration.inMilliseconds}ms) ────────────────────────',
    );
    buffer.writeln('│ $method $uri');
    buffer.writeln('│ Error Message: $errorMessage');
    if (body != null) {
      buffer.writeln('│ Response Body:');
      final formattedBody = _prettyPrintObject(body);
      for (final line in formattedBody.split('\n')) {
        buffer.writeln('│   $line');
      }
    }
    buffer.write(
      '└───────────────────────────────────────────────────────────────',
    );
    _printLog(buffer.toString(), isError: true);
  }

  void _logException({
    required String method,
    required Uri uri,
    required Duration duration,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!_enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln(
      '┌─── 💥 [API NETWORK/CLIENT EXCEPTION] (${duration.inMilliseconds}ms) ──────────',
    );
    buffer.writeln('│ $method $uri');
    buffer.writeln('│ Exception: $error');
    if (stackTrace != null) {
      buffer.writeln('│ StackTrace:');
      final traceLines = stackTrace.toString().split('\n').take(5);
      for (final line in traceLines) {
        if (line.trim().isNotEmpty) {
          buffer.writeln('│   $line');
        }
      }
    }
    buffer.write(
      '└───────────────────────────────────────────────────────────────',
    );
    _printLog(buffer.toString(), isError: true);
  }

  void _printLog(String message, {bool isError = false}) {
    final formatted = isError
        ? message.split('\n').map((line) => '\x1B[31m$line\x1B[0m').join('\n')
        : message;

    developer.log(
      formatted,
      name: isError ? '\x1B[31mAPI.ERROR\x1B[0m' : 'API',
      level: isError ? 1000 : 800,
    );
  }

  String _prettyPrintObject(Object? object) {
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

  Object? _tryDecodeJson(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Object _redact(Object body) {
    if (body is Map) {
      return body.map((key, value) {
        final k = key.toString().toLowerCase();
        if (k.contains('password') ||
            k.contains('token') ||
            k.contains('secret') ||
            k.contains('current_password') ||
            k.contains('new_password') ||
            k.contains('confirm_password')) {
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

  String _extractErrorMessage(Object? decoded, int statusCode) {
    if (decoded is Map) {
      if (decoded['message'] is String &&
          (decoded['message'] as String).trim().isNotEmpty) {
        return (decoded['message'] as String).trim();
      }
      if (decoded['detail'] is String &&
          (decoded['detail'] as String).trim().isNotEmpty) {
        return (decoded['detail'] as String).trim();
      }
      if (decoded['error'] is String &&
          (decoded['error'] as String).trim().isNotEmpty) {
        return (decoded['error'] as String).trim();
      }
      if (decoded['non_field_errors'] is List &&
          (decoded['non_field_errors'] as List).isNotEmpty) {
        return (decoded['non_field_errors'] as List)
            .map((e) => '$e')
            .join('\n');
      }
      final List<String> errorMessages = [];
      decoded.forEach((key, value) {
        if (key == 'status' ||
            key == 'code' ||
            key == 'status_code' ||
            key == 'success') {
          return;
        }
        if (value is List && value.isNotEmpty) {
          errorMessages.add('$key: ${value.join(", ")}');
        } else if (value is String && value.trim().isNotEmpty) {
          errorMessages.add('$key: $value');
        } else if (value is Map) {
          value.forEach((subKey, subVal) {
            if (subVal is List) {
              errorMessages.add('$key.$subKey: ${subVal.join(", ")}');
            } else if (subVal != null) {
              errorMessages.add('$key.$subKey: $subVal');
            }
          });
        }
      });
      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }
    } else if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }
    return 'Request failed ($statusCode)';
  }
}
