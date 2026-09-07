import 'tool_call_kind.dart';
import 'tool_call_timing.dart';

class SessionAnalytics {
  final String sessionId;
  final int totalTokens;
  final int totalMessages;
  final Duration totalDuration;
  final int toolCallsCount;
  final Map<ToolCallKind, int> toolCallsByKind;
  final Map<ToolCallStatus, int> toolCallsByStatus;
  final int approvalsRequested;
  final int approvalsGranted;
  final List<ToolCallTiming> timings;
  final double avgResponseTime;
  final Map<String, int> fileChanges;

  SessionAnalytics({
    required this.sessionId,
    this.totalTokens = 0,
    this.totalMessages = 0,
    this.totalDuration = Duration.zero,
    this.toolCallsCount = 0,
    this.toolCallsByKind = const {},
    this.toolCallsByStatus = const {},
    this.approvalsRequested = 0,
    this.approvalsGranted = 0,
    this.timings = const [],
    this.avgResponseTime = 0,
    this.fileChanges = const {},
  });
}
