import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/transactions/ui/screens/add_transaction_screen.dart';
import '../../../../features/transactions/ui/screens/edit_transactions_screen.dart';
import '../../../../features/transactions/ui/screens/transaction_details_screen.dart';
import '../../../../features/transactions/ui/screens/transactions_screen.dart';

final GoRoute transactionsRoutes = GoRoute(
  name: 'transactions',
  path: '/transactions',
  builder: (BuildContext context, GoRouterState state) {
    final String? accountId = state.uri.queryParameters['accountId'];
    return TransactionsScreen(accountId: accountId);
  },
  routes: <RouteBase>[
    GoRoute(
      name: 'add-transaction',
      path: '/transactions/add',
      builder: (BuildContext context, GoRouterState state) {
        final String? accountId = state.uri.queryParameters['accountId'];
        return AddTransactionScreen(preselectedAccountId: accountId);
      },
    ),
    GoRoute(
      name: 'edit-transaction',
      path: '/edit/:transactionId',
      builder: (BuildContext context, GoRouterState state) {
        final String transactionId = state.pathParameters['transactionId']!;
        return EditTransactionScreen(transactionId: transactionId);
      },
    ),
    GoRoute(
      name: 'transaction-details',
      path: '/:transactionId',
      builder: (BuildContext context, GoRouterState state) {
        final String transactionId = state.pathParameters['transactionId']!;
        return TransactionDetailScreen(transactionId: transactionId);
      },
    ),
  ],
);
