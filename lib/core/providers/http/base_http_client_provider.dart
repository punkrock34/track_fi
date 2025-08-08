import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/http/i_base_http_client.dart';
import '../../services/http/base_http_client.dart';

final Provider<IBaseHttpClient> baseHttpClientProvider = Provider<IBaseHttpClient>((ProviderRef<IBaseHttpClient> ref) {
  return BaseHttpClient();
});
