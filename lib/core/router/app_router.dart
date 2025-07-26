import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_redirect.dart';
import 'routes/auth/auth_route.dart';
import 'routes/main/main_shell_route.dart';
import 'routes/onboarding/onboarding_route.dart';
import 'session_refresh.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  final AppRedirect redirectHandler = AppRedirect(ref);
  final SessionRefresh notifier = SessionRefresh(ref.container);

  return GoRouter(
    initialLocation: '/',
    redirect: redirectHandler.handleRedirect,
    refreshListenable: notifier,
    routes: <RouteBase>[
      onboardingRoute,
      authRoute,
      mainShellRoute,
      GoRoute(
        path: '/',
        redirect: (_, _) => null,
      ),
    ],
  );
});
