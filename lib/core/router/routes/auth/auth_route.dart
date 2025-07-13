import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/ui/auth_screen.dart';

final GoRoute authRoute = GoRoute(
  name: 'auth',
  path: '/auth',
  builder: (BuildContext context, GoRouterState state) => const AuthScreen(),
);
