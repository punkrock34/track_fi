import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/database/account.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../contracts/services/currency/i_currency_exchange_service.dart';
import 'active_accounts_provider.dart';
import 'base_currency_provider.dart';

final FutureProvider<Map<String, double>> convertedBalancesProvider = FutureProvider<Map<String, double>>((FutureProviderRef<Map<String, double>> ref) async {
  final String _ = await ref.watch(baseCurrencyProvider.future);
  
  final List<Account> accounts = await ref.watch(activeAccountsProvider.future);
  final ICurrencyExchangeService fx = ref.read(currencyExchangeServiceProvider);
  try {
    return await fx.convertAccountBalancesToBaseCurrency(accounts);
  } catch (_) {
    return <String, double>{for (final Account a in accounts) a.id: a.balance};
  }
});
