import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'converted_balances_provider.dart';

final FutureProvider<double> totalBalanceProvider = FutureProvider<double>((FutureProviderRef<double> ref) async {
  final Map<String, double> map = await ref.watch(convertedBalancesProvider.future);
  return map.values.fold<double>(0.0, (double sum, double v) => sum + v);
});
