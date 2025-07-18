import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../config/app_config.dart';
import '../../../contracts/services/auth/jwt/i_jwt_auth_service.dart';
import '../../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../../logging/log.dart';
import '../../../models/auth/jwt/jwt_login_response.dart';

// imports remain unchanged

class JwtAuthService implements IJwtAuthService {
  JwtAuthService(this._secureStorage);

  final ISecureStorageService _secureStorage;

  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _tokenExpiryKey = 'jwt_token_expiry';
  static const String _userIdKey = 'jwt_user_id';
  static const String _deviceIdKey = 'device_id';

  static final String _baseUrl = AppConfig.apiBaseUrl;

  @override
  Future<bool> isAuthenticated() async {
    final String? token = await _secureStorage.read(_accessTokenKey);
    return token != null && !await _isTokenExpired();
  }

  @override
  Future<String?> getValidAccessToken() async {
    if (await _isTokenExpired()) {
      final bool refreshed = await _refreshAccessToken();
      if (!refreshed) {
        await clearTokens();
        return null;
      }
    }
    return _secureStorage.read(_accessTokenKey);
  }

  @override
  Future<bool> loginWithPin(String pin) async {
    final http.Response? response = await _post('/auth/login', <String, dynamic>{
      'pin': pin,
      'device_id': await _getDeviceId(),
    });

    if (response == null) {
      return false;
    }

    await _storeTokens(_parseJwtLoginResponse(response));
    return true;
  }

  @override
  Future<bool> registerDevice(String pin) async {
    final http.Response? response = await _post(
      '/auth/register',
      <String, dynamic>{
        'pin': pin,
        'device_id': await _getDeviceId(),
        'device_name': await _getDeviceName(),
      },
      expectedStatus: 201,
    );

    if (response == null) {
      return false;
    }

    await _storeTokens(_parseJwtLoginResponse(response));
    return true;
  }

  @override
  Future<void> logout() async {
    final String? accessToken = await _secureStorage.read(_accessTokenKey);
    if (accessToken != null) {
      await _post(
        '/auth/logout',
        <String, dynamic>{},
        headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      );
    }
    await clearTokens();
  }

  @override
  Future<void> clearTokens() => Future.wait(<Future<void>>[
        _secureStorage.delete(_accessTokenKey),
        _secureStorage.delete(_refreshTokenKey),
        _secureStorage.delete(_tokenExpiryKey),
        _secureStorage.delete(_userIdKey),
      ]);

  @override
  Future<String?> getCurrentUserId() =>
      _secureStorage.read(_userIdKey);

  Future<bool> _refreshAccessToken() async {
    final String? refreshToken = await _secureStorage.read(_refreshTokenKey);
    if (refreshToken == null) {
      return false;
    }

    final http.Response? response = await _post('/auth/refresh', <String, dynamic>{
      'refresh_token': refreshToken,
    });

    if (response == null) {
      return false;
    }

    await _storeTokens(
      _parseJwtLoginResponse(response),
      fallbackUserId: await getCurrentUserId(),
    );
    return true;
  }

  Future<bool> _isTokenExpired() async {
    final String? expiryStr = await _secureStorage.read(_tokenExpiryKey);
    if (expiryStr == null) {
      return true;
    }

    final DateTime expiry = DateTime.parse(expiryStr);
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  Future<http.Response?> _post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    int expectedStatus = 200,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl$endpoint');
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: json.encode(body),
      );

      if (response.statusCode == expectedStatus) {
        return response;
      }

      await log(
        message: 'Request failed [$endpoint]: ${response.statusCode} - ${response.body}',
      );
      return null;
    } catch (e, stack) {
      await log(
        message: 'HTTP request failed: $endpoint',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  JwtLoginResponse _parseJwtLoginResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return JwtLoginResponse.fromJson(data);
  }

  Future<void> _storeTokens(
    JwtLoginResponse response, {
    String? fallbackUserId,
  }) {
    final DateTime expiryTime = DateTime.now().add(Duration(seconds: response.expiresIn));

    return Future.wait(<Future<void>>[
      _secureStorage.write(_accessTokenKey, response.accessToken),
      _secureStorage.write(_refreshTokenKey, response.refreshToken),
      _secureStorage.write(_tokenExpiryKey, expiryTime.toIso8601String()),
      if (response.user?.id != null)
        _secureStorage.write(_userIdKey, response.user!.id)
      else if (fallbackUserId != null)
        _secureStorage.write(_userIdKey, fallbackUserId),
    ]);
  }

  Future<String> _getDeviceId() async {
    String? id = await _secureStorage.read(_deviceIdKey);
    if (id != null) {
      return id;
    }

    id = DateTime.now().millisecondsSinceEpoch.toString();
    await _secureStorage.write(_deviceIdKey, id);
    return id;
  }

  Future<String> _getDeviceName() async {
    if (Platform.isIOS) {
      return 'iOS Device';
    }
    if (Platform.isAndroid) {
      return 'Android Device';
    }
    return 'Unknown Device';
  }
}
