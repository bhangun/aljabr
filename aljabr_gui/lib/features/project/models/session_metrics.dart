import 'request_latency.dart';

class SessionMetrics {
  final String sessionId;
  final DateTime startTime;
  DateTime? endTime;
  int totalRequests;
  int totalErrors;
  Duration averageResponseTime;
  int toolCallsCount;
  int approvalsRequested;
  int approvalsGranted;
  List<RequestLatency> latencies = [];

  SessionMetrics({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.totalRequests = 0,
    this.totalErrors = 0,
    this.averageResponseTime = Duration.zero,
    this.toolCallsCount = 0,
    this.approvalsRequested = 0,
    this.approvalsGranted = 0,
  });

  void end() {
    endTime = DateTime.now();
  }
}
