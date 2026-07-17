import 'auth_http_io.dart' if (dart.library.html) 'auth_http_web.dart' as impl;

class AuthHttpResponse {
  const AuthHttpResponse({
    required this.statusCode,
    required this.data,
    this.token,
    this.refreshToken,
  });

  final int statusCode;
  final Map<String, dynamic> data;
  final String? token;
  final String? refreshToken;
}

/// Login/register — Set-Cookie token oxumaq üçün platform xüsusi klient.
Future<AuthHttpResponse> postAuth(
  String path, {
  required Map<String, dynamic> body,
}) =>
    impl.postAuth(path, body: body);
