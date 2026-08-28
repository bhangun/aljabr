class AgentEvent {
  final String id;
  final String runId;
  final String type;
  final String payload;
  final DateTime timestamp;

  const AgentEvent({
    required this.id,
    required this.runId,
    required this.type,
    required this.payload,
    required this.timestamp,
  });
}
