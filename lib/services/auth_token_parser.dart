/// Login/register/refresh cavabından JWT token çıxarma.
abstract final class AuthTokenParser {
  static const _accessKeys = [
    'token',
    'accessToken',
    'access_token',
    'jwt',
  ];

  static const _refreshKeys = [
    'refreshToken',
    'refresh_token',
  ];

  static String? fromBody(Map<String, dynamic>? data) {
    if (data == null) return null;

    for (final key in _accessKeys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }

    // { tokens: { accessToken, refreshToken } }
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
    List<String> prefixes = const ['token=', 'Token=', 'TOKEN='],
  }) {
    final trimmed = raw.trim();
    for (final prefix in prefixes) {
      // Word-boundary: `refreshToken=` içində `Token=` tutmasın.
      final pattern = RegExp(
        '(?:^|[;,\\s])$prefix',
        caseSensitive: true,
      );
      final match = pattern.firstMatch(trimmed);
      if (match == null) continue;

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
    const prefixes = [
      'refreshToken=',
      'refresh_token=',
      'RefreshToken=',
    ];
    for (final value in values) {
      final token = fromSetCookieValue(value, prefixes: prefixes);
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
    const prefixes = [
      'refreshToken=',
      'refresh_token=',
      'RefreshToken=',
    ];
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() != 'set-cookie') continue;
      final token = fromSetCookieValue(entry.value, prefixes: prefixes);
      if (token != null) return token;
    }
    return null;
  }
}
