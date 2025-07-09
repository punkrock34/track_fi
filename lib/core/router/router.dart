import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/ui/onboarding_screen.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      )
    ],
  );
});
