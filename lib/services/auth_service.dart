import '../config/api_config.dart';
import '../models/auth_user.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_http.dart';
import 'auth_storage.dart';

/// Login, qeydiyyat və profil API.
class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final emailTrimmed = email.trim();
    if (emailTrimmed.isEmpty || password.isEmpty) {
      throw const ApiException('Email və şifrə daxil edin');
    }

    final response = await postAuth(
      ApiConfig.loginPath,
      body: {
        'email': emailTrimmed,
        'password': password,
      },
    );

   
    print(
      '[login] refreshToken=${response.refreshToken == null ? "NULL" : "YES"}',
    );

    return _saveAuthResponse(response);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final nameTrimmed = name.trim();
    final emailTrimmed = email.trim();
    if (nameTrimmed.isEmpty || emailTrimmed.isEmpty || password.isEmpty) {
      throw const ApiException('Ad, email və şifrə mütləqdir');
    }
    if (password.length < 6) {
      throw const ApiException('Şifrə ən azı 6 simvol olmalıdır');
    }

    final body = <String, dynamic>{
      'name': nameTrimmed,
      'email': emailTrimmed,
      'password': password,
    };
    final phoneTrimmed = phone?.trim();
    if (phoneTrimmed != null && phoneTrimmed.isNotEmpty) {
      body['phone'] = phoneTrimmed;
    }

    final response = await postAuth(ApiConfig.registerPath, body: body);

    // Production register: body-də token yoxdur, JWT Set-Cookie-də gəlir.
    try {
      if (response.data['user'] is Map<String, dynamic> &&
          response.token != null &&
          response.token!.isNotEmpty) {
        final saved = await _saveAuthResponse(response);
        try {
          await fetchCurrentUser();
          return saved;
        } catch (_) {
          await AuthStorage.instance.clear();
        }
      }
    } catch (_) {
      await AuthStorage.instance.clear();
    }

    return login(email: emailTrimmed, password: password);
  }

  /// Cari istifadəçi — `GET /auth/me`.
  Future<AuthUser?> fetchCurrentUser() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    final body = await _client.get(ApiConfig.mePath, bearerToken: token);
    final user = _parseUser(body);
    if (user != null) {
      await AuthStorage.instance.saveUser(user);
    }
    return user;
  }

  /// Profil yeniləmə — `PATCH /auth/profile`.
  Future<AuthUser> updateProfile({
    String? name,
    String? phone,
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Daxil olmalısınız');
    }

    final payload = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      payload['name'] = name.trim();
    }
    if (phone != null) {
      payload['phone'] = phone.trim();
    }
    if (payload.isEmpty) {
      throw const ApiException('Dəyişiklik yoxdur');
    }

    final body = await _client.patch(
      ApiConfig.profilePath,
      body: payload,
      bearerToken: token,
    );

    final user = _parseUser(body);
    if (user != null) {
      await AuthStorage.instance.saveUser(user);
      return user;
    }

    final cached = await AuthStorage.instance.getUser();
    if (cached != null) {
      final updated = cached.copyWith(
        name: payload['name'] as String? ?? cached.name,
        phone: payload.containsKey('phone')
            ? payload['phone'] as String?
            : cached.phone,
      );
      await AuthStorage.instance.saveUser(updated);
      return updated;
    }

    throw const ApiException('Profil yenilənmədi');
  }

  /// Hesabı sil — `DELETE /auth/profile`.
  Future<void> deleteAccount() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Daxil olmalısınız');
    }

    await _client.delete(
      ApiConfig.profilePath,
      bearerToken: token,
    );
    await AuthStorage.instance.clear();
  }

  Future<bool> isLoggedIn() => AuthStorage.instance.isLoggedIn();

  Future<AuthUser?> getCachedUser() => AuthStorage.instance.getUser();

  Future<void> logout() => AuthStorage.instance.clear();

  AuthUser? _parseUser(Map<String, dynamic> body) {
    final candidate = body['user'] ?? body['data'] ?? body;
    if (candidate is Map<String, dynamic>) {
      if (candidate.containsKey('email') ||
          candidate.containsKey('name') ||
          candidate.containsKey('_id')) {
        return AuthUser.fromJson(candidate);
      }
    }
    return null;
  }

  Future<AuthResult> _saveAuthResponse(AuthHttpResponse response) async {
    final result = AuthResult.fromApiResponse(
      response.data,
      token: response.token,
      refreshToken: response.refreshToken,
    );
    await AuthStorage.instance.saveSession(result);
    return result;
  }

  void dispose() => _client.dispose();
}
