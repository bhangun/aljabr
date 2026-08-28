enum AgentStepType {
  analysis,
  fileRead,
  fileWrite,
  command,
  test,
  search,
  reasoning,
  approval,
  verification,
}

enum AgentStepStatus { pending, running, completed, failed, skipped }

class AgentStep {
  final String id;
  final AgentStepType type;
  final AgentStepStatus status;
  final String title;
  final String? description;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Duration? duration;

  const AgentStep({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    required this.startedAt,
    this.completedAt,
    this.duration,
  });

  AgentStep copyWith({
    AgentStepStatus? status,
    DateTime? completedAt,
    Duration? duration,
    String? description,
  }) {
    return AgentStep(
      id: id,
      type: type,
      status: status ?? this.status,
      title: title,
      description: description ?? this.description,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'title': title,
        'description': description,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'durationMs': duration?.inMilliseconds,
      };

  static AgentStep fromMap(Map<String, dynamic> m) {
    AgentStepType parseType(String s) => AgentStepType.values
        .firstWhere((e) => e.name == s, orElse: () => AgentStepType.analysis);
    AgentStepStatus parseStatus(String s) => AgentStepStatus.values
        .firstWhere((e) => e.name == s, orElse: () => AgentStepStatus.pending);

    return AgentStep(
      id: m['id'] as String,
      type: parseType(m['type'] as String? ?? 'analysis'),
      status: parseStatus(m['status'] as String? ?? 'pending'),
      title: m['title'] as String? ?? '',
      description: m['description'] as String?,
      startedAt: DateTime.parse(
          m['startedAt'] as String? ?? DateTime.now().toIso8601String()),
      completedAt: m['completedAt'] != null
          ? DateTime.parse(m['completedAt'] as String)
          : null,
      duration: m['durationMs'] != null
          ? Duration(milliseconds: m['durationMs'] as int)
          : null,
    );
  }
}
