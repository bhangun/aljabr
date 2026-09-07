import '../models/session_metrics.dart';

class SessionMonitor {
  final Map<String, SessionMetrics> metrics = {};

  void trackSessionStart(String sessionId) {
    metrics[sessionId] = SessionMetrics(
      sessionId: sessionId,
      startTime: DateTime.now(),
      totalRequests: 0,
      totalErrors: 0,
      averageResponseTime: Duration.zero,
      toolCallsCount: 0,
      approvalsRequested: 0,
    );
  }

  void trackRequest(String sessionId, Duration duration,
      {bool isError = false}) {
    final metric = metrics[sessionId];
    if (metric == null) return;

    metric.totalRequests++;
    if (isError) metric.totalErrors++;

    // Update average
    final totalDuration =
        metric.averageResponseTime.inMilliseconds * (metric.totalRequests - 1) +
            duration.inMilliseconds;
    metric.averageResponseTime =
        Duration(milliseconds: totalDuration ~/ metric.totalRequests);
  }

  void trackToolCall(String sessionId) {
    metrics[sessionId]?.toolCallsCount++;
  }

  void trackApproval(String sessionId, bool approved) {
    final metric = metrics[sessionId];
    if (metric == null) return;

    metric.approvalsRequested++;
    if (approved) metric.approvalsGranted++;
  }

  Map<String, dynamic> getDashboard() {
    final now = DateTime.now();
    final activeSessions =
        metrics.values.where((m) => m.endTime == null).length;

    final totalSessions = metrics.length;
    final totalRequests =
        metrics.values.fold(0, (sum, m) => sum + m.totalRequests);
    final totalErrors = metrics.values.fold(0, (sum, m) => sum + m.totalErrors);
    final totalToolCalls =
        metrics.values.fold(0, (sum, m) => sum + m.toolCallsCount);

    final avgResponseTime = metrics.isNotEmpty
        ? Duration(
            milliseconds: metrics.values
                    .map((m) => m.averageResponseTime.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                metrics.length)
        : Duration.zero;

    return {
      'activeSessions': activeSessions,
      'totalSessions': totalSessions,
      'totalRequests': totalRequests,
      'totalErrors': totalErrors,
      'errorRate': totalRequests > 0 ? totalErrors / totalRequests : 0,
      'totalToolCalls': totalToolCalls,
      'averageResponseTime': avgResponseTime,
      'timestamp': now,
    };
  }
}
