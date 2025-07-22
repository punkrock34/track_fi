import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/auth/jwt/i_jwt_auth_service.dart';
import '../../contracts/services/http/i_base_http_client.dart';
import '../../services/http/authenticated_http_client.dart';
import '../auth/jwt/jwt_auth_service_provider.dart';

final Provider<IBaseHttpClient> authenticatedHttpClientProvider = Provider<IBaseHttpClient>((ProviderRef<IBaseHttpClient> ref) {
  final IJwtAuthService jwtService = ref.read(jwtAuthServiceProvider);
  return AuthenticatedHttpClient(jwtService);
});
