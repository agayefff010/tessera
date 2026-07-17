import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_http.dart';
import 'auth_token_parser.dart';

Future<AuthHttpResponse> postAuth(
  String path, {
  required Map<String, dynamic> body,
}) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  final client = HttpClient();

  try {
    final request = await client.postUrl(uri);
    final payload = utf8.encode(jsonEncode(body));
    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Accept', 'application/json');
    request.contentLength = payload.length;
    request.add(payload);

    final response = await request.close().timeout(const Duration(seconds: 30));
    final responseBody = await response.transform(utf8.decoder).join();

    Map<String, dynamic>? data;
    if (responseBody.isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }

    // Dart HttpClient Set-Cookie-ni əsasən `response.cookies`-ə parse edir;
    // raw header bəzən boş və ya birləşmiş gəlir.
    final fromCookies = _tokensFromResponseCookies(response.cookies);
    final headerCookies = _cookieHeaderValues(response.headers);
    final token = fromCookies.access ??
        AuthTokenParser.fromSetCookieValues(headerCookies) ??
        _bearerFromHeaders(response.headers) ??
        AuthTokenParser.fromBody(data);
    final refreshToken = fromCookies.refresh ??
        AuthTokenParser.refreshFromSetCookieValues(headerCookies) ??
        AuthTokenParser.refreshFromBody(data);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthHttpResponse(
        statusCode: response.statusCode,
        data: data ?? <String, dynamic>{},
        token: token,
        refreshToken: refreshToken,
      );
    }

    final message = _messageFromBody(data) ??
        'Server xətası (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  } on ApiException {
    rethrow;
  } on SocketException {
    throw const ApiException('Şəbəkə xətası. İnternet bağlantınızı yoxlayın.');
  } on HttpException {
    throw const ApiException('Şəbəkə xətası. İnternet bağlantınızı yoxlayın.');
  } on Exception {
    throw const ApiException('Şəbəkə xətası. İnternet bağlantınızı yoxlayın.');
  } finally {
    client.close(force: true);
  }
}

({String? access, String? refresh}) _tokensFromResponseCookies(
  List<Cookie> cookies,
) {
  String? access;
  String? refresh;
  for (final cookie in cookies) {
    final name = cookie.name.toLowerCase().trim();
    final value = cookie.value.trim();
    if (value.isEmpty) continue;

    if (name == 'token' ||
        name == 'accesstoken' ||
        name == 'access_token' ||
        name == 'jwt') {
      access ??= value;
    } else if (name == 'refreshtoken' || name == 'refresh_token') {
      refresh ??= value;
    }
  }
  return (access: access, refresh: refresh);
}

List<String> _cookieHeaderValues(HttpHeaders headers) {
  final values = <String>[];
  headers.forEach((name, cookieValues) {
    if (name.toLowerCase() != 'set-cookie') return;
    values.addAll(cookieValues);
  });
  return values;
}

String? _bearerFromHeaders(HttpHeaders headers) {
  final auth = headers.value('authorization') ?? headers.value('Authorization');
  if (auth == null || auth.isEmpty) return null;
  final trimmed = auth.trim();
  const prefix = 'Bearer ';
  if (trimmed.length > prefix.length &&
      trimmed.toLowerCase().startsWith('bearer ')) {
    final token = trimmed.substring(prefix.length).trim();
    return token.isEmpty ? null : token;
  }
  return null;
}

String? _messageFromBody(Map<String, dynamic>? data) {
  if (data == null) return null;
  final message = data['message'];
  if (message is String && message.isNotEmpty) return message;
  final error = data['error'];
  if (error is String && error.isNotEmpty) return error;
  return null;
}
