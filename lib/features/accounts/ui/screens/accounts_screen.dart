import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../providers/accounts_provider.dart';
import '../widgets/accounts_view.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String _currentCurrency = 'RON';

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      _currentCurrency = await ref.read(currencyExchangeServiceProvider).getBaseCurrency();
      await ref.read(accountsProvider.notifier).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Account>> accountsAsync = ref.watch(accountsProvider);
    final ThemeData theme = Theme.of(context);

    return SwipeNavigationWrapper(
      currentRoute: 'accounts',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accounts'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.pushNamed('add-account'),
              tooltip: 'Add Account',
            ),
          ],
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
          child: _buildContent(accountsAsync),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed('add-account'),
          tooltip: 'Add Account',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<Account>> accountsAsync) {
    return accountsAsync.when(
      loading: () => const LoadingState(message: 'Loading accounts...'),
      error: (Object error, StackTrace stackTrace) => ErrorState(
        title: 'Failed to load accounts',
        message: error.toString(),
        onRetry: () => ref.read(accountsProvider.notifier).loadAccounts(),
      ),
      data: (List<Account> accounts) => AccountsView(
        accounts: accounts,
        onAccountTap: (Account account) => context.goNamed(
          'account-details',
          pathParameters: <String, String>{'accountId': account.id},
        ),
        onAddAccount: () => context.pushNamed('add-account'),
        currentCurrency: CurrencyUtils.getCurrencySymbol(_currentCurrency),
      ),
    );
  }
}
