import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/http/currency/i_currency_http_client.dart';
import '../../../contracts/services/http/i_base_http_client.dart';
import '../../../services/http/currency/currency_http_client.dart';
import '../base_http_client_provider.dart';

final Provider<ICurrencyHttpClient> currencyHttpClientProvider = Provider<ICurrencyHttpClient>((ProviderRef<ICurrencyHttpClient> ref) {
  final IBaseHttpClient httpClient = ref.watch(baseHttpClientProvider);
  return CurrencyHttpClient(httpClient: httpClient);
});
