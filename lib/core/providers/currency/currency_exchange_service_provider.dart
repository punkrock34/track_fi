import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/currency/i_currency_exchange_service.dart';
import '../../contracts/services/http/currency/i_currency_http_client.dart';
import '../../services/currency/currency_exchange_service.dart';
import '../http/currency/currency_http_client_provider.dart';

final Provider<ICurrencyExchangeService> currencyExchangeServiceProvider =Provider<ICurrencyExchangeService>((ProviderRef<ICurrencyExchangeService> ref) {
  final ICurrencyHttpClient currencyHttpClient = ref.watch(currencyHttpClientProvider);
  return CurrencyExchangeService(currencyHttpClient: currencyHttpClient);
});
