import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/analytics/ui/screen/analytics_screen.dart';

final GoRoute analyticsRoutes = GoRoute(
  name: 'analytics',
  path: '/analytics',
  builder: (BuildContext context, GoRouterState state) => const AnalyticsScreen(),
);
