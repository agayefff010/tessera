/// Login/refresh Set-Cookie dəyərlərini növbəti auth sorğularına göndərmək üçün.
/// HttpClient cookie jar saxlamır — əl ilə saxlayırıq.
class AuthCookieStore {
  AuthCookieStore._();

  static final AuthCookieStore instance = AuthCookieStore._();

  String? accessToken;
  String? refreshToken;

  void update({
    String? accessToken,
    String? refreshToken,
  }) {
    if (accessToken != null && accessToken.isNotEmpty) {
      this.accessToken = accessToken;
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      this.refreshToken = refreshToken;
    }
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
  }

  /// `Cookie: accessToken=...; refreshToken=...`
  String? get cookieHeader {
    final parts = <String>[];
    if (accessToken != null && accessToken!.isNotEmpty) {
      parts.add('accessToken=$accessToken');
    }
    if (refreshToken != null && refreshToken!.isNotEmpty) {
      parts.add('refreshToken=$refreshToken');
    }
    if (parts.isEmpty) return null;
    return parts.join('; ');
  }
}
