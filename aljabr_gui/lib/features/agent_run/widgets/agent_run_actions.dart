import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent_run.dart';
import '../models/agent_run_status.dart';
import '../providers/agent_run_provider.dart';

class AgentRunActions extends ConsumerWidget {
  const AgentRunActions({super.key, required this.run});
  final AgentRun run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(agentRunProvider.notifier);

    if (run.status == AgentRunStatus.planning ||
        run.status == AgentRunStatus.running) {
      return Row(
        children: [
          ElevatedButton(
              onPressed: () => notifier.cancel(),
              child: const Text('Stop agent')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () => notifier.approve(),
              child: const Text('Approve')),
        ],
      );
    }

    if (run.status == AgentRunStatus.waitingForApproval) {
      return Row(
        children: [
          OutlinedButton(
              onPressed: () => notifier.cancel(), child: const Text('Reject')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () => notifier.approve(), child: const Text('Allow')),
        ],
      );
    }

    if (run.status == AgentRunStatus.completed) {
      return Row(children: [
        Text('Completed at ${run.completedAt}'),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () {}, child: const Text('Review changes'))
      ]);
    }

    return const SizedBox.shrink();
  }
}
