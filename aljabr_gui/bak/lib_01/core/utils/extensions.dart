import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String toRelative() {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(this);
  }

  String toTimestamp() => DateFormat('HH:mm').format(this);
  String toFullDate() => DateFormat('MMM d, yyyy · HH:mm').format(this);
}

extension StringExt on String {
  String truncate(int maxLen, {String ellipsis = '…'}) =>
      length > maxLen ? '${substring(0, maxLen)}$ellipsis' : this;

  String get fileExtension {
    final idx = lastIndexOf('.');
    return idx == -1 ? '' : substring(idx + 1).toLowerCase();
  }

  String get fileName {
    final idx = lastIndexOf('/');
    return idx == -1 ? this : substring(idx + 1);
  }
}

String generateId() =>
    DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
    (DateTime.now().microsecond % 1000).toRadixString(36).padLeft(3, '0');
