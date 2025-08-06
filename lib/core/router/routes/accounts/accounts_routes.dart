import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/accounts/ui/screens/account_details_screen.dart';
import '../../../../features/accounts/ui/screens/accounts_screen.dart';
import '../../../../features/accounts/ui/screens/add_account_screen.dart';
import '../../../../features/accounts/ui/screens/edit_account_screen.dart';

final GoRoute accountsRoutes = GoRoute(
  name: 'accounts',
  path: '/accounts',
  builder: (BuildContext context, GoRouterState state) => const AccountsScreen(),
  routes: <RouteBase>[
    GoRoute(
      name: 'add-account',
      path: '/add',
      builder: (BuildContext context, GoRouterState state) => const AddAccountScreen(),
    ),
    GoRoute(
      path: '/edit',
      name: 'edit-account',
      builder: (BuildContext context, GoRouterState state) {
        final String accountId = state.uri.queryParameters['accountId']!;
        return EditAccountScreen(accountId: accountId);
      },
    ),
    GoRoute(
      name: 'account-details',
      path: '/:accountId',
      builder: (BuildContext context, GoRouterState state) {
        final String accountId = state.pathParameters['accountId']!;
        return AccountDetailScreen(accountId: accountId);
      },
    ),
  ],
);
