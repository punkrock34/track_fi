import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../core/providers/secure_storage/onboarding_storage_provider.dart';
import '../../core/providers/secure_storage/pin_storage_provider.dart';
import '../models/session/session_state.dart';
import '../providers/session/session_provider.dart';

class AppRedirect {
  const AppRedirect(this.ref);

  final Ref ref;

  Future<String?> handleRedirect(BuildContext context, GoRouterState state) async {
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

    // onboarding not done
    if (!isOnboardingComplete && !location.startsWith('/onboarding')) {
      return '/onboarding';
    }

    // trying to access onboarding but already onboarded
    if (isOnboardingComplete && location.startsWith('/onboarding')) {
      return '/auth';
    }

    // onboarded, but no PIN yet
    if (isOnboardingComplete && !hasPinSet && !location.startsWith('/onboarding')) {
      return '/onboarding';
    }

    // trying to go to dashboard - only redirect if NOT authenticated
    if (isOnboardingComplete && hasPinSet && location.startsWith('/dashboard') && !isAuthenticated) {
      return '/auth';
    }

    // root redirects
    if (location == '/') {
      if (!isOnboardingComplete) {
        return '/onboarding';
      } else if (hasPinSet && !isAuthenticated) {
        return '/auth';
      } else if (hasPinSet && isAuthenticated) {
        return '/dashboard';
      } else {
        return '/onboarding';
      }
    }

    return null;
  }
}
