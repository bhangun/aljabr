import 'agent_run_status.dart';
import 'agent_step.dart';

class AgentRun {
  final String id;
  final String request;
  final AgentRunStatus status;
  final List<AgentStep> steps;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? error;

  const AgentRun({
    required this.id,
    required this.request,
    required this.status,
    required this.steps,
    required this.startedAt,
    this.completedAt,
    this.error,
  });

  AgentRun copyWith({
    AgentRunStatus? status,
    List<AgentStep>? steps,
    DateTime? completedAt,
    String? error,
  }) {
    return AgentRun(
      id: id,
      request: request,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
    );
  }
}
