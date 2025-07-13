import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_redirect.dart';
import 'routes/auth/auth_route.dart';
import 'routes/dashboard/dashboard_route.dart';
import 'routes/onboarding/onboarding_route.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  final AppRedirect redirectHandler = AppRedirect(ref);

  return GoRouter(
    initialLocation: '/',
    redirect: redirectHandler.handleRedirect,
    routes: <RouteBase>[
      onboardingRoute,
      authRoute,
      dashboardRoute,
      GoRoute(
        path: '/',
        redirect: (_, _) => null, // Root handled by redirect
      )
    ],
  );
});
