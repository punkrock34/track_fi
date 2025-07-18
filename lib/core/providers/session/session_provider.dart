import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session/session_state.dart';

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState()) {
    // Start the session checker timer
    _startSessionChecker();
  }

  Timer? _sessionTimer;

  void setAuthenticated(bool authenticated) {
    state = state.copyWith(
      isAuthenticated: authenticated,
      lastActivityTime: authenticated ? DateTime.now() : null,
    );
  }

  void updateActivity() {
    if (state.isAuthenticated) {
      state = state.copyWith(lastActivityTime: DateTime.now());
    }
  }

  void checkExpiration() {
    if (state.isExpired) {
      logout();
    }
  }

  void logout() {
    state = const SessionState();
    _stopSessionChecker();
  }

  void _startSessionChecker() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      checkExpiration();
    });
  }

  void _stopSessionChecker() {
    _sessionTimer?.cancel();
  }

  @override
  void dispose() {
    _stopSessionChecker();
    super.dispose();
  }
}

final StateNotifierProvider<SessionNotifier, SessionState> sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>(
  (StateNotifierProviderRef<SessionNotifier, SessionState> ref) => SessionNotifier(),
);
