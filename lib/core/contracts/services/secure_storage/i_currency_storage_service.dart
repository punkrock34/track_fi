abstract class ICurrencyStorageService {
  /// Get the user's base currency (defaults to 'GBP')
  Future<String> getBaseCurrency();
  
  /// Set the user's base currency
  Future<void> setBaseCurrency(String currencyCode);
  
  /// Cache exchange rates for the current base currency
  Future<void> setExchangeRates(String baseCurrency, Map<String, double> rates);
  
  /// Get cached exchange rates for a specific base currency
  Future<Map<String, double>?> getExchangeRates(String baseCurrency);
  
  /// Set when exchange rates were last updated
  Future<void> setLastRatesUpdate(String baseCurrency, DateTime timestamp);
  
  /// Get when exchange rates were last updated for a currency
  Future<DateTime?> getLastRatesUpdate(String baseCurrency);
  
  /// Clear all cached exchange rates (useful for cleanup)
  Future<void> clearAllRates();
}
