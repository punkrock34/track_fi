import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../core/providers/secure_storage/onboarding_storage_provider.dart';
import '../../core/providers/secure_storage/pin_storage_provider.dart';
import '../logging/log.dart';
import '../models/session/session_state.dart';
import '../providers/auth/auth_service_provider.dart';
import '../providers/session/session_provider.dart';

class AppRedirect {
  const AppRedirect(this.ref);

  final Ref ref;

  static const String _onboardingPath = '/onboarding';
  static const String _authPath = '/auth';
  static const String _dashboardPath = '/dashboard';
  static const String _accountsPath = '/accounts';
  static const String _transactionsPath = '/transactions';
  static const String _settingsPath = '/settings';

  Future<String?> handleRedirect(BuildContext context, GoRouterState state) async {
    try {
      final IOnboardingStorageService onboardingStorage = ref.read(onboardingStorageProvider);
      final IPinStorageService pinStorage = ref.read(pinStorageProvider);
      
      SessionState sessionState = ref.read(sessionProvider);
      if (sessionState.isExpired) {
        ref.read(sessionProvider.notifier).logout();
        ref.read(authServiceProvider.notifier).reset();
        sessionState = ref.read(sessionProvider);
      }

      final bool isAuthenticated = sessionState.isAuthenticated;
      
      final bool isOnboardingComplete = await onboardingStorage.isOnboardingComplete();
      final bool hasPinSet = await pinStorage.hasPinSet();

      final String location = state.uri.toString();

      if (!isOnboardingComplete) {
        if (!location.startsWith(_onboardingPath)) {
          return _onboardingPath;
        }
        return null;
      }

      if (isOnboardingComplete && !hasPinSet) {
        if (location.startsWith(_onboardingPath)) {
          return null;
        } else {
          return _onboardingPath;
        }
      }

      if (isOnboardingComplete && hasPinSet && location.startsWith(_onboardingPath)) {
        if (isAuthenticated) {
          return _dashboardPath;
        } else {
          return _authPath;
        }
      }

      final List<String> protectedRoutes = <String>[_dashboardPath, _accountsPath, _transactionsPath, _settingsPath];
      final bool isProtectedRoute = protectedRoutes.any((String route) => location.startsWith(route));
      
      if (isProtectedRoute && !isAuthenticated) {
        return _authPath;
      }

      if (location.startsWith(_authPath) && isAuthenticated) {
        return _dashboardPath;
      }

      if (location == '/') {
        if (!isOnboardingComplete) {
          return _onboardingPath;
        } else if (!hasPinSet) {
          return _onboardingPath;
        } else if (!isAuthenticated) {
          return _authPath;
        } else {
          return _dashboardPath;
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
      if (location.startsWith(_onboardingPath) || location.startsWith(_authPath)) {
        return null;
      }

      return _onboardingPath;
    }
  }
}
