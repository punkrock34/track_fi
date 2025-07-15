import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../contracts/services/auth/i_jwt_auth_service.dart';
import '../../contracts/services/http/i_authenticated_http_client.dart';
import '../../logging/log.dart';

class AuthenticatedHttpClient implements IAuthenticatedHttpClient {
  AuthenticatedHttpClient(this._jwtService);

  final IJwtAuthService _jwtService;

  final String _baseUrl = AppConfig.apiBaseUrl;

  @override
  Future<http.Response?> get(String endpoint) {
    return _makeRequest((Uri uri, {Map<String, String>? headers, Object? body}) => http.get(uri, headers: headers), endpoint);
  }

  @override
  Future<http.Response?> post(String endpoint, {Map<String, dynamic>? body}) {
    return _makeRequest(http.post, endpoint, body: body);
  }

  @override
  Future<http.Response?> put(String endpoint, {Map<String, dynamic>? body}) {
    return _makeRequest(http.put, endpoint, body: body);
  }

  @override
  Future<http.Response?> delete(String endpoint) {
    return _makeRequest(http.delete, endpoint);
  }

  Future<http.Response?> _makeRequest(
    Future<http.Response> Function(Uri, {Map<String, String>? headers, Object? body}) httpMethod,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final String? accessToken = await _jwtService.getValidAccessToken();
      if (accessToken == null) {
        await log(message: 'No valid access token available.');
        return null;
      }

      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final Uri uri = Uri.parse('$_baseUrl$endpoint');

      final http.Response response = await httpMethod(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        await log(
          message:
              'Request failed [$endpoint]: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      await log(
        message: 'HTTP request failed: $endpoint',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
