import 'package:flutter/material.dart';
import '../models/agent_run.dart';
import '../models/agent_run_status.dart';

class AgentRunHeader extends StatelessWidget {
  const AgentRunHeader({super.key, required this.run});
  final AgentRun run;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AgentIcon(status: run.status),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aljabr Agent',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(run.request,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        _RunStatus(status: run.status),
      ],
    );
  }
}

class _AgentIcon extends StatelessWidget {
  const _AgentIcon({required this.status});
  final AgentRunStatus status;

  @override
  Widget build(BuildContext context) {
    final isRunning =
        status == AgentRunStatus.running || status == AgentRunStatus.planning;
    final color = isRunning
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Icon(isRunning ? Icons.auto_awesome : Icons.check_circle_outline,
          color: color, size: 18),
    );
  }
}

class _RunStatus extends StatelessWidget {
  const _RunStatus({required this.status});
  final AgentRunStatus status;

  @override
  Widget build(BuildContext context) {
    String label;
    switch (status) {
      case AgentRunStatus.planning:
        label = 'Planning';
        break;
      case AgentRunStatus.running:
        label = 'Running';
        break;
      case AgentRunStatus.waitingForApproval:
        label = 'Awaiting approval';
        break;
      case AgentRunStatus.completed:
        label = 'Completed';
        break;
      case AgentRunStatus.failed:
        label = 'Failed';
        break;
      case AgentRunStatus.cancelled:
        label = 'Cancelled';
        break;
    }

    return Text(label, style: Theme.of(context).textTheme.bodySmall);
  }
}
