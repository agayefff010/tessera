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

    final token = _tokenFromHttpHeaders(response.headers) ??
        AuthTokenParser.fromBody(data);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthHttpResponse(
        statusCode: response.statusCode,
        data: data ?? <String, dynamic>{},
        token: token,
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

String? _tokenFromHttpHeaders(HttpHeaders headers) {
  String? found;

  headers.forEach((name, values) {
    if (name.toLowerCase() != 'set-cookie') return;
    found ??= AuthTokenParser.fromSetCookieValues(values);
  });

  return found;
}

String? _messageFromBody(Map<String, dynamic>? data) {
  if (data == null) return null;
  final message = data['message'];
  if (message is String && message.isNotEmpty) return message;
  final error = data['error'];
  if (error is String && error.isNotEmpty) return error;
  return null;
}
