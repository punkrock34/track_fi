import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/main/ui/main_shell.dart';
import '../accounts/accounts_routes.dart';
import '../analytics/analytics_routes.dart';
import '../dashboard/dashboard_routes.dart';
import '../settings/settings_routes.dart';
import '../transactions/transactions_routes.dart';

final ShellRoute mainShellRoute = ShellRoute(
  builder: (BuildContext context, GoRouterState state, Widget child) {
    return MainShell(child: child);
  },
  routes: <RouteBase>[
    analyticsRoutes,
    dashboardRoutes,
    accountsRoutes,
    transactionsRoutes,
    settingsRoutes,
  ],
);
