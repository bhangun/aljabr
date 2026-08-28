import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agent_run_provider.dart';
import 'agent_run_header.dart';
import 'agent_timeline.dart';
import 'agent_run_actions.dart';

class AgentRunPanel extends ConsumerWidget {
  const AgentRunPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(agentRunProvider);
    if (run == null) {
      return const Center(child: Text('No agent run active'));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AgentRunHeader(run: run),
          const SizedBox(height: 12),
          AgentTimeline(steps: run.steps),
          const SizedBox(height: 12),
          AgentRunActions(run: run),
        ],
      ),
    );
  }
}
