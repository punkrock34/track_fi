import '../../contracts/services/currency/i_currency_exchange_service.dart';
import '../../contracts/services/http/currency/i_currency_http_client.dart';

class CurrencyExchangeService implements ICurrencyExchangeService {
  CurrencyExchangeService({required this.currencyHttpClient});

  final ICurrencyHttpClient currencyHttpClient;

  @override
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    final String base = baseCurrency.toLowerCase();
    final Map<String, dynamic>? json = await currencyHttpClient.getExchangeRates(base);
    if (json == null) {
      throw Exception('Unable to fetch exchange rates for $baseCurrency');
    }

    final Map<String, dynamic>? ratesForBase = json[base] as Map<String, dynamic>?;
    if (ratesForBase == null) {
      throw Exception('Invalid response: missing rates for $baseCurrency');
    }

    return ratesForBase.map((String code, dynamic value) => MapEntry<String, double>(code.toUpperCase(), (value as num).toDouble()),);
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
}
