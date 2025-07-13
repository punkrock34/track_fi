import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/screens/wip_screen.dart';

final GoRoute dashboardRoute = GoRoute(
  name: 'dashboard',
  path: '/dashboard',
  builder: (BuildContext context, GoRouterState state) => const WorkInProgressScreen(),
);
