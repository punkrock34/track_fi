import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/settings/ui/screens/security_settings_screen.dart';
import '../../../../features/settings/ui/screens/settings_screen.dart';

final GoRoute settingsRoutes = GoRoute(
  name: 'settings',
  path: '/settings',
  builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
  routes: <RouteBase>[
    GoRoute(
      name: 'security-settings',
      path: '/security',
      builder: (BuildContext context, GoRouterState state) => const SecuritySettingsScreen(),
    ),
  ],
);
