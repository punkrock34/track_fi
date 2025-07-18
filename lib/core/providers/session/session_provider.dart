import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session/session_state.dart';

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

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
  }
}

final StateNotifierProvider<SessionNotifier, SessionState> sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>(
  (StateNotifierProviderRef<SessionNotifier, SessionState> ref) => SessionNotifier(),
);
