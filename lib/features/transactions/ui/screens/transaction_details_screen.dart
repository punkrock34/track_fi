import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/transaction.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../providers/transactions_provider.dart';
import '../widgets/transaction_details_view.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Transaction?> transactionAsync = ref.watch(transactionProvider(widget.transactionId));

    return Scaffold(
      body: transactionAsync.when(
        loading: () => _buildLoadingState(context),
        error: (Object error, StackTrace stackTrace) => _buildErrorState(context, error),
        data: (Transaction? transaction) {
          if (transaction == null) {
            return _buildNotFoundState(context);
          }
          return TransactionDetailsView(
            transaction: transaction,
            onEdit: () => UiUtils.showComingSoon(context, 'Edit Transaction'),
            onDelete: () => _showDeleteConfirmation(context, transaction),
            onShare: () => _shareTransaction(context, transaction),
            onNavigateToAccount: () => context.goNamed(
              'account-details',
              pathParameters: <String, String>{'accountId': transaction.accountId},
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const LoadingState(message: 'Loading transaction details...'),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ErrorState(
        title: 'Failed to load transaction',
        message: error.toString(),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const ErrorState(
        title: 'Transaction not found',
        message: 'The transaction you are looking for does not exist.',
        icon: Icons.receipt_long_outlined,
      ),
    );
  }

  void _shareTransaction(BuildContext context, Transaction transaction) {
    UiUtils.showComingSoon(context, 'Share Transaction');
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Transaction transaction) async {
    final bool? confirmed = await UiUtils.showConfirmationDialog(
      context,
      title: 'Delete Transaction',
      message: 'Are you sure you want to delete "${transaction.description}"? This will also update your account balance. This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool? success = await UiUtils.showLoadingDialogWithFuture<bool>(
      context,
      ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id),
      message: 'Deleting transaction...',
      successMessage: 'Transaction deleted successfully',
      errorMessage: 'Failed to delete transaction. Please try again.',
    );

    if ((success ?? false) && context.mounted) {
      context.pop();
    }
  }
}
