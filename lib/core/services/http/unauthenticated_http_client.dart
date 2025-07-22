import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../contracts/services/http/i_base_http_client.dart';

class UnauthenticatedHttpClient implements IBaseHttpClient {
  @override
  Future<http.Response?> get(String url) => _makeRequest((Uri uri, {Map<String, String>? headers, Object? body}) => http.get(uri, headers: headers), url);

  @override
  Future<http.Response?> post(String url, {Map<String, dynamic>? body}) =>
      _makeRequest((Uri uri, {Map<String, String>? headers, Object? body}) => http.post(uri, headers: headers, body: body), url, body: body);

  @override
  Future<http.Response?> put(String url, {Map<String, dynamic>? body}) =>
      _makeRequest((Uri uri, {Map<String, String>? headers, Object? body}) => http.put(uri, headers: headers, body: body), url, body: body);

  @override
  Future<http.Response?> delete(String url) => _makeRequest((Uri uri, {Map<String, String>? headers, Object? body}) => http.delete(uri, headers: headers), url);

  Future<http.Response?> _makeRequest(
    Future<http.Response> Function(Uri, {Map<String, String>? headers, Object? body}) method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = <String, String>{'Content-Type': 'application/json'};

      final http.Response response = await method(uri,
          headers: headers, body: body != null ? json.encode(body) : null);

      return response;
    } catch (e) {
      // optional logging
      return null;
    }
  }
}
