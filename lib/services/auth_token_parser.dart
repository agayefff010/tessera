/// Login/register cavabından JWT token çıxarma.
abstract final class AuthTokenParser {
  static const _tokenKeys = [
    'token',
    'accessToken',
    'access_token',
    'jwt',
  ];

  static String? fromBody(Map<String, dynamic>? data) {
    if (data == null) return null;

    for (final key in _tokenKeys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return fromBody(nested);
    }
    return null;
  }

  static String? fromSetCookieValue(String raw) {
    final trimmed = raw.trim();
    for (final prefix in const ['token=', 'Token=', 'TOKEN=']) {
      final start = trimmed.indexOf(prefix);
      if (start == -1) continue;
      var value = trimmed.substring(start + prefix.length);
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

  static String? fromHeaderMap(Map<String, String> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() != 'set-cookie') continue;
      final token = fromSetCookieValue(entry.value);
      if (token != null) return token;
    }
    return null;
  }
}
