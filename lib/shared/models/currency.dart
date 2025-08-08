import 'package:flutter/widgets.dart';
import '../utils/currency_utils.dart';

@immutable
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    final String code =
        (json['code'] ?? json['cc'] ?? '').toString().toUpperCase();
    final String name = (json['name'] ??
            json['currencyName'] ??
            json['name_en'] ??
            '')
        .toString();
    final String symbol = json['symbol']?.toString() ??
        CurrencyUtils.getCurrencySymbol(code);
    return Currency(code: code, name: name, symbol: symbol);
  }

  final String code;
  final String name;
  final String symbol;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'symbol': symbol,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$name ($code)';
}
