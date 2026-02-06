import 'package:intl/intl.dart';

class DateFormatter {
  // Format as "12:30 PM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  // Format as "Jan 15, 2024"
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  // Format as "Jan 15, 12:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  // Format for chat messages (Today, Yesterday, or date)
  static String formatChatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return formatTime(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // Day name
    } else {
      return formatDate(dateTime);
    }
  }

  // Format for notification (e.g., "2 hours ago", "3 days ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
}
