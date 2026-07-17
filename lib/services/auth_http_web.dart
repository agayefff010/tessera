import 'dart:convert';

import 'package:http/browser_client.dart' as browser;
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_http.dart';
import 'auth_token_parser.dart';

/// Web — brauzer Set-Cookie header-ini oxuya bilmir (HttpOnly + CORS).
Future<AuthHttpResponse> postAuth(
  String path, {
  required Map<String, dynamic> body,
}) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  final client = browser.BrowserClient()..withCredentials = true;

  http.Response response;
  try {
    response = await client
        .post(
          uri,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
  } on Exception {
    throw const ApiException('Şəbəkə xətası. İnternet bağlantınızı yoxlayın.');
  } finally {
    client.close();
  }

  Map<String, dynamic>? data;
  if (response.body.isNotEmpty) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
  }

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final token = AuthTokenParser.fromHeaderMap(response.headers) ??
        AuthTokenParser.fromBody(data);
    final refreshToken =
        AuthTokenParser.refreshFromHeaderMap(response.headers) ??
            AuthTokenParser.refreshFromBody(data);
    return AuthHttpResponse(
      statusCode: response.statusCode,
      data: data ?? <String, dynamic>{},
      token: token,
      refreshToken: refreshToken,
    );
  }

  final message =
      _messageFromBody(data) ?? 'Server xətası (${response.statusCode})';
  throw ApiException(message, statusCode: response.statusCode);
}

String? _messageFromBody(Map<String, dynamic>? data) {
  if (data == null) return null;
  final message = data['message'];
  if (message is String && message.isNotEmpty) return message;
  return null;
}
