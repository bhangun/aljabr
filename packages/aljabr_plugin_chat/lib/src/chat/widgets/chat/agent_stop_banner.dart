import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../../providers/agent_runtime_provider.dart';
import '../running_indicator.dart';
import '../button/stop_button.dart';

class AgentStopBanner extends ConsumerWidget {
  const AgentStopBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(agentRunningProvider);
    if (!running) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const RunningIndicator(),
          const Gap(10),
          const Expanded(
            child: Text(
              'Agent is running…',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
            ),
          ),
          StopButton(
              onPressed: () => ref.read(agentRunningProvider.notifier).stop()),
        ],
      ),
    );
  }
}
