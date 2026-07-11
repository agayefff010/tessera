import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_user.dart';

/// JWT və istifadəçi məlumatının təhlükəsiz saxlanması.
class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Test/desktop fallback — yalnız secure storage uğursuz olanda.
  String? _memoryToken;
  String? _memoryUserJson;

  Future<void> saveSession(AuthResult result) async {
    await _writeUser(result.token, result.user);
  }

  Future<void> saveUser(AuthUser user) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await _writeUserOnly(user);
      return;
    }
    await _writeUser(token, user);
  }

  Future<void> _writeUser(String token, AuthUser user) async {
    final userJson = _encodeUser(user);

    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: userJson);
      _memoryToken = null;
      _memoryUserJson = null;
    } catch (e) {
      if (kDebugMode) {
        _memoryToken = token;
        _memoryUserJson = userJson;
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

  Future<String?> getToken() async {
    try {
      final stored = await _storage.read(key: _tokenKey);
      if (stored != null && stored.isNotEmpty) return stored;
    } catch (_) {}
    return _memoryToken;
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
      await _storage.delete(key: _userKey);
    } catch (_) {}
    _memoryToken = null;
    _memoryUserJson = null;
  }
}
