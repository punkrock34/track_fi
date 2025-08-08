abstract class ICurrencyExchangeService {
  /// Returns a map of {code: rate} for the given [baseCurrency].
  Future<Map<String, double>> getExchangeRates(String baseCurrency);

  /// Converts [amount] from [fromCurrency] to [toCurrency].
  Future<double> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  );
}
