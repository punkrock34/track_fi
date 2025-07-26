import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../core/providers/secure_storage/onboarding_storage_provider.dart';
import '../../core/providers/secure_storage/pin_storage_provider.dart';
import '../logging/log.dart';
import '../models/session/session_state.dart';
import '../providers/session/session_provider.dart';

class AppRedirect {
  const AppRedirect(this.ref);

  final Ref ref;

  Future<String?> handleRedirect(BuildContext context, GoRouterState state) async {
    try {
      final IOnboardingStorageService onboardingStorage = ref.read(onboardingStorageProvider);
      final IPinStorageService pinStorage = ref.read(pinStorageProvider);
      
      final SessionState sessionState = ref.read(sessionProvider);

      if (sessionState.isExpired) {
        ref.read(sessionProvider.notifier).logout();
      }

      final bool isAuthenticated = sessionState.isAuthenticated;
      
      final bool isOnboardingComplete = await onboardingStorage.isOnboardingComplete();
      final bool hasPinSet = await pinStorage.hasPinSet();

      final String location = state.uri.toString();

      if (!isOnboardingComplete) {
        if (!location.startsWith('/onboarding')) {
          return '/onboarding';
        }
        return null;
      }

      if (isOnboardingComplete && !hasPinSet) {
        if (location.startsWith('/onboarding')) {
          return null;
        } else {
          return '/onboarding';
        }
      }

      if (isOnboardingComplete && hasPinSet && location.startsWith('/onboarding')) {
        if (isAuthenticated) {
          return '/dashboard';
        } else {
          return '/auth';
        }
      }

      final List<String> protectedRoutes = <String>['/dashboard', '/accounts', '/transactions', '/settings'];
      final bool isProtectedRoute = protectedRoutes.any((String route) => location.startsWith(route));
      
      if (isProtectedRoute && !isAuthenticated) {
        return '/auth';
      }

      if (location.startsWith('/auth') && isAuthenticated) {
        return '/dashboard';
      }

      if (location == '/') {
        if (!isOnboardingComplete) {
          return '/onboarding';
        } else if (!hasPinSet) {
          return '/onboarding';
        } else if (!isAuthenticated) {
          return '/auth';
        } else {
          return '/dashboard';
        }
      }
      return null;

    } catch (e, stackTrace) {
      await log(
        message: 'Redirect handling failed',
        error: e,
        stackTrace: stackTrace,
      );

      final String location = state.uri.toString();
      if (location.startsWith('/onboarding') || location.startsWith('/auth')) {
        return null;
      }
      
      return '/onboarding';
    }
  }
}
