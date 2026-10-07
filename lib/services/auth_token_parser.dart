/// Login/register/refresh cavabından JWT token çıxarma.
/// Backend cookie-ləri: `accessToken`, `refreshToken` (Set-Cookie).
abstract final class AuthTokenParser {
  static const _accessKeys = [
    'accessToken',
    'access_token',
    'token',
    'jwt',
  ];

  static const _refreshKeys = [
    'refreshToken',
    'refresh_token',
  ];

  /// Set-Cookie access — əvvəl `accessToken=`.
  static const accessCookiePrefixes = [
    'accessToken=',
    'access_token=',
    'token=',
    'Token=',
    'TOKEN=',
  ];

  /// Set-Cookie refresh — əvvəl `refreshToken=`.
  static const refreshCookiePrefixes = [
    'refreshToken=',
    'refresh_token=',
    'RefreshToken=',
  ];

  static String? fromBody(Map<String, dynamic>? data) {
    if (data == null) return null;

    for (final key in _accessKeys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }

    final tokens = data['tokens'];
    if (tokens is Map<String, dynamic>) {
      final nested = fromBody(tokens);
      if (nested != null) return nested;
    }

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return fromBody(nested);
    }
    return null;
  }

  static String? refreshFromBody(Map<String, dynamic>? data) {
    if (data == null) return null;

    for (final key in _refreshKeys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }

    final tokens = data['tokens'];
    if (tokens is Map<String, dynamic>) {
      final nested = refreshFromBody(tokens);
      if (nested != null) return nested;
    }

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return refreshFromBody(nested);
    }
    return null;
  }

  static String? fromSetCookieValue(
    String raw, {
    List<String> prefixes = accessCookiePrefixes,
  }) {
    final trimmed = raw.trim();
    for (final prefix in prefixes) {
      // Word-boundary: `refreshToken=` içində `Token=` tutmasın.
      final pattern = RegExp(
        '(?:^|[;,\\s])${RegExp.escape(prefix)}',
        caseSensitive: true,
      );
      final match = pattern.firstMatch(trimmed);
      if (match == null) {
        // Bəzən header tək cookie-dir: `accessToken=...`
        if (trimmed.startsWith(prefix)) {
          var value = trimmed.substring(prefix.length);
          final end = value.indexOf(';');
          if (end != -1) value = value.substring(0, end);
          value = value.trim();
          if (value.isNotEmpty) return value;
        }
        continue;
      }

      final valueStart = match.end;
      var value = trimmed.substring(valueStart);
      final end = value.indexOf(';');
      if (end != -1) value = value.substring(0, end);
      value = value.trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static String? fromSetCookieValues(Iterable<String> values) {
    for (final value in values) {
      final token = fromSetCookieValue(value);
      if (token != null) return token;
    }
    return null;
  }

  static String? refreshFromSetCookieValues(Iterable<String> values) {
    for (final value in values) {
      final token = fromSetCookieValue(
        value,
        prefixes: refreshCookiePrefixes,
      );
      if (token != null) return token;
    }
    return null;
  }

  static String? fromHeaderMap(Map<String, String> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() != 'set-cookie') continue;
      final token = fromSetCookieValue(entry.value);
      if (token != null) return token;
    }
    return null;
  }

  static String? refreshFromHeaderMap(Map<String, String> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() != 'set-cookie') continue;
      final token = fromSetCookieValue(
        entry.value,
        prefixes: refreshCookiePrefixes,
      );
      if (token != null) return token;
    }
    return null;
  }
}
