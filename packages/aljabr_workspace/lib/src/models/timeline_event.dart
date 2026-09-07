enum TimelineEventKind {
  phaseStarted,
  decisionMade,
  toolInvoked,
  toolResult,
  verificationPassed,
  verificationFailed,
  thoughtToken,
  outputToken,
  error;
}

class TimelineEvent {
  final String id;
  final String executionId;
  final String phase;
  final TimelineEventKind kind;
  final String title;
  final String details;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  TimelineEvent({
    required this.id,
    required this.executionId,
    required this.phase,
    required this.kind,
    required this.title,
    this.details = '',
    this.payload = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'executionId': executionId,
        'phase': phase,
        'kind': kind.name,
        'title': title,
        'details': details,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String? ?? '',
      executionId: json['executionId'] as String? ?? '',
      phase: json['phase'] as String? ?? 'GENERAL',
      kind: TimelineEventKind.values.firstWhere(
        (k) => k.name == json['kind'],
        orElse: () => TimelineEventKind.thoughtToken,
      ),
      title: json['title'] as String? ?? '',
      details: json['details'] as String? ?? '',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }
}
