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

  /// Access JWT — əsasən Set-Cookie `accessToken`.
  final String? token;

  /// Refresh JWT — əsasən Set-Cookie `refreshToken`.
  final String? refreshToken;
}

/// Login / register / refresh — Set-Cookie oxumaq üçün platform klient.
///
/// [cookieHeader] göndərilərsə `Cookie:` header yazılır (refresh üçün).
Future<AuthHttpResponse> postAuth(
  String path, {
  required Map<String, dynamic> body,
  String? cookieHeader,
}) =>
    impl.postAuth(path, body: body, cookieHeader: cookieHeader);
