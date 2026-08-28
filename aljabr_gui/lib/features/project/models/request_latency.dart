class RequestLatency {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final bool isError;

  RequestLatency({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.isError = false,
  });
}
