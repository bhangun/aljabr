Yes. Let’s move from architecture into **actual implementation**, but I want to adjust one thing from the previous proposal after reviewing the source more closely.

Your GUI **already has**:

* `ToolCallStatus`
* `ToolCallTiming`
* `AgentRunningNotifier`
* `ChatEntry`
* `ToolCall`
* `ApprovalRequest`
* `AgentPlan`
* `appendStep()`
* pause/resume/cancel
* persistent serialization of tool calls/plans/approvals.

So **do not create a parallel execution model yet**. That would duplicate state.

Instead, let's improve the existing architecture first.

# Next implementation: Execution HUD + polished tool cards

I would make these changes first:

```text
Current

IdeHomeScreen
 └── ChatPanel
      └── ChatEntry


Improved

IdeHomeScreen
 ├── WorkspaceHeader
 ├── ChatPanel
 │    ├── AgentRunBanner
 │    ├── ChatEntry
 │    │    ├── Message
 │    │    ├── ToolCard
 │    │    ├── PlanCard
 │    │    └── ApprovalCard
 │    └── Composer
 └── Editor
```

This gives us a visible improvement without destabilizing the backend.

---

# 1. Add an `AgentRunBanner`

You already have `agentRunningProvider`, so use it rather than introducing another boolean. 

Create:

```text
features/chat/widgets/agent_run_banner.dart
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/agent_runtime_provider.dart';
import '../providers/chat_transcript_provider.dart';
import '../../project/providers/active_session_provider.dart';

class AgentRunBanner extends ConsumerWidget {
  const AgentRunBanner({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final running = ref.watch(agentRunningProvider);
    final sessionId =
        ref.watch(activeSessionIdProvider);

    if (!running || sessionId == null) {
      return const SizedBox.shrink();
    }

    return _RunningBanner(
      onStop: () {
        ref
            .read(agentRunningProvider.notifier)
            .stop();

        ref
            .read(chatTranscriptProvider(sessionId).notifier)
            .appendStep('Stopped by user');
      },
    );
  }
}

class _RunningBanner extends StatelessWidget {
  const _RunningBanner({
    required this.onStop,
  });

  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            'Aljabr is working',
            style: theme.textTheme.labelLarge,
          ),

          const Spacer(),

          TextButton.icon(
            onPressed: onStop,
            icon: const Icon(
              Icons.stop_circle_outlined,
              size: 17,
            ),
            label: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}
```

This immediately gives the user a clear answer to:

> Is the agent currently doing something?

---

# 2. Put it into `ChatPanel`

Your existing `IdeHomeScreen` composes the sidebar, chat and editor as modular columns. 

Inside the chat column:

```dart
Column(
  children: [
    const AgentRunBanner(),

    Expanded(
      child: ChatTranscript(...),
    ),

    ChatComposer(...),
  ],
)
```

The important UX rule:

**Don't put "Stop" inside the composer only.**

The active execution state should be visible independently.

---

# 3. Upgrade `ToolCall` rendering

Your `ToolCallStatus` already gives us the semantic states:

```text
queued
pending
running
success
error
cancelled
suspended
```

and labels/colors. 

Create:

```text
features/chat/widgets/tool_call_card.dart
```

```dart
import 'package:flutter/material.dart';

import '../models/tool_call.dart';
import '../models/tool_call_status.dart';

class ToolCallCard extends StatefulWidget {
  const ToolCallCard({
    super.key,
    required this.toolCall,
  });

  final ToolCall toolCall;

  @override
  State<ToolCallCard> createState() =>
      _ToolCallCardState();
}

class _ToolCallCardState
    extends State<ToolCallCard> {

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.toolCall;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Row(
                children: [
                  _StatusIcon(
                    status: tool.status,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.summary,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          tool.status.label,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                            color:
                                tool.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (tool.duration != null)
                    Text(
                      _duration(tool.duration!),
                      style: theme.textTheme.labelSmall,
                    ),

                  const SizedBox(width: 6),

                  Icon(
                    expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          if (expanded)
            _ToolDetails(
              tool: tool,
            ),
        ],
      ),
    );
  }

  String _duration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }

    return '${duration.inMilliseconds / 1000}s';
  }
}
```

---

# 4. Status icon

```dart
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.status,
  });

  final ToolCallStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      ToolCallStatus.queued =>
        Icons.schedule,
      ToolCallStatus.pending =>
        Icons.lock_outline,
      ToolCallStatus.running =>
        Icons.sync,
      ToolCallStatus.success =>
        Icons.check_circle_outline,
      ToolCallStatus.error =>
        Icons.error_outline,
      ToolCallStatus.cancelled =>
        Icons.cancel_outlined,
      ToolCallStatus.suspended =>
        Icons.pause_circle_outline,
    };

    return Icon(
      icon,
      size: 18,
      color: status.color,
    );
  }
}
```

---

# 5. Expandable tool details

Your existing `ToolCall` already stores input/output/result/error/progress/subtasks. 

Use them.

```dart
class _ToolDetails extends StatelessWidget {
  const _ToolDetails({
    required this.tool,
  });

  final ToolCall tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Divider(
            color: theme.dividerColor,
          ),

          if (tool.detailInput != null)
            _CodeSection(
              title: 'INPUT',
              content: tool.detailInput!,
            ),

          if (tool.detailOutput != null)
            _CodeSection(
              title: 'OUTPUT',
              content: tool.detailOutput!,
            ),

          if (tool.errorMessage != null)
            _ErrorSection(
              message: tool.errorMessage!,
            ),

          if (tool.progress != null)
            _ProgressSection(
              progress: tool.progress!,
            ),

          if (tool.subtasks != null &&
              tool.subtasks!.isNotEmpty)
            _SubtasksSection(
              subtasks: tool.subtasks!,
            ),
        ],
      ),
    );
  }
}
```

---

# 6. Code sections

```dart
class _CodeSection extends StatelessWidget {
  const _CodeSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: .6,
            ),
          ),

          const SizedBox(height: 5),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(6),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

This makes terminal/file/tool output feel like **developer tooling**, rather than ordinary chat text.

---

# 7. Progress should be visual

Because `ToolCall` already has `progress`, don't display:

```text
Progress: 0.64
```

Use:

```dart
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 4,
        ),
      ),
    );
  }
}
```

---

# 8. Subtasks become a mini timeline

```dart
class _SubtasksSection extends StatelessWidget {
  const _SubtasksSection({
    required this.subtasks,
  });

  final List<String> subtasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        children: [
          for (final task in subtasks)
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(task),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
```

---

# 9. Improve the plan card

You already persist `AgentPlan` and its `PlanStep`s. 

Make it visually useful:

```text
PLAN
────────────────────────

✓ Understand request
✓ Inspect workspace
● Fix Hibernate mapping
○ Run tests
○ Verify

                    3 / 5
```

Code:

```dart
class AgentPlanCard extends StatelessWidget {
  const AgentPlanCard({
    super.key,
    required this.plan,
  });

  final AgentPlan plan;

  @override
  Widget build(BuildContext context) {
    final completed = plan.steps
        .where(
          (s) => s.status == PlanStepStatus.completed,
        )
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_tree_outlined,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    plan.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                ),

                Text(
                  '$completed/${plan.steps.length}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            for (final step in plan.steps)
              _PlanStep(step: step),
          ],
        ),
      ),
    );
  }
}
```

And:

```dart
class _PlanStep extends StatelessWidget {
  const _PlanStep({
    required this.step,
  });

  final PlanStep step;

  @override
  Widget build(BuildContext context) {
    final completed =
        step.status == PlanStepStatus.completed;

    final running =
        step.status == PlanStepStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : running
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
            size: 17,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              step.description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

# 10. Approval needs stronger UX

The runtime actually supports human approval through `ApprovalRequiredException` and an `ApprovalStrategy`. 

So the UI should look important:

```text
┌───────────────────────────────────────────────┐
│ 🔒 Permission required                        │
│                                               │
│ Run command                                   │
│                                               │
│ ./mvnw clean install                          │
│                                               │
│ Risk: CAUTION                                 │
│                                               │
│ [Deny]       [Allow once]       [Allow]       │
└───────────────────────────────────────────────┘
```

Don't make approval another generic message bubble.

---

# 11. Add a proper execution summary

When the agent finishes, show:

```text
✓ Completed

2 files changed
6 tests passed
0 errors
1m 24s

[Review changes]
```

You already have session analytics and tool timing concepts in the GUI. 

Create:

```text
features/chat/widgets/execution_summary.dart
```

```dart
class ExecutionSummary extends StatelessWidget {
  const ExecutionSummary({
    super.key,
    required this.filesChanged,
    required this.testsPassed,
    required this.testsFailed,
    required this.duration,
  });

  final int filesChanged;
  final int testsPassed;
  final int testsFailed;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
          ),

          const SizedBox(width: 8),

          const Text('Completed'),

          const Spacer(),

          _Metric(
            value: '$filesChanged',
            label: 'files',
          ),

          _Metric(
            value: '$testsPassed',
            label: 'tests',
          ),

          _Metric(
            value: _format(duration),
            label: '',
          ),
        ],
      ),
    );
  }

  String _format(Duration value) {
    return '${value.inSeconds}s';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 14,
      ),
      child: Text(
        label.isEmpty
            ? value
            : '$value $label',
        style: Theme.of(context)
            .textTheme
            .labelSmall,
      ),
    );
  }
}
```

---

# 12. Then improve `IdeHomeScreen`

The current screen is intentionally just the three columns. 

I would change the chat column from:

```dart
ChatPanel(...)
```

to:

```dart
Column(
  children: [
    WorkspaceHeader(),

    const AgentRunBanner(),

    Expanded(
      child: ChatPanel(
        ...
      ),
    ),
  ],
)
```

And **keep the editor independent**.

That gives us:

```text
┌──────────────────────────────────────────────────────┐
│ Aljabr   Wayang ▾                    ● Connected      │
├──────────┬──────────────────────────────┬─────────────┤
│ Sidebar  │ Chat                         │ Editor      │
│          │                              │             │
│          │ ● Aljabr is working          │             │
│          │                              │             │
│          │ ✓ Plan                       │             │
│          │ ✓ Search workspace            │             │
│          │ ● Read SessionResource       │             │
│          │                              │             │
│          │ Agent response...            │             │
│          │                              │             │
│          │ [Ask Aljabr...]              │             │
└──────────┴──────────────────────────────┴─────────────┘
```

---

# 13. One important backend improvement after this

I would **not yet create the new `ExecutionViewModel`** from my previous answer.

First, exploit what already exists.

The Wayang framework already exposes:

```java
onAgentStart()
onThought()
onToolStart()
onToolResult()
onAgentEnd()
onAgentError()
```

through `AgentListener`. 

And the ReAct agent already runs the model → tool → result loop. 

So after the UI work above, our next actual code change should be:

```text
Wayang AgentListener
        ↓
ExecutionEvent
        ↓
Aljabr API stream
        ↓
Flutter ChatEntry
```

rather than inventing another parallel state system.

---

# 14. The next commit should therefore be

I would make **one focused commit**:

```text
feat(gui): polish agent execution experience
```

Containing:

```text
+ agent_run_banner.dart
+ tool_call_card.dart
+ agent_plan_card.dart
+ approval_card.dart
+ execution_summary.dart

~ chat_panel.dart
~ ide_home_screen.dart
```

No database migration.

No protobuf changes.

No new backend architecture.

No new state-management system.

That gives us a **safe, immediately visible UX improvement** while preserving the existing `ChatEntry` architecture.

After that, the next commit should be the **streaming execution-event pipeline**, because that is what will make these cards update live instead of merely displaying persisted results. The current GUI already has persistence for the rich `ToolCall`, approval and plan structures, so we can build on that rather than replacing it. 


Next, I would implement the **live execution-event pipeline**. This is the piece that turns the polished cards from static UI into a real-time agent experience.

Your current backend already has the right lifecycle hooks — `onAgentStart`, `onThought`, `onToolStart`, `onToolResult`, `onAgentEnd`, and `onAgentError` — so we should connect those rather than inventing another execution system. 

## 1. Define a small event contract

Create:

```text
backend/
└── .../execution/
    ├── ExecutionEvent.java
    └── ExecutionEventType.java
```

### `ExecutionEventType.java`

```java
public enum ExecutionEventType {
    AGENT_STARTED,
    THOUGHT,
    TOOL_STARTED,
    TOOL_COMPLETED,
    TOOL_FAILED,
    APPROVAL_REQUIRED,
    AGENT_COMPLETED,
    AGENT_FAILED
}
```

### `ExecutionEvent.java`

```java
public record ExecutionEvent(
    String executionId,
    ExecutionEventType type,
    String toolName,
    String summary,
    String input,
    String output,
    String error,
    Long durationMs
) {

    public static ExecutionEvent agentStarted(
        String executionId
    ) {
        return new ExecutionEvent(
            executionId,
            ExecutionEventType.AGENT_STARTED,
            null,
            null,
            null,
            null,
            null,
            null
        );
    }

    public static ExecutionEvent toolStarted(
        String executionId,
        String toolName,
        String summary,
        String input
    ) {
        return new ExecutionEvent(
            executionId,
            ExecutionEventType.TOOL_STARTED,
            toolName,
            summary,
            input,
            null,
            null,
            null
        );
    }

    public static ExecutionEvent toolCompleted(
        String executionId,
        String toolName,
        String output,
        long durationMs
    ) {
        return new ExecutionEvent(
            executionId,
            ExecutionEventType.TOOL_COMPLETED,
            toolName,
            null,
            null,
            output,
            null,
            durationMs
        );
    }

    public static ExecutionEvent toolFailed(
        String executionId,
        String toolName,
        String error
    ) {
        return new ExecutionEvent(
            executionId,
            ExecutionEventType.TOOL_FAILED,
            toolName,
            null,
            null,
            null,
            error,
            null
        );
    }
}
```

Keep this deliberately small.

---

# 2. Add an execution event mapper on Flutter

Create:

```text
lib/features/chat/
└── execution/
    └── execution_event_mapper.dart
```

```dart
class ExecutionEventMapper {
  const ExecutionEventMapper();

  void apply(
    WidgetRef ref,
    String sessionId,
    Map<String, dynamic> event,
  ) {
    final type = event['type'];

    switch (type) {
      case 'AGENT_STARTED':
        _agentStarted(ref, sessionId);
        break;

      case 'TOOL_STARTED':
        _toolStarted(ref, sessionId, event);
        break;

      case 'TOOL_COMPLETED':
        _toolCompleted(ref, sessionId, event);
        break;

      case 'TOOL_FAILED':
        _toolFailed(ref, sessionId, event);
        break;

      case 'AGENT_COMPLETED':
        _agentCompleted(ref, sessionId);
        break;

      case 'AGENT_FAILED':
        _agentFailed(ref, sessionId, event);
        break;
    }
  }

  void _agentStarted(
    WidgetRef ref,
    String sessionId,
  ) {
    ref
        .read(agentRunningProvider.notifier)
        .start();
  }

  void _agentCompleted(
    WidgetRef ref,
    String sessionId,
  ) {
    ref
        .read(agentRunningProvider.notifier)
        .stop();
  }

  void _agentFailed(
    WidgetRef ref,
    String sessionId,
    Map<String, dynamic> event,
  ) {
    ref
        .read(agentRunningProvider.notifier)
        .stop();

    ref
        .read(chatTranscriptProvider(sessionId).notifier)
        .appendStep(
          event['error'] ?? 'Agent execution failed',
        );
  }
}
```

Notice that we're **reusing your existing `agentRunningProvider`** rather than introducing another running-state provider. 

---

# 3. Convert tool-start events into `ToolCall`

Your existing `ToolCall` model is already designed for this. 

When:

```text
TOOL_STARTED
```

arrives:

```dart
void _toolStarted(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  final tool = ToolCall(
    id: event['tool_id'],
    toolName: event['tool_name'],
    summary: event['summary'] ??
        'Running ${event['tool_name']}',
    status: ToolCallStatus.running,
    startedAt: DateTime.now(),
    detailInput: event['input'],
  );

  ref
      .read(chatTranscriptProvider(sessionId).notifier)
      .appendToolCall(tool);
}
```

Then when the tool finishes:

```dart
void _toolCompleted(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  ref
      .read(chatTranscriptProvider(sessionId).notifier)
      .completeToolCall(
        id: event['tool_id'],
        output: event['output'],
        duration: Duration(
          milliseconds:
              event['duration_ms'] ?? 0,
        ),
      );
}
```

If `completeToolCall()` doesn't exist yet, add it to the transcript notifier.

---

# 4. Add the missing transcript operations

In your existing transcript notifier:

```dart
void appendToolCall(
  ToolCall toolCall,
) {
  final entry = ChatEntry.toolCall(
    id: toolCall.id,
    toolCall: toolCall,
  );

  state = [
    ...state,
    entry,
  ];
}
```

Then:

```dart
void completeToolCall({
  required String id,
  String? output,
  Duration? duration,
}) {
  state = [
    for (final entry in state)
      if (entry.toolCall?.id == id)
        entry.copyWith(
          toolCall: entry.toolCall!.copyWith(
            status: ToolCallStatus.success,
            detailOutput: output,
            duration: duration,
          ),
        )
      else
        entry,
  ];
}
```

And:

```dart
void failToolCall({
  required String id,
  required String error,
}) {
  state = [
    for (final entry in state)
      if (entry.toolCall?.id == id)
        entry.copyWith(
          toolCall: entry.toolCall!.copyWith(
            status: ToolCallStatus.error,
            errorMessage: error,
          ),
        )
      else
        entry,
  ];
}
```

This gives you a very nice live transition:

```text
Before:

◌ Running tests


During:

◌ Running tests
  Running...


After:

✓ Running tests                         12.4s
  6 tests passed
```

No new state architecture required.

---

# 5. Stream the events into the mapper

Your API already exposes:

```dart
Stream<Map<String, dynamic>> runAgent(...)
```

so the GUI service can become:

```dart
Stream<Map<String, dynamic>> runAgent({
  required String sessionId,
  required String prompt,
  required String workspacePath,
}) async* {
  await for (final event in api.runAgent(
    sessionId: sessionId,
    prompt: prompt,
    workspacePath: workspacePath,
  )) {
    yield event;
  }
}
```

Then the screen/controller:

```dart
await for (final event in service.runAgent(
  sessionId: sessionId,
  prompt: prompt,
  workspacePath: workspacePath,
)) {
  const ExecutionEventMapper().apply(
    ref,
    sessionId,
    event,
  );
}
```

---

# 6. Add automatic scrolling

This is a small UX feature with a huge impact.

Create:

```dart
class ChatScrollController {
  final ScrollController controller =
      ScrollController();

  void scrollToBottom() {
    if (!controller.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  void dispose() {
    controller.dispose();
  }
}
```

But don't always force-scroll.

Use this rule:

```text
User is at bottom
        ↓
New event
        ↓
auto-scroll


User scrolled upward
        ↓
New event
        ↓
DO NOT move viewport
        ↓
"↓ New activity"
```

That is much better than the usual annoying auto-scroll behavior.

---

# 7. Add the "new activity" button

```dart
AnimatedSwitcher(
  duration: const Duration(
    milliseconds: 150,
  ),
  child: hasNewActivity
      ? FloatingActionButton.small(
          onPressed: scrollToBottom,
          child: const Icon(
            Icons.keyboard_arrow_down,
          ),
        )
      : const SizedBox.shrink(),
)
```

This is especially useful during long Wayang runs.

---

# 8. Add a proper connection indicator

At the top-right:

```text
● Connected
```

Possible states:

```dart
enum ConnectionState {
  connected,
  connecting,
  reconnecting,
  disconnected,
}
```

Render:

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _statusColor(state),
      ),
    ),
    const SizedBox(width: 6),
    Text(_statusLabel(state)),
  ],
)
```

Don't use large banners for ordinary connectivity.

Only show a banner if the connection actually affects the user's current operation.

---

# 9. Now tackle approval

This is the next important interaction.

When the backend emits:

```text
APPROVAL_REQUIRED
```

create/update the existing `ApprovalRequest`.

The card should become:

```text
┌──────────────────────────────────────────────┐
│ 🔒 Permission required                      │
│                                              │
│ Run command                                  │
│                                              │
│ ./mvnw clean install                         │
│                                              │
│ Risk · CAUTION                               │
│                                              │
│ [Deny]        [Allow once]       [Allow]     │
└──────────────────────────────────────────────┘
```

The runtime already has an approval mechanism, so this is not merely cosmetic. 

---

# 10. Make approval state persistent

Your GUI persistence layer already serializes approval requests. 

Therefore the UX should support reopening a session containing:

```text
Waiting for approval
```

rather than treating it as a transient snackbar.

That means:

```dart
if (approval.status == ApprovalStatus.pending) {
  return ApprovalCard(
    approval: approval,
  );
}
```

---

# 11. Add keyboard shortcuts

For an IDE-like product, this should happen now rather than at the very end.

```dart
Shortcuts(
  shortcuts: {
    const SingleActivator(
      LogicalKeyboardKey.enter,
      control: true,
    ): const SubmitPromptIntent(),
    const SingleActivator(
      LogicalKeyboardKey.keyK,
      control: true,
    ): const OpenCommandPaletteIntent(),
    const SingleActivator(
      LogicalKeyboardKey.escape,
    ): const CancelAgentIntent(),
  },
  child: Actions(
    actions: {
      SubmitPromptIntent:
          CallbackAction<SubmitPromptIntent>(
        onInvoke: (_) {
          submitPrompt();
          return null;
        },
      ),

      CancelAgentIntent:
          CallbackAction<CancelAgentIntent>(
        onInvoke: (_) {
          cancelAgent();
          return null;
        },
      ),
    },
    child: child,
  ),
)
```

Then:

```text
Ctrl/Cmd + Enter   Send
Ctrl/Cmd + K      Command palette
Esc               Stop/cancel
```

---

# 12. Then implement the command palette

```text
┌─────────────────────────────────────────────┐
│ Search commands...                          │
├─────────────────────────────────────────────┤
│ ✦ Review current changes                    │
│ ▶ Run tests                                 │
│ ⚒ Fix current issue                         │
│ ◇ Explain selection                         │
│ ⌕ Search workspace                          │
└─────────────────────────────────────────────┘
```

Model:

```dart
class ChatCommand {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  const ChatCommand({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}
```

Commands:

```dart
const commands = [
  ChatCommand(
    id: 'review',
    label: 'Review current changes',
    description: 'Analyze the current workspace diff',
    icon: Icons.rate_review_outlined,
  ),
  ChatCommand(
    id: 'test',
    label: 'Run tests',
    description: 'Run relevant project tests',
    icon: Icons.play_arrow_outlined,
  ),
  ChatCommand(
    id: 'fix',
    label: 'Fix current issue',
    description: 'Analyze and repair the current problem',
    icon: Icons.build_outlined,
  ),
];
```

---

# 13. The resulting UX

After this round, an agent run should look like:

```text
┌───────────────────────────────────────────────────────────┐
│ Aljabr                                      ● Connected   │
├───────────────────────────────────────────────────────────┤
│                                                           │
│ ◉ Aljabr is working                              [Stop]   │
│                                                           │
│ ┌───────────────────────────────────────────────────────┐ │
│ │ PLAN                                             2/5 │ │
│ │                                                       │ │
│ │ ✓ Understand request                                  │ │
│ │ ✓ Inspect workspace                                   │ │
│ │ ● Analyze Hibernate mapping                           │ │
│ │ ○ Apply changes                                       │ │
│ │ ○ Run tests                                            │ │
│ └───────────────────────────────────────────────────────┘ │
│                                                           │
│ ✓ Search workspace                               1.2s    │
│                                                           │
│ ◌ Read SessionResource.java                              │
│   Running...                                             │
│                                                           │
│ ┌───────────────────────────────────────────────────────┐ │
│ │ Agent                                                 │ │
│ │ I found the mapping mismatch. I'll update the        │ │
│ │ relationship and then run the relevant tests.        │ │
│ └───────────────────────────────────────────────────────┘ │
│                                                           │
│ ┌───────────────────────────────────────────────────────┐ │
│ │ 🔒 Permission required                                │ │
│ │                                                       │ │
│ │ Apply changes to SessionResource.java                 │ │
│ │                                                       │ │
│ │ [Deny]          [Allow once]          [Allow]         │ │
│ └───────────────────────────────────────────────────────┘ │
│                                                           │
├───────────────────────────────────────────────────────────┤
│ Ask Aljabr...                              ⌘K   ↑        │
└───────────────────────────────────────────────────────────┘
```

That is the point where the product starts feeling like an **AI development environment**, rather than a chat window attached to an IDE.

## After this

The next major implementation should be **Changes/Diff UX**:

```text
Agent modifies files
        ↓
Changes drawer updates live
        ↓
2 files changed
        ↓
Review changes
        ↓
Side-by-side / unified diff
        ↓
Accept / revert individual change
```

That should be the next feature after the event pipeline, because it closes the loop between **agent action → user visibility → user control**.
