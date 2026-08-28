import '../../chat/models/message.dart';
import '../../chat/models/session.dart';

/// Analytics data structure
class AnalyticsData {
  const AnalyticsData({
    required this.totalSessions,
    required this.totalMessages,
    required this.totalTokens,
    required this.averageTokensPerMessage,
    required this.mostActiveDay,
    required this.messageFrequency,
    required this.modelUsage,
    required this.dailyActivity,
    required this.averageResponseTime,
    required this.topLanguages,
  });

  final int totalSessions;
  final int totalMessages;
  final int totalTokens;
  final double averageTokensPerMessage;
  final DateTime mostActiveDay;
  final Map<String, int> messageFrequency;
  final Map<String, int> modelUsage;
  final List<DailyActivity> dailyActivity;
  final Duration averageResponseTime;
  final Map<String, int> topLanguages;

  static AnalyticsData fromSessions(List<Session> sessions) {
    var totalMessages = 0;
    var totalTokens = 0;
    var totalResponseTime = 0;
    var responseCount = 0;
    final dailyMessages = <String, int>{};
    final modelUsage = <String, int>{};
    final languageUsage = <String, int>{};

    for (final session in sessions) {
      totalMessages += session.messages.length;

      for (final message in session.messages) {
        // Count tokens
        totalTokens += message.tokenCount ?? 0;

        // Daily activity
        final day =
            '${message.createdAt.year}-${message.createdAt.month}-${message.createdAt.day}';
        dailyMessages[day] = (dailyMessages[day] ?? 0) + 1;

        // Language usage from attached files
        for (final file in message.attachedFiles) {
          languageUsage[file.language] =
              (languageUsage[file.language] ?? 0) + 1;
        }

        // Response time (estimate from message timestamps)
        if (message.role == MessageRole.assistant) {
          final userMessage = _findPreviousUserMessage(
            session.messages,
            message,
          );
          if (userMessage != null) {
            final diff = message.createdAt.difference(userMessage.createdAt);
            totalResponseTime += diff.inMilliseconds;
            responseCount++;
          }
        }
      }

      // Model usage from session (would need to be stored)
      modelUsage['Claude'] =
          (modelUsage['Claude'] ?? 0) + session.messages.length;
    }

    // Find most active day
    var mostActiveDay = DateTime.now();
    var maxMessages = 0;
    for (final entry in dailyMessages.entries) {
      if (entry.value > maxMessages) {
        maxMessages = entry.value;
        final parts = entry.key.split('-');
        mostActiveDay = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    // Build daily activity list
    final dailyActivity = dailyMessages.entries.map((e) {
      final parts = e.key.split('-');
      return DailyActivity(
        date: DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ),
        messageCount: e.value,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    // Top languages
    final sortedLanguages = languageUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AnalyticsData(
      totalSessions: sessions.length,
      totalMessages: totalMessages,
      totalTokens: totalTokens,
      averageTokensPerMessage: totalMessages > 0
          ? totalTokens / totalMessages
          : 0,
      mostActiveDay: mostActiveDay,
      messageFrequency: dailyMessages,
      modelUsage: modelUsage,
      dailyActivity: dailyActivity,
      averageResponseTime: responseCount > 0
          ? Duration(milliseconds: totalResponseTime ~/ responseCount)
          : Duration.zero,
      topLanguages: Map.fromEntries(sortedLanguages.take(10)),
    );
  }

  static Message? _findPreviousUserMessage(
    List<Message> messages,
    Message assistantMessage,
  ) {
    final index = messages.indexOf(assistantMessage);
    for (var i = index - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.user) {
        return messages[i];
      }
    }
    return null;
  }
}

/// Daily activity record
class DailyActivity {
  DailyActivity({required this.date, required this.messageCount});

  final DateTime date;
  final int messageCount;
}
