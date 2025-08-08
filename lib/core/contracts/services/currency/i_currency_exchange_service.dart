import '../../../models/database/account.dart';

abstract class ICurrencyExchangeService {
  /// Returns a map of {code: rate} for the given [baseCurrency].
  Future<Map<String, double>> getExchangeRates(String baseCurrency);

  /// Converts [amount] from [fromCurrency] to [toCurrency].
  Future<double> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  );

  /// Get the user's current base currency
  Future<String> getBaseCurrency();

  /// Set the user's base currency and refresh exchange rates
  Future<void> setBaseCurrency(String currencyCode);

  /// Convert amount from any currency to the user's base currency
  Future<double> convertToBaseCurrency(double amount, String fromCurrency);

  /// Convert multiple account balances to base currency in one go
  /// Returns map of {accountId: convertedBalance}
  Future<Map<String, double>> convertAccountBalancesToBaseCurrency(List<Account> accounts);

  /// Force refresh exchange rates for current base currency
  Future<void> refreshExchangeRates();

  /// Check if cached rates are still valid (less than 2 hours old)
  Future<bool> areRatesStale(String baseCurrency);

  /// Get last update time for exchange rates
  Future<DateTime?> getLastRatesUpdate(String baseCurrency);
}
