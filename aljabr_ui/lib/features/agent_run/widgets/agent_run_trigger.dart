import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agent_run_provider.dart';
import 'agent_run_panel.dart';

class AgentRunTrigger extends ConsumerWidget {
  const AgentRunTrigger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Run agent',
      icon: const Icon(Icons.play_circle_outline),
      onPressed: () {
        // Start a simulated run and show the panel
        ref
            .read(agentRunProvider.notifier)
            .startRun('Fix authentication bug and add tests');
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (ctx) => const FractionallySizedBox(
            heightFactor: 0.85,
            child: AgentRunPanel(),
          ),
        );
      },
    );
  }
}
