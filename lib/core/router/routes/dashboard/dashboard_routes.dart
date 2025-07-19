import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/dashboard/ui/screens/dashboard_screen.dart';

final GoRoute dashboardRoutes = GoRoute(
  name: 'dashboard',
  path: '/dashboard',
  builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
);
