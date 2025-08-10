import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';

final FutureProvider<String> baseCurrencyProvider = FutureProvider<String>(
  (FutureProviderRef<String> ref) => ref.read(currencyExchangeServiceProvider).getBaseCurrency(),
);
