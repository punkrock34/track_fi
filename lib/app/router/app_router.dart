import 'package:go_router/go_router.dart';
import 'package:trackfi/features/auth/ui/welcome_screen.dart';
import 'package:trackfi/features/dashboard/ui/dashboard_screen.dart';

class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
