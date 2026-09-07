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
        id: id, description: description, status: status ?? this.status);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'status': status.toString(),
    };
  }

  factory PlanStep.fromJson(Map<String, dynamic> json) {
    return PlanStep(
      id: json['id'],
      description: json['description'],
      status: PlanStepStatus.values
          .firstWhere((e) => e.toString() == json['status']),
    );
  }
}
