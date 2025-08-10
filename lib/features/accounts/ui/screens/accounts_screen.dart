import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../shared/utils/currency_utils.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../core/providers/financial/active_accounts_provider.dart';
import '../../../../core/providers/financial/base_currency_provider.dart';
import '../../../../core/providers/financial/total_balance_provider.dart';
import '../widgets/accounts_view.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> accountsAsync = ref.watch(activeAccountsProvider);
    final AsyncValue<double> totalAsync    = ref.watch(totalBalanceProvider);
    final AsyncValue<String> baseCurAsync  = ref.watch(baseCurrencyProvider);

    final String currentCurrencySymbol = baseCurAsync.maybeWhen(
      data: (String c) => CurrencyUtils.getCurrencySymbol(c),
      orElse: () => CurrencyUtils.getCurrencySymbol('RON'),
    );

    return SwipeNavigationWrapper(
      currentRoute: 'accounts',
      child: Scaffold(
        appBar: AppBar(title: const Text('Accounts')),
        body: accountsAsync.when(
          loading: () => const LoadingState(message: 'Loading accounts...'),
          error: (Object e, StackTrace st) => ErrorState(
            title: 'Failed to load accounts',
            message: e.toString(),
            onRetry: () => ref.refresh(activeAccountsProvider),
          ),
          data: (List<Account> accounts) => totalAsync.when(
            loading: () => const LoadingState(),
            error: (Object e, StackTrace st) => ErrorState(
              title: 'Failed to compute total',
              message: e.toString(),
              onRetry: () => ref.refresh(totalBalanceProvider),
            ),
            data: (double total) => AccountsView(
              accounts: accounts,
              totalBalance: total,
              currentCurrency: currentCurrencySymbol,
              onAccountTap: (Account a) => context.goNamed(
                'account-details',
                pathParameters: <String, String>{'accountId': a.id},
              ),
              onAddAccount: () => context.pushNamed('add-account'),
            ),
          ),
        ),
      ),
    );
  }
}
