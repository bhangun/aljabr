import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/running_task.dart';
import '../../providers/chat_providers.dart';
import '../../theme/app_colors.dart';

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
          InkWell(
            onTap: () => ref.read(taskTrayExpandedProvider.notifier).toggle(),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${tasks.length} tasks running',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                children: [for (final t in tasks) RunningTaskRow(task: t)],
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable single row for a background task (timer or shell command).
class RunningTaskRow extends StatelessWidget {
  final RunningTask task;
  const RunningTaskRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: task.isSpinning
                ? const CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: AppTheme.textMuted,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
          ),
          const SizedBox(width: 10),
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
        ],
      ),
    );
  }
}
