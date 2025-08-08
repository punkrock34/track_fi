import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/currency/i_currency_exchange_service.dart';
import '../../contracts/services/http/currency/i_currency_http_client.dart';
import '../../contracts/services/secure_storage/i_currency_storage_service.dart';
import '../../services/currency/currency_exchange_service.dart';
import '../http/currency/currency_http_client_provider.dart';
import '../secure_storage/currency_storage_provider.dart';

final Provider<ICurrencyExchangeService> currencyExchangeServiceProvider = Provider<ICurrencyExchangeService>((ProviderRef<ICurrencyExchangeService> ref) {
  final ICurrencyHttpClient currencyHttpClient = ref.watch(currencyHttpClientProvider);
  final ICurrencyStorageService currencyStorage = ref.read(currencyStorageProvider);
  
  return CurrencyExchangeService(
    currencyHttpClient: currencyHttpClient,
    currencyStorage: currencyStorage,
  );
});
