import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/approval_request.dart';
import '../models/chat_entry.dart';
import '../../project/models/session_analytics.dart';
import '../models/tool_call_kind.dart';
import '../models/tool_call_timing.dart';
import 'chat_transcript_provider.dart';

class AnalyticsNotifier extends StateNotifier<SessionAnalytics> {
  final Ref _ref;
  final String sessionId;
  final Stopwatch _stopwatch = Stopwatch();

  AnalyticsNotifier(this._ref, this.sessionId)
      : super(
          SessionAnalytics(sessionId: sessionId),
        ) {
    _stopwatch.start();
    _trackEvents();
  }

  void _trackEvents() {
    // Listen to transcript changes
    _ref.listen<List<ChatEntry>>(
      chatTranscriptProvider(sessionId),
      (previous, current) {
        _updateAnalytics(current);
      },
    );
  }

  void _updateAnalytics(List<ChatEntry> entries) {
    // Count tool calls
    final toolCalls = entries.where((e) => e.toolCall != null);
    final toolCallsByKind = <ToolCallKind, int>{};
    final toolCallsByStatus = <ToolCallStatus, int>{};

    for (final entry in toolCalls) {
      final tc = entry.toolCall!;
      toolCallsByKind[tc.kind] = (toolCallsByKind[tc.kind] ?? 0) + 1;
      toolCallsByStatus[tc.status] = (toolCallsByStatus[tc.status] ?? 0) + 1;
    }

    // Calculate response times
    final timings = <ToolCallTiming>[];
    for (final entry in toolCalls) {
      if (entry.toolCall!.duration != null) {
        timings.add(ToolCallTiming(
          toolCallId: entry.toolCall!.id,
          startedAt: entry.timestamp,
          completedAt: entry.timestamp.add(entry.toolCall!.duration!),
          duration: entry.toolCall!.duration!,
          isSuccess: entry.toolCall!.status == ToolCallStatus.success,
        ));
      }
    }

    final avgResponseTime = timings.isEmpty
        ? 0.0
        : timings
                .map((t) => t.duration.inMilliseconds)
                .reduce((a, b) => a + b) /
            timings.length;

    state = SessionAnalytics(
      sessionId: sessionId,
      totalTokens: _calculateTotalTokens(entries),
      totalMessages: entries.length,
      totalDuration: _stopwatch.elapsed,
      toolCallsCount: toolCalls.length,
      toolCallsByKind: toolCallsByKind,
      toolCallsByStatus: toolCallsByStatus,
      approvalsRequested: _countApprovals(entries, ApprovalStatus.pending),
      approvalsGranted: _countApprovals(entries, ApprovalStatus.approved),
      timings: timings,
      avgResponseTime: avgResponseTime,
      fileChanges: _calculateFileChanges(entries),
    );
  }

  int _calculateTotalTokens(List<ChatEntry> entries) {
    int total = 0;
    for (final e in entries) {
      total += (e.text.length / 4).ceil();
      if (e.toolCall != null) {
        total += (((e.toolCall!.detailInput?.length ?? 0) +
                    (e.toolCall!.detailOutput?.length ?? 0)) /
                4)
            .ceil();
        total += 40; // overhead
      }
    }
    return total;
  }

  int _countApprovals(List<ChatEntry> entries, ApprovalStatus status) {
    return entries
        .where((e) => e.approval != null && e.approval!.status == status)
        .length;
  }

  Map<String, int> _calculateFileChanges(List<ChatEntry> entries) {
    // Implementation to track file changes
    return {};
  }

  Future<void> exportAnalytics() async {
    // Export to JSON/CSV for external analysis
  }
}

final analyticsProvider =
    StateNotifierProvider.family<AnalyticsNotifier, SessionAnalytics, String>(
        (ref, sessionId) => AnalyticsNotifier(ref, sessionId));
