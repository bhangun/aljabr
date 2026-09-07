import 'package:flutter/material.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// Renders an [AgentPlan] as an interactive autonomous checklist combining
/// Antigravity-style Task Tracking and Verification Ladder progression.
class PlanCard extends StatelessWidget {
  final AgentPlan plan;
  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDone = plan.completedCount == plan.steps.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone
              ? const Color(0xFF34C759).withValues(alpha: 0.4)
              : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDone ? Icons.task_alt : Icons.checklist,
                size: 16,
                color: isDone ? const Color(0xFF34C759) : AppTheme.accentBlue,
              ),
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
              // Verification Level Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFF34C759).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 11, color: Color(0xFF34C759)),
                    SizedBox(width: 4),
                    Text(
                      'L2 Verified',
                      style: TextStyle(
                        color: Color(0xFF34C759),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${plan.completedCount}/${plan.steps.length}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 3.5),
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
