import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../models/auth_user.dart';
import 'api_exception.dart';
import 'auth_http.dart';
import 'jwt_payload.dart';

/// JWT və istifadəçi məlumatının təhlükəsiz saxlanması.
class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Test/desktop fallback — yalnız secure storage uğursuz olanda.
  String? _memoryToken;
  String? _memoryRefreshToken;
  String? _memoryUserJson;

  /// Eyni anda bir neçə API 401/exp üçün tək refresh.
  Future<String?>? _refreshInFlight;

  Future<void> saveSession(AuthResult result) async {
    await _writeSession(
      accessToken: result.token,
      refreshToken: result.refreshToken,
      user: result.user,
    );
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final user = await getUser();
    await _writeSession(
      accessToken: accessToken,
      refreshToken: refreshToken ?? await _readRefreshRaw(),
      user: user,
    );
  }

  Future<void> saveUser(AuthUser user) async {
    final token = await _readAccessRaw();
    if (token == null || token.isEmpty) {
      await _writeUserOnly(user);
      return;
    }
    await _writeSession(
      accessToken: token,
      refreshToken: await _readRefreshRaw(),
      user: user,
    );
  }

  Future<void> _writeSession({
    required String accessToken,
    String? refreshToken,
    AuthUser? user,
  }) async {
    final userJson = user != null ? _encodeUser(user) : null;

    try {
      await _storage.write(key: _tokenKey, value: accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }
      if (userJson != null) {
        await _storage.write(key: _userKey, value: userJson);
      }
      _memoryToken = null;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _memoryRefreshToken = null;
      }
      if (userJson != null) _memoryUserJson = null;
    } catch (e) {
      if (kDebugMode) {
        _memoryToken = accessToken;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          _memoryRefreshToken = refreshToken;
        }
        if (userJson != null) _memoryUserJson = userJson;
      } else {
        rethrow;
      }
    }
  }

  Future<void> _writeUserOnly(AuthUser user) async {
    final userJson = _encodeUser(user);
    try {
      await _storage.write(key: _userKey, value: userJson);
      _memoryUserJson = null;
    } catch (e) {
      if (kDebugMode) {
        _memoryUserJson = userJson;
      } else {
        rethrow;
      }
    }
  }

  String _encodeUser(AuthUser user) => jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        if (user.phone != null && user.phone!.isNotEmpty) 'phone': user.phone,
      });

  Future<String?> _readAccessRaw() async {
    try {
      final stored = await _storage.read(key: _tokenKey);
      if (stored != null && stored.isNotEmpty) return stored;
    } catch (_) {}
    return _memoryToken;
  }

  Future<String?> _readRefreshRaw() async {
    try {
      final stored = await _storage.read(key: _refreshTokenKey);
      if (stored != null && stored.isNotEmpty) return stored;
    } catch (_) {}
    return _memoryRefreshToken;
  }

  /// Access token (15 dəq). Bitibsə refreshToken ilə yeniləyir.
  Future<String?> getToken() async {
    final token = await _readAccessRaw();
    if (token != null &&
        token.isNotEmpty &&
        !JwtPayload.isExpired(token)) {
      return token;
    }

    final refresh = await _readRefreshRaw();
    if (refresh == null || refresh.isEmpty) {
      if (token != null && token.isNotEmpty) {
        await clear();
      }
      return null;
    }

    return _refreshAccessToken(refresh);
  }

  Future<String?> getRefreshToken() => _readRefreshRaw();

  Future<String?> _refreshAccessToken(String refreshToken) {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = _doRefresh(refreshToken);
    _refreshInFlight = future;
    return future.whenComplete(() {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    });
  }

  Future<String?> _doRefresh(String refreshToken) async {
    try {
      final response = await postAuth(
        ApiConfig.refreshPath,
        body: {
          'refreshToken': refreshToken,
        },
      );

      final access = response.token;
      if (access == null || access.isEmpty) {
        await clear();
        return null;
      }

      final nextRefresh = response.refreshToken ?? refreshToken;
      await _writeSession(
        accessToken: access,
        refreshToken: nextRefresh,
        user: await getUser(),
      );
      return access;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await clear();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser?> getUser() async {
    String? raw;
    try {
      raw = await _storage.read(key: _userKey);
    } catch (_) {}
    raw ??= _memoryUserJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return AuthUser.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userKey);
    } catch (_) {}
    _memoryToken = null;
    _memoryRefreshToken = null;
    _memoryUserJson = null;
  }
}
