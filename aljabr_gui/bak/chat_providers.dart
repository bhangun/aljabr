import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/agent_repository.dart';
import '../../../models/approval_request.dart';
import '../../../models/chat_message.dart';
import '../../../models/plan.dart';
import '../../../models/running_task.dart';
import '../../../models/tool_call.dart';
import '../../project/providers/session_providers.dart';

/// The chat transcript, mixing plain agent text with structured [ToolCall]
/// rows and a blocking [ApprovalRequest] gate, the way Codex/Antigravity
/// interleave narration with actual tool execution.
///
/// Scoped per session (see [chatTranscriptProvider]'s `.family`) so forking
/// a session gives it its own independent transcript instead of sharing
/// the one the whole app used to point at.
class ChatTranscriptNotifier extends StateNotifier<List<ChatEntry>> {
  ChatTranscriptNotifier(super.seed);

  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;
    state = [
      ...state,
      ChatEntry(
        id: 'u-${DateTime.now().microsecondsSinceEpoch}',
        type: ChatEntryType.userPrompt,
        text: text.trim(),
      ),
    ];
  }

  /// Appends a server-pushed event (see [AgentRepository]) if it isn't
  /// already present — the stream can, in principle, replay, so this stays
  /// idempotent on entry id.
  void appendEntry(ChatEntry entry) {
    if (state.any((e) => e.id == entry.id)) return;
    state = [...state, entry];
  }

  /// Appends a lightweight step/status row (e.g. "Stopped by user").
  void appendStep(String text) {
    state = [
      ...state,
      ChatEntry(
        id: 'step-${DateTime.now().microsecondsSinceEpoch}',
        type: ChatEntryType.stepEvent,
        text: text,
      ),
    ];
  }

  /// Resolves a pending [ApprovalRequest] in place, then (if approved)
  /// appends the tool call it was gating.
  void resolveApproval(String approvalId, bool approved) {
    state = [
      for (final e in state)
        if (e.type == ChatEntryType.approvalRequest &&
            e.approval?.id == approvalId)
          e.copyWith(
            approval: e.approval!.copyWith(
              status:
                  approved ? ApprovalStatus.approved : ApprovalStatus.denied,
            ),
          )
        else
          e,
    ];

    if (approved) {
      state = [
        ...state,
        ChatEntry(
          id: 'tc-post-approval-${DateTime.now().microsecondsSinceEpoch}',
          type: ChatEntryType.toolCall,
          toolCall: const ToolCall(
            id: 'tc-push',
            kind: ToolCallKind.runCommand,
            summary: 'git push origin main',
            detailInput: 'git push origin main',
            detailOutput:
                'Enumerating objects... done.\nTo github.com:wayang-platform/wayang-code.git\n   4f2a1c9..9b7e0d1  main -> main',
            status: ToolCallStatus.success,
            duration: Duration(seconds: 3),
          ),
        ),
      ];
    } else {
      appendStep('Push denied — the agent will wait for further instructions.');
    }
  }

  /// Updates a single step's status within a [ChatEntryType.plan] entry —
  /// how the plan checklist stays in sync with what the agent has actually
  /// finished, rather than being a static list printed once.
  void updatePlanStepStatus(
      String planEntryId, String stepId, PlanStepStatus status) {
    state = [
      for (final e in state)
        if (e.id == planEntryId && e.plan != null)
          e.copyWith(
            plan: e.plan!.copyWith(
              steps: [
                for (final s in e.plan!.steps)
                  if (s.id == stepId) s.copyWith(status: status) else s,
              ],
            ),
          )
        else
          e,
    ];
  }

  /// Truncates the transcript back to [cutoff] entries and appends a note —
  /// used when the user restores a [Checkpoint].
  void restoreToCheckpoint(int cutoff, String label) {
    final kept = state.take(cutoff).toList();
    state = [
      ...kept,
      ChatEntry(
        id: 'restore-${DateTime.now().microsecondsSinceEpoch}',
        type: ChatEntryType.stepEvent,
        text:
            'Restored to checkpoint "$label" — later messages and file changes were discarded.',
      ),
    ];
  }
}

/// Seed transcripts keyed by session id. `wayang-code` ships with the full
/// mock walkthrough; forked sessions get registered here at fork time
/// (see [registerForkedTranscript] in session_actions.dart); anything else
/// starts empty.
final Map<String, List<ChatEntry>> _seedTranscripts = {
  'wayang-code': const [
    ChatEntry(
      id: 'plan1',
      type: ChatEntryType.plan,
      plan: AgentPlan(
        title: 'Get the dev server running',
        steps: [
          PlanStep(
            id: 'p1',
            description: 'Start PostgreSQL and Redis via Docker Compose',
            status: PlanStepStatus.done,
          ),
          PlanStep(
            id: 'p2',
            description: 'Boot the Quarkus dev server',
            status: PlanStepStatus.done,
          ),
          PlanStep(
            id: 'p3',
            description: 'Fix the Hibernate JSON mapping config',
            status: PlanStepStatus.done,
          ),
          PlanStep(
              id: 'p4',
              description: 'Run the test suite',
              status: PlanStepStatus.inProgress),
          PlanStep(
            id: 'p5',
            description: 'Push changes to main (needs approval)',
            status: PlanStepStatus.pending,
          ),
        ],
      ),
    ),
    ChatEntry(id: 'e0', type: ChatEntryType.userPrompt, text: 'continue'),
    ChatEntry(
      id: 'tc1',
      type: ChatEntryType.toolCall,
      toolCall: ToolCall(
        id: 'tc1',
        kind: ToolCallKind.runCommand,
        summary: 'docker compose up -d postgres redis',
        detailInput: 'docker compose up -d postgres redis',
        detailOutput:
            ' ✔ Container wayang-postgres  Started\n ✔ Container wayang-redis     Started',
        status: ToolCallStatus.success,
        duration: Duration(seconds: 16),
      ),
    ),
    ChatEntry(
      id: 'e1',
      type: ChatEntryType.agentText,
      text:
          'containers, and started the `mvn quarkus:dev` process. I am waiting for these to finish starting up to verify if the server boots successfully!',
    ),
    ChatEntry(
      id: 'tc2',
      type: ChatEntryType.toolCall,
      toolCall: ToolCall(
        id: 'tc2',
        kind: ToolCallKind.runCommand,
        summary: 'mvn quarkus:dev -Dquarkus.http.port=8086',
        detailInput: 'mvn quarkus:dev -Dquarkus.http.port=8086',
        detailOutput:
            '[INFO] Scanning for projects...\n[INFO] Building wayang-platform-api\nINFO  [io.quarkus] Profile dev activated. Live Coding activated.',
        status: ToolCallStatus.success,
        duration: Duration(seconds: 29),
      ),
    ),
    ChatEntry(
      id: 'e9',
      type: ChatEntryType.agentText,
      text:
          "Docker Compose is now up and running with PostgreSQL and Redis! The API resolved Maven dependencies and booted with the new configuration.",
    ),
    ChatEntry(
      id: 'tc3',
      type: ChatEntryType.toolCall,
      toolCall: ToolCall(
        id: 'tc3',
        kind: ToolCallKind.editFile,
        summary: 'src/main/resources/application.properties',
        detailInput: '+ quarkus.hibernate-orm.mapping.format.global=ignore',
        detailOutput: 'File updated. 1 insertion(+).',
        status: ToolCallStatus.success,
        duration: Duration(seconds: 2),
      ),
    ),
    ChatEntry(
      id: 'e13',
      type: ChatEntryType.agentText,
      text:
          "I've added the property `quarkus.hibernate-orm.mapping.format.global=ignore` to fix the JSON serialization configuration issue that Hibernate reported:\n\n"
          "```properties\n"
          "quarkus.hibernate-orm.database.generation=none\n"
          "quarkus.hibernate-orm.mapping.format.global=ignore\n"
          "```\n\n"
          "Summary of what changed so far:\n"
          "- Started **PostgreSQL** and **Redis** via Docker Compose\n"
          "- Fixed the Hibernate JSON mapping property\n"
          "- Restarted the Quarkus dev server\n\n"
          "Review the exact diff in the **Diff** tab.",
    ),
    ChatEntry(
      id: 'ap1',
      type: ChatEntryType.approvalRequest,
      approval: ApprovalRequest(
        id: 'ap1',
        command: 'git push origin main',
        reason:
            'This pushes 3 commits directly to main with no open PR. Confirm before the agent proceeds.',
        risk: RiskLevel.dangerous,
      ),
    ),
  ],
};

/// Registers a seed transcript for a session id — used when forking so the
/// new session starts from a snapshot of its parent instead of empty.
void registerForkedTranscript(String sessionId, List<ChatEntry> entries) {
  _seedTranscripts[sessionId] = entries;
}

List<ChatEntry> _seedFor(String sessionId) =>
    _seedTranscripts[sessionId] ??
    const [
      ChatEntry(
        id: 'new-session-hint',
        type: ChatEntryType.stepEvent,
        text: 'New session — send a message to get started.',
      ),
    ];

final chatTranscriptProvider = StateNotifierProvider.family<
    ChatTranscriptNotifier, List<ChatEntry>, String>(
  (ref, sessionId) => ChatTranscriptNotifier(_seedFor(sessionId)),
);

/// Whether the agent is actively mid-run for the current session — drives
/// the Stop/interrupt affordance above the composer.
class AgentRunningNotifier extends StateNotifier<bool> {
  final Ref _ref;
  AgentRunningNotifier(this._ref) : super(true);

  void stop() {
    state = false;
    final sessionId = _ref.read(activeSessionIdProvider);
    _ref
        .read(chatTranscriptProvider(sessionId).notifier)
        .appendStep('Stopped by user');
  }
}

final agentRunningProvider = StateNotifierProvider<AgentRunningNotifier, bool>(
  (ref) => AgentRunningNotifier(ref),
);

/// Background task tray ("2 tasks running").
class RunningTasksNotifier extends StateNotifier<List<RunningTask>> {
  RunningTasksNotifier()
      : super(const [
          RunningTask(
            id: 't1',
            label:
                'Timer: 10s, Prompt: Check if the dev server successfully booted after …',
            isSpinning: false,
          ),
          RunningTask(
            id: 't2',
            label: 'mvn quarkus:dev -Dquarkus.http.port=8086',
          ),
        ]);

  void remove(String id) => state = state.where((t) => t.id != id).toList();
}

final runningTasksProvider =
    StateNotifierProvider<RunningTasksNotifier, List<RunningTask>>(
  (ref) => RunningTasksNotifier(),
);

class TaskTrayExpandedNotifier extends StateNotifier<bool> {
  TaskTrayExpandedNotifier() : super(true);
  void toggle() => state = !state;
}

final taskTrayExpandedProvider =
    StateNotifierProvider<TaskTrayExpandedNotifier, bool>(
  (ref) => TaskTrayExpandedNotifier(),
);

final selectedModelProvider =
    StateProvider<String>((ref) => 'Gemini 3.1 Pro (High)');

/// The data-layer seam: swap [MockAgentRepository] for a real WebSocket/SSE
/// implementation here and nothing above this line needs to change.
final agentRepositoryProvider =
    Provider<AgentRepository>((ref) => MockAgentRepository());

/// Server-pushed follow-up events for a session, surfaced as a stream so
/// the transcript keeps moving even after the initial mock history loads —
/// consumed via `ref.listen` in [ChatPanel] rather than watched directly,
/// since each emission is an event to append, not a value to render.
final agentEventsProvider =
    StreamProvider.family<ChatEntry, String>((ref, sessionId) {
  return ref.watch(agentRepositoryProvider).observeSession(sessionId);
});

/// Rough token/cost estimate for a session, derived from its transcript.
/// A real integration would read actual usage from the API response;
/// this approximates from character counts (~4 chars/token) purely for
/// giving the UI something live to display.
final sessionUsageProvider =
    Provider.family<(int tokens, double costUsd), String>(
  (ref, sessionId) {
    final entries = ref.watch(chatTranscriptProvider(sessionId));
    int tokens = 0;
    for (final e in entries) {
      tokens += (e.text.length / 4).ceil();
      final tc = e.toolCall;
      if (tc != null) {
        tokens +=
            (((tc.detailInput?.length ?? 0) + (tc.detailOutput?.length ?? 0)) /
                    4)
                .ceil();
        tokens += 40; // fixed per-call overhead
      }
    }
    final costUsd = tokens / 1000 * 0.015;
    return (tokens, costUsd);
  },
);
