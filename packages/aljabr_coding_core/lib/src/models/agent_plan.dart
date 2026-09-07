import 'plan_step.dart';

/// A plan the agent lays out before executing — the thing that turns a
/// black-box "the agent is doing stuff" into a checklist the user can
/// actually follow along with and see update as real progress happens.
class AgentPlan {
  final String title;
  final List<PlanStep> steps;

  const AgentPlan({required this.title, required this.steps});

  AgentPlan copyWith({List<PlanStep>? steps}) {
    return AgentPlan(title: title, steps: steps ?? this.steps);
  }

  int get completedCount =>
      steps.where((s) => s.status == PlanStepStatus.done).length;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }

  factory AgentPlan.fromJson(Map<String, dynamic> json) {
    return AgentPlan(
      title: json['title'],
      steps: (json['steps'] as List).map((s) => PlanStep.fromJson(s)).toList(),
    );
  }
}
