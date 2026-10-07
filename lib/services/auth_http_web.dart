import 'dart:convert';

import 'package:http/browser_client.dart' as browser;
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_cookie_store.dart';
import 'auth_http.dart';
import 'auth_token_parser.dart';

/// Web — brauzer Set-Cookie-ni JS-ə vermir (HttpOnly).
/// withCredentials ilə brauzer cookie jar işləyir; body-dən oxumaq fallbackdır.
Future<AuthHttpResponse> postAuth(
  String path, {
  required Map<String, dynamic> body,
  String? cookieHeader,
}) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  final client = browser.BrowserClient()..withCredentials = true;

  http.Response response;
  try {
    print('[auth][web] POST $path');
    print('[auth][web] cookieHeader ignored (browser jar): $cookieHeader');
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

  print('[auth][web] Status: ${response.statusCode}');
  print('[auth][web] Body: ${response.body}');

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final token = AuthTokenParser.fromHeaderMap(response.headers) ??
        AuthTokenParser.fromBody(data);
    final refreshToken =
        AuthTokenParser.refreshFromHeaderMap(response.headers) ??
            AuthTokenParser.refreshFromBody(data);

    // Web-də HttpOnly cookie oxunmur.
    // Refresh cavabında JSON token yoxdursa — köhnə access-i "yeni" kimi qəbul etmə.
    final store = AuthCookieStore.instance;
    final isRefresh = path.contains('refresh');
    final resolvedAccess =
        token ?? (isRefresh ? null : store.accessToken);
    final resolvedRefresh = refreshToken ?? store.refreshToken;


    store.update(
      accessToken: resolvedAccess,
      refreshToken: resolvedRefresh,
    );

    return AuthHttpResponse(
      statusCode: response.statusCode,
      data: data ?? <String, dynamic>{},
      token: resolvedAccess,
      refreshToken: resolvedRefresh,
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
