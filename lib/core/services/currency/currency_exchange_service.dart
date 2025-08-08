import '../../contracts/services/currency/i_currency_exchange_service.dart';
import '../../contracts/services/http/currency/i_currency_http_client.dart';
import '../../contracts/services/secure_storage/i_currency_storage_service.dart';
import '../../logging/log.dart';
import '../../models/database/account.dart';

class CurrencyExchangeService implements ICurrencyExchangeService {
  CurrencyExchangeService({
    required this.currencyHttpClient,
    required this.currencyStorage,
  });

  final ICurrencyHttpClient currencyHttpClient;
  final ICurrencyStorageService currencyStorage;

  static const Duration _cacheValidDuration = Duration(hours: 2);

  @override
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    final String base = baseCurrency.toLowerCase();

    final Map<String, double>? cachedRates = await currencyStorage.getExchangeRates(base);
    final bool stale = await areRatesStale(base);

    if (cachedRates != null && !stale) {
      return cachedRates;
    }

    try {
      final Map<String, dynamic>? json = await currencyHttpClient.getExchangeRates(base);
      if (json == null) {
        throw Exception('Unable to fetch exchange rates for $baseCurrency');
      }

      final Map<String, dynamic>? ratesForBase = json[base] as Map<String, dynamic>?;
      if (ratesForBase == null) {
        throw Exception('Invalid response: missing rates for $baseCurrency');
      }

      final Map<String, double> rates = ratesForBase.map(
        (String code, dynamic value) => MapEntry<String, double>(
          code.toUpperCase(),
          (value as num).toDouble(),
        ),
      );

      await currencyStorage.setExchangeRates(base, rates);
      await currencyStorage.setLastRatesUpdate(base, DateTime.now());

      return rates;
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to fetch fresh exchange rates for $baseCurrency',
        error: e,
        stackTrace: stackTrace,
      );

      if (cachedRates != null) {
        await log(message: 'Using stale cached rates as fallback');
        return cachedRates;
      }

      rethrow;
    }
  }

  @override
  Future<double> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) {
      return amount;
    }

    final Map<String, double> rates = await getExchangeRates(fromCurrency);
    final double? rate = rates[toCurrency.toUpperCase()];
    
    if (rate == null) {
      throw Exception('Rate not available for $toCurrency');
    }
    
    return amount * rate;
  }

  @override
  Future<String> getBaseCurrency() async {
    return currencyStorage.getBaseCurrency();
  }

  @override
  Future<void> setBaseCurrency(String currencyCode) async {
    await currencyStorage.setBaseCurrency(currencyCode);

    try {
      await refreshExchangeRates();
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to pre-fetch rates for new base currency $currencyCode',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<double> convertToBaseCurrency(double amount, String fromCurrency) async {
    final String baseCurrency = await getBaseCurrency();
    return convertAmount(amount, fromCurrency, baseCurrency);
  }

  @override
  Future<Map<String, double>> convertAccountBalancesToBaseCurrency(List<Account> accounts) async {
    final String baseCurrency = await getBaseCurrency();
    final Map<String, double> convertedBalances = <String, double>{};

    final Map<String, List<Account>> accountsByCurrency = <String, List<Account>>{};
    for (final Account account in accounts) {
      accountsByCurrency.putIfAbsent(account.currency, () => <Account>[]);
      accountsByCurrency[account.currency]!.add(account);
    }

    for (final MapEntry<String, List<Account>> entry in accountsByCurrency.entries) {
      final String currency = entry.key;
      final List<Account> currencyAccounts = entry.value;

      try {
        for (final Account account in currencyAccounts) {
          if (currency.toUpperCase() == baseCurrency.toUpperCase()) {
            convertedBalances[account.id] = account.balance;
          } else {
            final double convertedBalance = await convertAmount(
              account.balance,
              currency,
              baseCurrency,
            );
            convertedBalances[account.id] = convertedBalance;
          }
        }
      } catch (e, stackTrace) {
        await log(
          message: 'Failed to convert balances from $currency to $baseCurrency',
          error: e,
          stackTrace: stackTrace,
        );
        
        for (final Account account in currencyAccounts) {
          convertedBalances[account.id] = account.balance;
        }
      }
    }

    return convertedBalances;
  }

  @override
  Future<void> refreshExchangeRates() async {
    final String baseCurrency = await getBaseCurrency();
    
    final Map<String, dynamic>? json = await currencyHttpClient.getExchangeRates(baseCurrency.toLowerCase());
    if (json == null) {
      throw Exception('Unable to refresh exchange rates for $baseCurrency');
    }

    final Map<String, dynamic>? ratesForBase = json[baseCurrency.toLowerCase()] as Map<String, dynamic>?;
    if (ratesForBase == null) {
      throw Exception('Invalid response: missing rates for $baseCurrency');
    }

    final Map<String, double> rates = ratesForBase.map(
      (String code, dynamic value) => MapEntry<String, double>(
        code.toUpperCase(), 
        (value as num).toDouble(),
      ),
    );

    await currencyStorage.setExchangeRates(baseCurrency.toLowerCase(), rates);
    await currencyStorage.setLastRatesUpdate(baseCurrency.toLowerCase(), DateTime.now());
  }

  @override
  Future<bool> areRatesStale(String baseCurrency) async {
    final DateTime? lastUpdate = await currencyStorage.getLastRatesUpdate(baseCurrency.toLowerCase());
    
    if (lastUpdate == null) {
      return true;
    }

    final Duration timeSinceUpdate = DateTime.now().difference(lastUpdate);
    return timeSinceUpdate > _cacheValidDuration;
  }

  @override
  Future<DateTime?> getLastRatesUpdate(String baseCurrency) async {
    return currencyStorage.getLastRatesUpdate(baseCurrency.toLowerCase());
  }
}
