import 'package:http/http.dart' as http;

abstract class IAuthenticatedHttpClient {
  Future<http.Response?> get(String endpoint);
  Future<http.Response?> post(String endpoint, {Map<String, dynamic>? body});
  Future<http.Response?> put(String endpoint, {Map<String, dynamic>? body});
  Future<http.Response?> delete(String endpoint);
}
