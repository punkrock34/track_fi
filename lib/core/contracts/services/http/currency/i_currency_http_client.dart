abstract class ICurrencyHttpClient {
  /// Returns a JSON map of {code: name} for all currencies,
  /// or null if the request fails.
  Future<Map<String, dynamic>?> getCurrencies();

  /// Returns a JSON map of {code: rate} for the given [baseCurrency],
  /// or null if the request fails.
  Future<Map<String, dynamic>?> getExchangeRates(String baseCurrency);
}
