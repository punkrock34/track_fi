class SessionState {
  const SessionState({
    this.isAuthenticated = false,
    this.lastActivityTime,
  });

  final bool isAuthenticated;
  final DateTime? lastActivityTime;

  SessionState copyWith({
    bool? isAuthenticated,
    DateTime? lastActivityTime,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
    );
  }

  /// Returns true if the user has been idle > 5 minutes while authenticated.
  bool get isExpired {
    if (!isAuthenticated || lastActivityTime == null) {
      return false;
    }
    return DateTime.now().difference(lastActivityTime!) > const Duration(minutes: 5);
  }
}
