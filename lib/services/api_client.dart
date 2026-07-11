import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiPostResult {
  const ApiPostResult({
    required this.data,
    this.token,
  });

  final Map<String, dynamic> data;
  final String? token;
}

/// HTTPS JSON API klienti.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    String? bearerToken,
  }) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }

    final headers = <String, String>{'Accept': 'application/json'};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    http.Response response;
    try {
      response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const ApiException(
        'Şəbəkə xətası. İnternet bağlantınızı yoxlayın.',
      );
    }

    Map<String, dynamic>? data;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        // JSON olmayan cavab
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data ?? <String, dynamic>{};
    }

    final message = _extractMessage(data) ??
        'Server xətası (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<void> delete(
    String path, {
    String? bearerToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    http.Response response;
    try {
      response = await _client
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const ApiException(
        'Şəbəkə xətası. İnternet bağlantınızı yoxlayın.',
      );
    }

    Map<String, dynamic>? data;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = _extractMessage(data) ??
        'Server xətası (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    http.Response response;
    try {
      response = await _client
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const ApiException(
        'Şəbəkə xətası. İnternet bağlantınızı yoxlayın.',
      );
    }

    Map<String, dynamic>? data;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data ?? <String, dynamic>{};
    }

    final message = _extractMessage(data) ??
        'Server xətası (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    http.Response response;
    try {
      response = await _client
          .patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const ApiException(
        'Şəbəkə xətası. İnternet bağlantınızı yoxlayın.',
      );
    }

    Map<String, dynamic>? data;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data ?? <String, dynamic>{};
    }

    final message = _extractMessage(data) ??
        'Server xətası (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<ApiPostResult> post(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    http.Response response;
    try {
      response = await _client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const ApiException(
        'Şəbəkə xətası. İnternet bağlantınızı yoxlayın.',
      );
    }

    Map<String, dynamic>? data;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        // JSON olmayan cavab
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiPostResult(
        data: data ?? <String, dynamic>{},
        token: _tokenFromHeaders(response.headers) ?? data?['token']?.toString(),
      );
    }

    final message = _extractMessage(data) ??
        'Server xətası (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  /// Backend JWT-ni `Set-Cookie: token=...` ilə göndərir.
  static String? _tokenFromHeaders(Map<String, String> headers) {
    final raw = headers['set-cookie'] ?? headers['Set-Cookie'];
    if (raw == null || raw.isEmpty) return null;

    const prefix = 'token=';
    final start = raw.indexOf(prefix);
    if (start == -1) return null;

    var value = raw.substring(start + prefix.length);
    final end = value.indexOf(';');
    if (end != -1) {
      value = value.substring(0, end);
    }
    return value.trim().isEmpty ? null : value.trim();
  }

  String? _extractMessage(Map<String, dynamic>? data) {
    if (data == null) return null;
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
    return null;
  }

  void dispose() => _client.close();
}
