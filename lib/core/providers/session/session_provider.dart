import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session/session_state.dart';

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState()) {
    _initializeSession();
  }

  Timer? _sessionTimer;
  Timer? _heartbeatTimer;
  bool _isDisposed = false;

  static const Duration _sessionTimeout = Duration(minutes: 5);
  static const Duration _checkInterval = Duration(seconds: 30);
  static const Duration _heartbeatInterval = Duration(minutes: 1);

  void _initializeSession() {
    if (_isDisposed) {
      return;
    }
    
    _startSessionChecker();
  }

  void setAuthenticated(bool authenticated) {
    if (_isDisposed) {
      return;
    }
    
    final DateTime now = DateTime.now();
    
    state = state.copyWith(
      isAuthenticated: authenticated,
      lastActivityTime: authenticated ? now : null,
    );

    if (authenticated) {
      _startSessionChecker();
      _startHeartbeat();
    } else {
      _stopSessionChecker();
      _stopHeartbeat();
    }
  }

  void updateActivity() {
    if (_isDisposed || !state.isAuthenticated) {
      return;
    }
    
    final DateTime now = DateTime.now();
    
    if (state.lastActivityTime == null ||
        now.difference(state.lastActivityTime!) > const Duration(seconds: 10)) {
      state = state.copyWith(lastActivityTime: now);
    }
  }

  void checkExpiration() {
    if (_isDisposed || !state.isAuthenticated) {
      return;
    }
    
    if (state.isExpired) {
      logout();
    }
  }

  void logout() {
    if (_isDisposed) {
      debugPrint('[SESSION] logout skipped (disposed)');
      return;
    }
    
    debugPrint('[SESSION] logout called');
    state = SessionState(sessionId: 'logout_${DateTime.now().millisecondsSinceEpoch}');
    _stopSessionChecker();
    _stopHeartbeat();
  }

  void _startSessionChecker() {
    _stopSessionChecker();
    
    if (_isDisposed) {
      return;
    }
    
    _sessionTimer = Timer.periodic(_checkInterval, (Timer timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      checkExpiration();
    });
  }

  void _stopSessionChecker() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    
    if (_isDisposed) {
      return;
    }
    
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (Timer timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void extendSession() {
    if (_isDisposed || !state.isAuthenticated) {
      return;
    }
    
    state = state.copyWith(lastActivityTime: DateTime.now());
  }

  bool get willExpireSoon {
    if (!state.isAuthenticated || state.lastActivityTime == null) {
      return false;
    }
    
    final Duration timeUntilExpiry = _sessionTimeout - DateTime.now().difference(state.lastActivityTime!);
    return timeUntilExpiry < const Duration(minutes: 1);
  }

  Duration? get remainingSessionTime {
    if (!state.isAuthenticated || state.lastActivityTime == null) {
      return null;
    }
    
    final Duration elapsed = DateTime.now().difference(state.lastActivityTime!);
    final Duration remaining = _sessionTimeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopSessionChecker();
    _stopHeartbeat();
    super.dispose();
  }
}

final StateNotifierProvider<SessionNotifier, SessionState> sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>(
  (StateNotifierProviderRef<SessionNotifier, SessionState> ref) => SessionNotifier(),
);
