import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../providers/accounts_provider.dart';
import '../widgets/account_details_view.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Account?> accountAsync = ref.watch(accountProvider(widget.accountId));
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: accountAsync.when(
        loading: () => _buildLoadingState(theme),
        error: (Object error, StackTrace stackTrace) => _buildErrorState(error, theme),
        data: (Account? account) {
          if (account == null) {
            return _buildNotFoundState(theme);
          }
          return AccountDetailsView(
            account: account,
            onAddTransaction: () => context.push('/transactions/add?accountId=${account.id}'),
            onEditAccount: () => UiUtils.showComingSoon(context, 'Edit Account'),
            onDeleteAccount: () => _showDeleteConfirmation(context, account),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: const LoadingState(message: 'Loading account details...'),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ErrorState(
        title: 'Failed to load account',
        message: error.toString(),
        onRetry: () => ref.invalidate(accountProvider(widget.accountId)),
      ),
    );
  }

  Widget _buildNotFoundState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: const ErrorState(
        title: 'Account not found',
        message: 'The account you are looking for does not exist.',
        icon: Icons.account_balance_outlined,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Account account) async {
    final NavigatorState navigator = Navigator.of(context);
    final bool confirmed = (await UiUtils.showConfirmationDialog(
      navigator.context,
      title: 'Delete Account',
      message: 'Are you sure you want to delete "${account.name}"? This action cannot be undone and will also delete all associated transactions.',
      confirmText: 'Delete',
      isDestructive: true,
    )) ?? false;

    if (!confirmed || !navigator.mounted) {
      return;
    }

    UiUtils.showComingSoon(navigator.context, 'Delete Account');
  }
}
