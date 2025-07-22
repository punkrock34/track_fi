import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/http/i_base_http_client.dart';
import '../../services/http/unauthenticated_http_client.dart';

final Provider<IBaseHttpClient> authenticatedHttpClientProvider = Provider<IBaseHttpClient>((ProviderRef<IBaseHttpClient> ref) {
  return UnauthenticatedHttpClient();
});
