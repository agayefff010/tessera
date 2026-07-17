import 'package:flutter/foundation.dart';

import '../services/auth_token_parser.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.phone,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  final String id;
  final String name;
  final String email;
  final String? role;
  final String? phone;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  AuthUser copyWith({
    String? name,
    String? phone,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      phone: phone ?? this.phone,
    );
  }
}

@immutable
class AuthResult {
  const AuthResult({
    required this.token,
    required this.user,
    this.refreshToken,
  });

  factory AuthResult.fromApiResponse(
    Map<String, dynamic> json, {
    String? token,
    String? refreshToken,
  }) {
    final userJson = _extractUser(json);
    if (userJson == null) {
      throw const ApiParseException('Cavabda istifadəçi məlumatı yoxdur');
    }

    final resolvedToken = token ?? AuthTokenParser.fromBody(json);
    if (resolvedToken == null || resolvedToken.isEmpty) {
      throw AuthParseException(
        kIsWeb
            ? 'Web brauzerində login işləmir: server token yalnız cookie-də göndərir. '
                'Android, iOS və ya Windows build istifadə edin.'
            : 'Server token qaytarmadı. Token cookie-dən oxunmadı — '
                'backend token-i JSON cavabına da əlavə etməlidir.',
      );
    }

    final resolvedRefresh =
        refreshToken ?? AuthTokenParser.refreshFromBody(json);

    return AuthResult(
      token: resolvedToken,
      refreshToken: resolvedRefresh,
      user: AuthUser.fromJson(userJson),
    );
  }

  static Map<String, dynamic>? _extractUser(Map<String, dynamic> json) {
    final direct = json['user'];
    if (direct is Map<String, dynamic>) return direct;

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['user'];
      if (nested is Map<String, dynamic>) return nested;
      if (data.containsKey('email') || data.containsKey('_id')) return data;
    }
    return null;
  }

  final String token;
  final String? refreshToken;
  final AuthUser user;
}

class AuthParseException implements Exception {
  const AuthParseException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiParseException implements Exception {
  const ApiParseException(this.message);
  final String message;

  @override
  String toString() => message;
}
