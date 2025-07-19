import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/transactions/ui/screens/transaction_details_screen.dart';
import '../../../../features/transactions/ui/screens/transactions_screen.dart';

final GoRoute transactionsRoutes = GoRoute(
  name: 'transactions',
  path: '/transactions',
  builder: (BuildContext context, GoRouterState state) => const TransactionsScreen(),
  routes: <RouteBase>[
    GoRoute(
      name: 'transaction-detail',
      path: '/:transactionId',
      builder: (BuildContext context, GoRouterState state) {
        final String transactionId = state.pathParameters['transactionId']!;
        return TransactionDetailScreen(transactionId: transactionId);
      },
    ),
  ],
);
