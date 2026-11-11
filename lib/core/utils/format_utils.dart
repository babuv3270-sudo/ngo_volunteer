import 'package:intl/intl.dart';

String formatDate(DateTime date, {String pattern = 'EEE, d MMM'}) => DateFormat(pattern).format(date);

String formatFullDate(DateTime date) => DateFormat('EEEE, d MMMM yyyy').format(date);

String formatTimeOfDay(DateTime date) => DateFormat('h:mm a').format(date);

String greetingFor(DateTime now) {
  final int hour = now.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String timeAgo(DateTime? time) {
  if (time == null) return '';
  final Duration diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(time);
}