import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_cookie_store.dart';
import 'auth_http.dart';
import 'auth_token_parser.dart';

Future<AuthHttpResponse> postAuth(
  String path, {
  required Map<String, dynamic> body,
  String? cookieHeader,
}) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}$path');
  final client = HttpClient();
  final store = AuthCookieStore.instance;

  // Refresh: body-dəki refreshToken Cookie header-ə də əlavə et.
  final outgoingCookie = _buildOutgoingCookie(
    explicit: cookieHeader,
    body: body,
    store: store,
  );

  try {
    final request = await client.postUrl(uri);
    final payload = utf8.encode(jsonEncode(body));
    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Accept', 'application/json');
    if (outgoingCookie != null && outgoingCookie.isNotEmpty) {
      request.headers.set('Cookie', outgoingCookie);
    }
    request.contentLength = payload.length;
    request.add(payload);

    

    final response = await request.close().timeout(const Duration(seconds: 30));
    final responseBody = await response.transform(utf8.decoder).join();

    final headerCookies = _cookieHeaderValues(response.headers);
  
    for (final c in response.cookies) {
      print('[auth]   cookie ${c.name}=${_preview(c.value)}');
    }
    

    Map<String, dynamic>? data;
    if (responseBody.isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }

    // Cookie-based auth: əvvəl response.cookies, sonra Set-Cookie header.
    // JSON token gözlənilmir (refresh yalnız { success: true } qaytarır).
    final fromCookies = _tokensFromResponseCookies(response.cookies);
    final token = fromCookies.access ??
        AuthTokenParser.fromSetCookieValues(headerCookies) ??
        AuthTokenParser.fromBody(data);
    final refreshToken = fromCookies.refresh ??
        AuthTokenParser.refreshFromSetCookieValues(headerCookies) ??
        AuthTokenParser.refreshFromBody(data);

   

    if (response.statusCode >= 200 && response.statusCode < 300) {
      store.update(accessToken: token, refreshToken: refreshToken);
      print(
        '[auth] CookieStore after $path | '
        'access=${store.accessToken == null ? "NULL" : "YES"} | '
        'refresh=${store.refreshToken == null ? "NULL" : "YES"}',
      );

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

String? _buildOutgoingCookie({
  required String? explicit,
  required Map<String, dynamic> body,
  required AuthCookieStore store,
}) {
  if (explicit != null && explicit.isNotEmpty) return explicit;

  final access = store.accessToken;
  var refresh = store.refreshToken;
  final bodyRefresh = body['refreshToken']?.toString();
  if (bodyRefresh != null && bodyRefresh.isNotEmpty) {
    refresh = bodyRefresh;
  }

  final parts = <String>[];
  if (access != null && access.isNotEmpty) {
    parts.add('accessToken=$access');
  }
  if (refresh != null && refresh.isNotEmpty) {
    parts.add('refreshToken=$refresh');
  }
  if (parts.isEmpty) return null;
  return parts.join('; ');
}

({String? access, String? refresh}) _tokensFromResponseCookies(
  List<Cookie> cookies,
) {
  String? access;
  String? refresh;
  for (final cookie in cookies) {
    final name = cookie.name.trim();
    final value = cookie.value.trim();
    if (value.isEmpty) continue;

    // Exact backend names first (case-sensitive).
    if (name == 'accessToken') {
      access ??= value;
      continue;
    }
    if (name == 'refreshToken') {
      refresh ??= value;
      continue;
    }

    final lower = name.toLowerCase();
    if (lower == 'accesstoken' ||
        lower == 'access_token' ||
        lower == 'token' ||
        lower == 'jwt') {
      access ??= value;
    } else if (lower == 'refreshtoken' || lower == 'refresh_token') {
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

String _preview(String value) {
  if (value.length <= 24) return value;
  return '${value.substring(0, 12)}...${value.substring(value.length - 8)} '
      '(len=${value.length})';
}

String? _messageFromBody(Map<String, dynamic>? data) {
  if (data == null) return null;
  final message = data['message'];
  if (message is String && message.isNotEmpty) return message;
  final error = data['error'];
  if (error is String && error.isNotEmpty) return error;
  return null;
}
