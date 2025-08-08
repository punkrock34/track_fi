import 'dart:convert';

import 'package:http/http.dart';

import '../../../contracts/services/http/currency/i_currency_http_client.dart';
import '../../../contracts/services/http/i_base_http_client.dart';
import '../../../logging/log.dart';

class CurrencyHttpClient implements ICurrencyHttpClient {
  CurrencyHttpClient({required this.httpClient});

  final IBaseHttpClient httpClient;

  static const String _baseUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';

  @override
  Future<Map<String, dynamic>?> getCurrencies() async {
    const String url = '$_baseUrl/currencies.json';
    final Response? response = await httpClient.get(url);
    if (response == null || response.statusCode != 200) {
      await log(
        message: 'Failed to fetch currency list: ${response?.statusCode}',
      );
      return null;
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>?> getExchangeRates(String baseCurrency) async {
    final String base = baseCurrency.toLowerCase();
    final String url = '$_baseUrl/currencies/$base.json';
    final Response? response = await httpClient.get(url);
    if (response == null || response.statusCode != 200) {
      await log(
        message:
            'Failed to fetch exchange rates for $baseCurrency: ${response?.statusCode}',
      );
      return null;
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
