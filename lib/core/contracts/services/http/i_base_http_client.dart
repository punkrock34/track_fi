import 'package:http/http.dart' as http;

abstract class IBaseHttpClient {
  Future<http.Response?> get(String url);
  Future<http.Response?> post(String url, {Map<String, dynamic>? body});
  Future<http.Response?> put(String url, {Map<String, dynamic>? body});
  Future<http.Response?> delete(String url);
}
