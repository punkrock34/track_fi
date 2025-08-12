import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../core/models/database/transaction.dart';
import '../../../../core/providers/database/storage/transaction_storage_service_provider.dart';
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
            onAddTransaction: () => context.pushNamed(
              'add-transaction',
              queryParameters: <String, String>{'accountId': account.id},
            ),
            onEditAccount: () {
              context.pushNamed(
                'edit-account',
                queryParameters: <String, String>{'accountId': account.id},
              );
            },
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
    final List<Transaction> transactions = await ref.read(transactionStorageProvider)
        .getAllByAccount(account.id);
    
    final String message = transactions.isEmpty
        ? 'Are you sure you want to delete "${account.name}"? This action cannot be undone.'
        : 'Are you sure you want to delete "${account.name}"? This will also delete ${transactions.length} associated transaction${transactions.length == 1 ? '' : 's'}. This action cannot be undone.';

    if (!context.mounted) {
      return;
    }

    final bool? confirmed = await UiUtils.showConfirmationDialog(
      context,
      title: 'Delete Account',
      message: message,
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool? success = await UiUtils.showLoadingDialogWithFuture<bool>(
      context,
      ref.read(accountsProvider.notifier).deleteAccount(account.id),
      message: 'Deleting account...',
      successMessage: 'Account "${account.name}" deleted successfully',
      errorMessage: 'Failed to delete account. Please try again.',
    );

    if ((success ?? false) && context.mounted) {
      context.goNamed('accounts');
    }
  }
}
