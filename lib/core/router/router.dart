import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/secure_storage/onboarding_storage_provider.dart';
import '../../features/onboarding/ui/onboarding_coordinator.dart';
import '../../shared/screens/wip_screen.dart';
import '../contracts/services/secure_storage/i_onboarding_storage_service.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      final IOnboardingStorageService onboardingStorage = ref.read(onboardingStorageProvider);
      final bool isOnboardingComplete = await onboardingStorage.isOnboardingComplete();

      if (!isOnboardingComplete && !state.uri.toString().startsWith('/onboarding')) {
        return '/onboarding';
      }

      if (isOnboardingComplete && state.uri.toString().startsWith('/onboarding')) {
        return '/dashboard';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        name: 'onboarding',
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) => const OnboardingCoordinator(),
      ),
      GoRoute(
        name: 'dashboard',
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) => const WorkInProgressScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (BuildContext context, GoRouterState state) => '/dashboard',
      ),
    ],
  );
});
