import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import '../../models/plan.dart';
import '../../providers/chat_providers.dart';
import '../../providers/project_providers.dart';
import '../../providers/session_actions.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_colors.dart';
import '../common/status_badge.dart';
import 'approval_request_card.dart';
import 'checkpoint_menu_button.dart';
import 'chat_message_bubble.dart';
import 'plan_card.dart';
import 'running_tasks_panel.dart';
import 'tool_call_row.dart';
import 'chat_input_bar.dart';

/// The center column: breadcrumb header with live session status, scrollable
/// transcript made of reusable [ChatMessageBubble]/[ToolCallRow]/
/// [ApprovalRequestCard] rows, the collapsible task tray, and the composer.
class ChatPanel extends ConsumerWidget {
  const ChatPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(activeSessionIdProvider);
    final entries = ref.watch(chatTranscriptProvider(sessionId));

    // Appends server-pushed follow-up events (see AgentRepository) as they
    // arrive. Guarded on agentRunningProvider so a stopped session doesn't
    // keep receiving events the user already asked to halt.
    ref.listen(agentEventsProvider(sessionId), (previous, next) {
      final entry = next.valueOrNull;
      if (entry == null) return;
      if (!ref.read(agentRunningProvider)) return;
      final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);
      notifier.appendEntry(entry);
      // The scripted "run tests" event doubles as real progress on the
      // plan's "Run the test suite" step, instead of the plan being a
      // static list that never reflects what actually happened.
      if (entry.id == 'live-tc1') {
        notifier.updatePlanStepStatus('plan1', 'p4', PlanStepStatus.done);
      }
    });

    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          const _ChatHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final ChatEntry e = entries[i];
                switch (e.type) {
                  case ChatEntryType.stepEvent:
                    return StepEventRow(entry: e);
                  case ChatEntryType.toolCall:
                    return ToolCallRow(call: e.toolCall!);
                  case ChatEntryType.approvalRequest:
                    return ApprovalRequestCard(request: e.approval!);
                  case ChatEntryType.plan:
                    return PlanCard(plan: e.plan!);
                  case ChatEntryType.userPrompt:
                  case ChatEntryType.agentText:
                    return ChatMessageBubble(entry: e);
                }
              },
            ),
          ),
          const RunningTasksPanel(),
          const _StopBanner(),
          const ChatInputBar(),
        ],
      ),
    );
  }
}

/// Shown above the composer while the agent is mid-run; lets the user
/// interrupt execution immediately instead of waiting for it to finish.
class _StopBanner extends ConsumerWidget {
  const _StopBanner();

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
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: AppTheme.accentBlue,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Agent is running…',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
            ),
          ),
          TextButton.icon(
            onPressed: () => ref.read(agentRunningProvider.notifier).stop(),
            icon: const Icon(
              Icons.stop_circle_outlined,
              size: 16,
              color: Color(0xFFE0554C),
            ),
            label: const Text(
              'Stop',
              style: TextStyle(color: Color(0xFFE0554C), fontSize: 12.5),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(activeProjectProvider);
    final session = ref.watch(activeSessionProvider);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.folder_open,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            project.name,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            session.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          StatusBadge(status: session.status),
          const Spacer(),
          Tooltip(
            message: 'Fork this session',
            child: IconButton(
              onPressed: () => forkActiveSession(ref),
              icon: const Icon(
                Icons.call_split,
                size: 17,
                color: AppTheme.textSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
          const CheckpointMenuButton(),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.bolt, size: 15, color: AppTheme.accentBlue),
            label: const Text(
              'Open IDE',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.5),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
