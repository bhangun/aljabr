import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../project/providers/active_project_provider.dart';
import '../../../project/providers/active_session_provider.dart';
import '../../providers/chat_transcript_provider.dart';
import '../../../../theme/app_colors.dart';

import 'agent_stop_banner.dart';
import 'chat_header.dart';
import 'chat_input_bar.dart';
import 'chat_transcript.dart';
import '../running_tasks_panel.dart';
import '../queue_status_widget.dart';
import '../../providers/running_task_provider.dart';

/// Main chat panel - orchestrates all chat-related components
class ChatPanel extends ConsumerWidget {
  final List<String> slashCommands;
  const ChatPanel({super.key, this.slashCommands = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawSessionId = ref.watch(activeSessionIdProvider);
    final sessionId =
        (rawSessionId.isNotEmpty && rawSessionId != kGeneralSessionId)
            ? rawSessionId
            : kGeneralSessionId;
    final activeProject = ref.watch(activeProjectProvider);

    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          const ChatHeader(),
          if (activeProject == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppTheme.panelAlt.withValues(alpha: 0.7),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppTheme.accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'General Assistant Mode — Chatting with Aljabr Agent (No project attached)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: ChatTranscript(
              sessionId: sessionId,
              entries: const [],
            ),
          ),
          const RunningTasksPanel(),
          const AgentStopBanner(),

          // ── Queue status bar (isolated rebuild) ───────────────────────
          Consumer(
            builder: (context, ref, _) {
              final notifier =
                  ref.watch(chatTranscriptProvider(sessionId).notifier);
              final runningTasks = ref.watch(runningTasksProvider);
              if (notifier.pendingEntries.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: QueueStatusWidget(
                  pendingEntries: notifier.pendingEntries,
                  queueSize: notifier.queueSize,
                  activeJobs: runningTasks.length,
                  onForceProcessAll: () => notifier.forceProcessAll(),
                  onForceProcessSingle: (id) => notifier.forceProcessSingle(id),
                  onClearQueue: () => notifier.forceProcessAll(),
                ),
              );
            },
          ),

          ChatInputBar(slashCommands: slashCommands),
        ],
      ),
    );
  }
}
