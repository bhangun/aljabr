class ToolCallTiming {
  final String toolCallId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Duration duration;
  final bool isSuccess;

  ToolCallTiming({
    required this.toolCallId,
    required this.startedAt,
    this.completedAt,
    required this.duration,
    this.isSuccess = true,
  });
}
