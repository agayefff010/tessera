import 'dart:convert';

/// JWT payload oxuma (imza yoxlanmır — yalnız client tərəfdə `exp` üçün).
abstract final class JwtPayload {
  static Map<String, dynamic>? decode(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final json = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  /// Token müddəti bitibsə `true`. `exp` yoxdursa `false` (server yoxlasın).
  static bool isExpired(String token, {Duration leeway = const Duration(seconds: 30)}) {
    final payload = decode(token);
    if (payload == null) return false;
    final exp = payload['exp'];
    if (exp is! num) return false;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      (exp * 1000).round(),
      isUtc: true,
    );
    return DateTime.now().toUtc().isAfter(expiresAt.subtract(leeway));
  }

  static Duration? timeToLive(String token) {
    final payload = decode(token);
    if (payload == null) return null;
    final exp = payload['exp'];
    if (exp is! num) return null;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      (exp * 1000).round(),
      isUtc: true,
    );
    final remaining = expiresAt.difference(DateTime.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
