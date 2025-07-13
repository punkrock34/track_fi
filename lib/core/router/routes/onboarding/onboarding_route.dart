import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/onboarding/ui/onboarding_coordinator.dart';

final GoRoute onboardingRoute = GoRoute(
  name: 'onboarding',
  path: '/onboarding',
  builder: (BuildContext context, GoRouterState state) => const OnboardingCoordinator(),
);
