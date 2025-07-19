// lib/shared/utils/date_utils.dart - Enhanced version
class DateUtils {
  DateUtils._();

  /// Format DateTime for display with time
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }

  /// Format date only (no time)
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format time only
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format relative date (Today, Yesterday, X days ago, etc.)
  static String formatRelativeDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final List<String> months = <String>[
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  /// Format duration for display (e.g., for lockout countdown)
  static String formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get time ago string (for sync status, etc.)
  static String getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime parseDateKey(String dateKey) {
    final List<String> parts = dateKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static String getTimeAgoForSync(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
