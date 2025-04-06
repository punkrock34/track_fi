import 'package:go_router/go_router.dart';
import 'package:trackfi/features/onboarding/ui/onboarding_screen.dart';
import 'package:trackfi/shared/screens/main_navigation_shell.dart';

class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainNavigationShell(),
      ),
    ],
  );
}
