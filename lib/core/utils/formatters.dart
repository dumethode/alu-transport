/// Small text helpers for times, greetings and names.
abstract final class Formatters {
  /// 07:40 when [use24Hour] is true, otherwise 7:40 AM.
  static String time(DateTime value, {bool use24Hour = true}) {
    if (use24Hour) {
      return '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
    }
    final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String suffix = value.hour < 12 ? 'AM' : 'PM';
    return '$hour:${_twoDigits(value.minute)} $suffix';
  }

  /// "just now", "4 min ago", "2 h ago", "Yesterday".
  static String timeAgo(DateTime value, {DateTime? now}) {
    final Duration diff = (now ?? DateTime.now()).difference(value);
    if (diff.inSeconds < 60) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} h ago';
    }
    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    return '${diff.inDays} days ago';
  }

  /// "now", "in 10 min", "in 1 h 5 min".
  static String minutesFromNow(int minutes) {
    if (minutes <= 0) {
      return 'now';
    }
    if (minutes < 60) {
      return 'in $minutes min';
    }
    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    return rest == 0 ? 'in $hours h' : 'in ${hours}h ${rest}min';
  }

  static String greeting(DateTime now) {
    if (now.hour < 12) {
      return 'Good morning';
    }
    if (now.hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  static String firstName(String fullName) {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'there';
    }
    return parts.first;
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
