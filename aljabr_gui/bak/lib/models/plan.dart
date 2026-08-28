import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PlanStepStatus { pending, inProgress, done, skipped }

extension PlanStepStatusX on PlanStepStatus {
  IconData get icon {
    switch (this) {
      case PlanStepStatus.pending:
        return Icons.radio_button_unchecked;
      case PlanStepStatus.inProgress:
        return Icons.autorenew;
      case PlanStepStatus.done:
        return Icons.check_circle;
      case PlanStepStatus.skipped:
        return Icons.remove_circle_outline;
    }
  }

  Color get color {
    switch (this) {
      case PlanStepStatus.pending:
        return AppTheme.textMuted;
      case PlanStepStatus.inProgress:
        return AppTheme.accentBlue;
      case PlanStepStatus.done:
        return AppTheme.accentGreen;
      case PlanStepStatus.skipped:
        return AppTheme.textMuted;
    }
  }
}

/// One step in an [AgentPlan]. Mutable in the sense that its status updates
/// in place as the agent actually completes work — see
/// `ChatTranscriptNotifier.updatePlanStepStatus`.
class PlanStep {
  final String id;
  final String description;
  final PlanStepStatus status;

  const PlanStep({
    required this.id,
    required this.description,
    this.status = PlanStepStatus.pending,
  });

  PlanStep copyWith({PlanStepStatus? status}) {
    return PlanStep(
      id: id,
      description: description,
      status: status ?? this.status,
    );
  }
}

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
}
