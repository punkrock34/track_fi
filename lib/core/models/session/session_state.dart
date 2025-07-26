import 'package:meta/meta.dart';

@immutable
class SessionState {
  const SessionState({
    this.isAuthenticated = false,
    this.lastActivityTime,
    this.sessionId,
  });

  final bool isAuthenticated;
  final DateTime? lastActivityTime;
  final String? sessionId;

  SessionState copyWith({
    bool? isAuthenticated,
    DateTime? lastActivityTime,
    String? sessionId,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  bool get isExpired {
    if (!isAuthenticated || lastActivityTime == null) {
      return false;
    }
    
    final Duration idleTime = DateTime.now().difference(lastActivityTime!);
    return idleTime > const Duration(minutes: 5);
  }

  Duration get idleTime {
    if (!isAuthenticated || lastActivityTime == null) {
      return Duration.zero;
    }
    
    return DateTime.now().difference(lastActivityTime!);
  }

  Duration get timeUntilExpiry {
    if (!isAuthenticated || lastActivityTime == null) {
      return Duration.zero;
    }
    
    const Duration sessionDuration = Duration(minutes: 5);
    final Duration elapsed = DateTime.now().difference(lastActivityTime!);
    final Duration remaining = sessionDuration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get willExpireSoon {
    return timeUntilExpiry < const Duration(minutes: 1) && timeUntilExpiry > Duration.zero;
  }

  @override
  bool operator ==(Object other) =>
    other is SessionState &&
    other.isAuthenticated == isAuthenticated &&
    other.lastActivityTime == lastActivityTime &&
    other.sessionId == sessionId;

  @override
  int get hashCode => Object.hash(isAuthenticated, lastActivityTime, sessionId);

  @override
  String toString() {
    return 'SessionState(isAuthenticated: $isAuthenticated, lastActivityTime: $lastActivityTime, isExpired: $isExpired, sessionId: $sessionId)';
  }
}
