// widgets/chat/running_tasks_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../models/running_task.dart';
import '../../../theme/app_colors.dart';
import '../providers/running_task_provider.dart';
import '../providers/task_tray_expander_provider.dart';

/// The "2 tasks running" collapsible tray sitting above the composer.
class RunningTasksPanel extends ConsumerWidget {
  const RunningTasksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(runningTasksProvider);
    final expanded = ref.watch(taskTrayExpandedProvider);

    if (tasks.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TrayHeader(
            taskCount: tasks.length,
            expanded: expanded,
            onToggle: () =>
                ref.read(taskTrayExpandedProvider.notifier).toggle(),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                children: tasks.map((t) => RunningTaskRow(task: t)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrayHeader extends StatelessWidget {
  final int taskCount;
  final bool expanded;
  final VoidCallback onToggle;

  const _TrayHeader({
    required this.taskCount,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Text(
              '$taskCount tasks running',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 18,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable single row for a background task (timer or shell command).
class RunningTaskRow extends ConsumerWidget {
  final RunningTask task;
  const RunningTaskRow({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TaskStatusIndicator(isSpinning: task.isSpinning),
          const Gap(10),
          Expanded(
            child: Text(
              task.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const Gap(8),
          Tooltip(
            message: 'Stop task',
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                ref.read(runningTasksProvider.notifier).remove(task.id);
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskStatusIndicator extends StatelessWidget {
  final bool isSpinning;
  const _TaskStatusIndicator({required this.isSpinning});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: isSpinning
          ? const CircularProgressIndicator(
              strokeWidth: 1.8,
              color: AppTheme.textMuted,
            )
          : const Icon(
              Icons.radio_button_unchecked,
              size: 14,
              color: AppTheme.textMuted,
            ),
    );
  }
}
