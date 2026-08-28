import 'package:flutter/material.dart';
import '../../models/plan.dart';
import '../../theme/app_colors.dart';

/// Renders an [AgentPlan] as a checklist. Step statuses update live as the
/// agent progresses (see `ChatTranscriptNotifier.updatePlanStepStatus`),
/// so this is the one place a user can see the whole run's shape at a
/// glance instead of just scrolling through a transcript.
class PlanCard extends StatelessWidget {
  final AgentPlan plan;
  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, size: 16, color: AppTheme.accentBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${plan.completedCount}/${plan.steps.length}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final step in plan.steps) _PlanStepRow(step: step),
        ],
      ),
    );
  }
}

class _PlanStepRow extends StatelessWidget {
  final PlanStep step;
  const _PlanStepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final done = step.status == PlanStepStatus.done;
    final skipped = step.status == PlanStepStatus.skipped;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          step.status == PlanStepStatus.inProgress
              ? SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: step.status.color,
                  ),
                )
              : Icon(step.status.icon, size: 15, color: step.status.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step.description,
              style: TextStyle(
                color: done || skipped
                    ? AppTheme.textMuted
                    : AppTheme.textSecondary,
                fontSize: 13,
                decoration: skipped ? TextDecoration.lineThrough : null,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
