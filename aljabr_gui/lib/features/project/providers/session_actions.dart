import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

import '../../../data/backend_providers.dart';
import '../../chat/models/agent_plan.dart';
import '../../chat/models/plan_step.dart';
import '../../chat/models/tool_call.dart';
import '../../chat/providers/chat_transcript_provider.dart';
import '../../diff/providers/diff_providers.dart';
import '../models/session_mode.dart';
import '../models/session_statusx.dart';
import 'active_session_provider.dart';
import 'session_list_provider.dart';
import '../../chat/models/chat_entry.dart';

/// Fork active session with all state - FULL or PARTIAL HISTORY COPY
Future<void> forkActiveSession(WidgetRef ref, {String? fromMessageId}) async {
  final activeId = ref.read(activeSessionIdProvider);
  if (activeId.isEmpty) {
    _showError(ref, 'No active session to fork');
    return;
  }

  try {
    // ── 1. Get current session data ──────────────────────────────────────
    final service = ref.read(backendServiceProvider);
    final currentSession = ref.read(activeSessionProvider);
    if (currentSession == null) {
      _showError(ref, 'Current session not found');
      return;
    }

    // ── 2. Get full transcript (ALL messages) ───────────────────────────
    final transcriptNotifier =
        ref.read(chatTranscriptProvider(activeId).notifier);
    final currentTranscript = ref.read(chatTranscriptProvider(activeId));
    final pendingQueue = transcriptNotifier.pendingEntries;
    final pendingCount = transcriptNotifier.pendingCount;
    final queueSize = transcriptNotifier.queueSize;

    // ── 3. Get diff state ──────────────────────────────────────────────────
    final parentDiffs = ref.read(fileDiffsProvider(activeId));

    // ── 4. Get session mode ───────────────────────────────────────────────
    final sessionMode = currentSession.mode;

    // ── 5. Create forked session on backend ──────────────────────────────
    final forked = await service.forkSession(activeId, fromMessageId);
    final newId = forked.id;

    logDebug('FORK: Created new session $newId from $activeId');

    // ── 6. Clone diff state ───────────────────────────────────────────────
    registerForkedDiffs(newId, parentDiffs);
    logDebug('FORK: Cloned ${parentDiffs.length} diffs');

    // ── 7. Add session to list and select it ─────────────────────────────
    final newSession = forked.copyWith(
      pendingCount: pendingCount,
      queueSize: queueSize,
      status: SessionStatus.created,
      isSelected: false,
      title: '${currentSession.title} (Fork)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      fileChanges: currentSession.fileChanges,
      messageCount: currentSession.messageCount,
    );

    ref.read(sessionListProvider.notifier).addSession(newSession);
    logInfo(
        'FORK: Added session to list with pendingCount=$pendingCount, queueSize=$queueSize');

    // ── 8. Clone transcript entries (up to fromMessageId if provided) ─────
    final forkedTranscriptNotifier =
        ref.read(chatTranscriptProvider(newId).notifier);

    if (currentTranscript.isNotEmpty) {
      for (final entry in currentTranscript) {
        final clonedEntry = _cloneEntry(entry);
        forkedTranscriptNotifier.appendEntry(clonedEntry);
        if (fromMessageId != null && entry.id == fromMessageId) {
          break;
        }
      }
      logDebug('FORK: Cloned transcript entries');
    }

    // ── 9. Restore pending queue ─────────────────────────────────────────
    if (pendingQueue.isNotEmpty) {
      forkedTranscriptNotifier.restorePendingQueue(pendingQueue);
      logDebug('FORK: Restored ${pendingQueue.length} pending entries');
    }

    // ── 10. Restore session mode ──────────────────────────────────────────
    forkedTranscriptNotifier.setSessionMode(sessionMode);
    logDebug('FORK: Restored session mode: $sessionMode');

    // ── 11. Select the new session ────────────────────────────────────────
    ref.read(sessionListProvider.notifier).select(newId);
    ref.read(activeSessionIdProvider.notifier).select(newId);
    logDebug('FORK: Selected new session');

    // ── 12. Show success message ──────────────────────────────────────────
    _showSuccess(ref, 'Session forked successfully');
  } catch (e, stacktrace) {
    logDebug('FORK ERROR: $e');
    logInfo(stacktrace.toString());
    _showError(ref, 'Failed to fork session: ${e.toString()}');

    // Add error to current session transcript
    ref
        .read(chatTranscriptProvider(activeId).notifier)
        .appendStep('❌ Failed to fork session: ${e.toString()}');
  }
}

/// Clone a chat entry with new ID and timestamp
ChatEntry _cloneEntry(ChatEntry entry) {
  return ChatEntry(
    id: 'fork-${DateTime.now().millisecondsSinceEpoch}-${entry.id}',
    type: entry.type,
    status: entry.status,
    text: entry.text,
    isLoading: entry.isLoading,
    timestamp: DateTime.now(),
    toolCall: entry.toolCall != null ? _cloneToolCall(entry.toolCall!) : null,
    approval: entry.approval,
    plan: entry.plan != null ? _clonePlan(entry.plan!) : null,
    attachments: entry.attachments,
    errorMessage: entry.errorMessage,
    retryCount: entry.retryCount,
    metadata: {
      ...entry.metadata ?? {},
      'forkedFrom': entry.id,
      'forkedAt': DateTime.now().toIso8601String(),
    },
    jobId: entry.jobId,
    queuePosition: entry.queuePosition,
  );
}

/// Clone a tool call
ToolCall _cloneToolCall(ToolCall toolCall) {
  return ToolCall(
    id: 'fork-${DateTime.now().millisecondsSinceEpoch}-${toolCall.id}',
    kind: toolCall.kind,
    summary: toolCall.summary,
    detailInput: toolCall.detailInput,
    detailOutput: toolCall.detailOutput,
    status: toolCall.status,
    risk: toolCall.risk,
    duration: toolCall.duration,
    errorMessage: toolCall.errorMessage,
    subtasks: toolCall.subtasks,
    result: toolCall.result,
    progress: toolCall.progress,
    isBlocking: toolCall.isBlocking,
  );
}

/// Clone a plan
AgentPlan _clonePlan(AgentPlan plan) {
  return AgentPlan(
    title: plan.title,
    steps: plan.steps
        .map((step) => PlanStep(
              id: 'fork-${DateTime.now().millisecondsSinceEpoch}-${step.id}',
              description: step.description,
              status: step.status,
            ))
        .toList(),
  );
}

/// Show success message
void _showSuccess(WidgetRef ref, String message) {
  // You can use a toast/snackbar service here
  logDebug('✅ FORK SUCCESS: $message');
}

/// Show error message
void _showError(WidgetRef ref, String message) {
  logDebug('❌ FORK ERROR: $message');
}

/// Force process all pending entries in a session
Future<void> forceProcessAllPending(WidgetRef ref, String sessionId) async {
  final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);
  await notifier.forceProcessAll();
}

/// Force process a single pending entry
Future<void> forceProcessSingle(
    WidgetRef ref, String sessionId, String entryId) async {
  final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);
  await notifier.forceProcessSingle(entryId);
}

/// Cancel all pending entries
void cancelAllPending(WidgetRef ref, String sessionId) {
  final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);
  notifier.cancelPendingAll();
  notifier.appendStep('🛑 All pending operations cancelled');
}

/// Pause/resume session
void toggleSessionPause(WidgetRef ref, String sessionId) {
  final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);
  notifier.togglePause();
}

/// Update session execution mode
void updateSessionMode(WidgetRef ref, String sessionId, SessionMode mode) {
  final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);
  notifier.toggleSessionMode(mode);
}
