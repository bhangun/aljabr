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


Next: **implement the Changes/Diff UX**. This is the next highest-value piece because it gives the user control over what the agent actually changed.

The existing GUI already has `FileDiff` references and session change tracking, so we should extend that rather than introduce another parallel model. 

## 1. Create the changes feature

```text
lib/features/changes/
├── models/
│   └── file_change.dart
├── providers/
│   └── changes_provider.dart
└── widgets/
    ├── changes_panel.dart
    ├── file_change_tile.dart
    ├── diff_view.dart
    └── diff_toolbar.dart
```

### `file_change.dart`

```dart
enum FileChangeType {
  added,
  modified,
  deleted,
  renamed,
}

class FileChange {
  final String path;
  final FileChangeType type;
  final int additions;
  final int deletions;
  final String? oldPath;
  final String? diff;

  const FileChange({
    required this.path,
    required this.type,
    this.additions = 0,
    this.deletions = 0,
    this.oldPath,
    this.diff,
  });

  FileChange copyWith({
    String? diff,
    int? additions,
    int? deletions,
  }) {
    return FileChange(
      path: path,
      type: type,
      additions: additions ?? this.additions,
      deletions: deletions ?? this.deletions,
      oldPath: oldPath,
      diff: diff ?? this.diff,
    );
  }
}
```

---

# 2. Changes provider

Use Riverpod:

```dart
final changesProvider = StateNotifierProvider.family<
    ChangesNotifier,
    List<FileChange>,
    String>((ref, sessionId) {
  return ChangesNotifier();
});
```

```dart
class ChangesNotifier
    extends StateNotifier<List<FileChange>> {
  ChangesNotifier() : super(const []);

  void setChanges(List<FileChange> changes) {
    state = changes;
  }

  void addChange(FileChange change) {
    final existing = state.indexWhere(
      (item) => item.path == change.path,
    );

    if (existing == -1) {
      state = [...state, change];
      return;
    }

    final updated = [...state];
    updated[existing] = change;

    state = updated;
  }

  void removeChange(String path) {
    state = state
        .where((change) => change.path != path)
        .toList();
  }

  void clear() {
    state = const [];
  }
}
```

---

# 3. Build the changes panel

The panel should be compact rather than another huge sidebar.

```text
┌───────────────────────────────┐
│ CHANGES                  3    │
├───────────────────────────────┤
│ M  SessionResource.java  +12  │
│                             -4│
│ M  SessionResourceTest.java   │
│                             +8│
│ A  SessionRepository.java     │
│                             +42│
├───────────────────────────────┤
│        Review changes         │
└───────────────────────────────┘
```

### `changes_panel.dart`

```dart
class ChangesPanel extends ConsumerWidget {
  const ChangesPanel({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final changes = ref.watch(
      changesProvider(sessionId),
    );

    if (changes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 280,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          _ChangesHeader(
            count: changes.length,
          ),

          Expanded(
            child: ListView.builder(
              itemCount: changes.length,
              itemBuilder: (_, index) {
                return FileChangeTile(
                  change: changes[index],
                );
              },
            ),
          ),

          _ReviewChangesButton(
            onPressed: () {
              // open full diff
            },
          ),
        ],
      ),
    );
  }
}
```

---

# 4. File change tile

```dart
class FileChangeTile extends StatelessWidget {
  const FileChangeTile({
    super.key,
    required this.change,
  });

  final FileChange change;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        _icon(change.type),
        size: 17,
      ),
      title: Text(
        change.path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (change.additions > 0)
            Text(
              '+${change.additions}',
              style: const TextStyle(
                color: Colors.green,
              ),
            ),

          const SizedBox(width: 8),

          if (change.deletions > 0)
            Text(
              '-${change.deletions}',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
        ],
      ),
      onTap: () {
        // select file
      },
    );
  }

  IconData _icon(FileChangeType type) {
    switch (type) {
      case FileChangeType.added:
        return Icons.add_circle_outline;
      case FileChangeType.modified:
        return Icons.edit_outlined;
      case FileChangeType.deleted:
        return Icons.delete_outline;
      case FileChangeType.renamed:
        return Icons.drive_file_move_outline;
    }
  }
}
```

---

# 5. Add selected-file state

Don't open a separate window for every diff.

Add:

```dart
final selectedChangeProvider =
    StateProvider.family<String?, String>(
  (ref, sessionId) => null,
);
```

Then:

```dart
ref
    .read(selectedChangeProvider(sessionId).notifier)
    .state = change.path;
```

Now the UI becomes:

```text
Changes
  │
  ├── SessionResource.java      ← selected
  ├── SessionResourceTest.java
  └── SessionRepository.java

              ↓

        Diff Viewer
```

---

# 6. Implement a unified diff viewer first

Don't start with a complicated side-by-side editor.

Start with:

```text
SessionResource.java

  18  public class SessionResource {
  19
- 20    private Session session;
+ 20    private SessionService sessionService;
  21
+ 22    public Session getSession() {
+ 23       return sessionService.get();
+ 24    }
```

Create:

```text
lib/features/changes/widgets/diff_view.dart
```

```dart
class DiffView extends StatelessWidget {
  const DiffView({
    super.key,
    required this.diff,
  });

  final String diff;

  @override
  Widget build(BuildContext context) {
    final lines = diff.split('\n');

    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];

        return _DiffLine(
          text: line,
        );
      },
    );
  }
}
```

---

# 7. Diff line classification

```dart
class _DiffLine extends StatelessWidget {
  const _DiffLine({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final isAdded = text.startsWith('+');
    final isRemoved = text.startsWith('-');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 1,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}
```

Later we can add syntax highlighting and proper line numbers.

---

# 8. Add line numbers

Don't make users read raw diff syntax.

Use:

```dart
class DiffLine {
  final int? oldLine;
  final int? newLine;
  final String text;
  final DiffLineType type;

  const DiffLine({
    this.oldLine,
    this.newLine,
    required this.text,
    required this.type,
  });
}

enum DiffLineType {
  context,
  added,
  removed,
  header,
}
```

Then render:

```text
  18 │  18 │ public class SessionResource {
  19 │  19 │
     │  20 │ + private SessionService service;
  20 │     │ - private Session session;
```

This will make the diff much easier to scan.

---

# 9. Add a diff toolbar

```text
┌────────────────────────────────────────────────────┐
│ SessionResource.java             3 additions  1 deletion │
│                                                    │
│ [Unified] [Side by side]        [Copy] [Revert]   │
└────────────────────────────────────────────────────┘
```

Code:

```dart
class DiffToolbar extends StatelessWidget {
  const DiffToolbar({
    super.key,
    required this.file,
    required this.onRevert,
  });

  final FileChange file;
  final VoidCallback onRevert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            file.path,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Text(
          '+${file.additions}',
          style: const TextStyle(
            color: Colors.green,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          '-${file.deletions}',
          style: const TextStyle(
            color: Colors.red,
          ),
        ),

        const SizedBox(width: 12),

        IconButton(
          tooltip: 'Copy diff',
          icon: const Icon(Icons.copy_outlined),
          onPressed: () {},
        ),

        IconButton(
          tooltip: 'Revert file',
          icon: const Icon(
            Icons.undo_outlined,
          ),
          onPressed: onRevert,
        ),
      ],
    );
  }
}
```

---

# 10. Add a full review mode

This is where the UX becomes much stronger.

Click:

```text
Review changes
```

and switch the main workspace to:

```text
┌───────────────┬─────────────────────────────────────┐
│ CHANGED FILES │ SessionResource.java                │
│               ├─────────────────────────────────────┤
│ ● Session...  │  18 │ 18 │ public class...         │
│   Test.java   │     │ 19 │ + service...             │
│   Repository  │  20 │    │ - session...             │
│               │                                     │
│               │                                     │
│               │                                     │
└───────────────┴─────────────────────────────────────┘
```

Don't navigate away from the session.

The user should always be able to return to:

```text
← Back to agent
```

---

# 11. Add "revert" carefully

The button should not immediately revert.

Click:

```text
Revert file
```

Then:

```text
Revert changes to SessionResource.java?

This will discard the changes made by Aljabr.

[Cancel] [Revert]
```

This is especially important because your runtime already treats changes as controlled operations with risk semantics. 

---

# 12. Connect changes to agent events

Now connect this to the event pipeline from the previous step.

Add:

```text
PATCH_PROPOSED
PATCH_APPLIED
PATCH_REVERTED
```

to the event types.

```java
public enum ExecutionEventType {
    AGENT_STARTED,
    THOUGHT,

    TOOL_STARTED,
    TOOL_COMPLETED,
    TOOL_FAILED,

    PATCH_PROPOSED,
    PATCH_APPLIED,
    PATCH_REVERTED,

    APPROVAL_REQUIRED,

    AGENT_COMPLETED,
    AGENT_FAILED
}
```

When:

```text
PATCH_APPLIED
```

arrives:

```dart
void applyPatchEvent(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  final change = FileChange(
    path: event['path'],
    type: _changeType(event['change_type']),
    additions: event['additions'] ?? 0,
    deletions: event['deletions'] ?? 0,
    diff: event['diff'],
  );

  ref
      .read(changesProvider(sessionId).notifier)
      .addChange(change);
}
```

Now the changes panel updates **while the agent is working**.

---

# 13. The resulting flow

This is the UX we want:

```text
User
 │
 │ "Fix the Session mapping"
 ▼
Aljabr
 │
 ├── Plan
 │
 ├── Inspect files
 │
 ├── Analyze
 │
 ├── PATCH_PROPOSED
 │       │
 │       ▼
 │   Approval card
 │
 ├── PATCH_APPLIED
 │       │
 │       ▼
 │   Changes panel updates
 │
 ├── Run tests
 │
 └── Verify
         │
         ▼
      Complete
```

And the user can inspect changes **before the agent finishes**.

---

# 14. One more important improvement: don't mix chat and diff state

Keep:

```text
Chat state
    ↓
ChatEntry[]

Execution state
    ↓
agentRunningProvider

Changes state
    ↓
changesProvider

Editor state
    ↓
editor providers
```

They communicate through events, but don't become one giant provider.

That will keep `IdeHomeScreen` manageable as the product grows.

---

# 15. After this, we should implement the real editor integration

The next feature after Changes is:

```text
Agent changes file
       ↓
Changes panel
       ↓
Click file
       ↓
Open exact file in editor
       ↓
Highlight changed lines
       ↓
Review
```

That is where Aljabr starts feeling like a true IDE agent.

The target architecture becomes:

```text
                   ┌──────────────┐
                   │ Wayang Agent │
                   └──────┬───────┘
                          │
                    Execution Events
                          │
             ┌────────────┴────────────┐
             ▼                         ▼
        Chat/Timeline              Changes
             │                         │
             │                         ▼
             │                    Diff Viewer
             │                         │
             └──────────┬──────────────┘
                        ▼
                   IDE Editor
```

**So the immediate coding sequence is now:**

1. `FileChange` model
2. `changesProvider`
3. `ChangesPanel`
4. `FileChangeTile`
5. `DiffView`
6. `DiffToolbar`
7. `PATCH_APPLIED` event
8. Connect event → changes provider
9. Add review mode
10. Add safe revert

Then we move directly into **editor ↔ diff synchronization**, which is the next substantial UX improvement.



Continue with **editor ↔ diff synchronization**. This is the next major UX layer: when Aljabr changes a file, the user should be able to jump directly from the change to the exact location in the editor.

## 1. Add a selection model

Create:

```text
lib/features/editor/models/editor_location.dart
```

```dart
class EditorLocation {
  final String path;
  final int? line;
  final int? column;

  const EditorLocation({
    required this.path,
    this.line,
    this.column,
  });
}
```

Then:

```text
lib/features/editor/providers/editor_selection_provider.dart
```

```dart
final editorSelectionProvider =
    StateProvider.family<EditorLocation?, String>(
  (ref, sessionId) => null,
);
```

Now changes and the editor communicate through a small, explicit object.

---

## 2. Give each diff hunk a location

Expand the diff model:

```dart
enum DiffLineType {
  context,
  added,
  removed,
}

class DiffLine {
  final int? oldLine;
  final int? newLine;
  final DiffLineType type;
  final String text;

  const DiffLine({
    required this.oldLine,
    required this.newLine,
    required this.type,
    required this.text,
  });
}
```

This lets the UI know:

```text
diff line → source line
```

instead of treating the diff as a block of text.

---

## 3. Make diff lines clickable

```dart
class DiffLineWidget extends ConsumerWidget {
  const DiffLineWidget({
    super.key,
    required this.sessionId,
    required this.path,
    required this.line,
  });

  final String sessionId;
  final String path;
  final DiffLine line;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final sourceLine =
        line.newLine ?? line.oldLine;

    return InkWell(
      onTap: sourceLine == null
          ? null
          : () {
              ref
                  .read(
                    editorSelectionProvider(
                      sessionId,
                    ).notifier,
                  )
                  .state = EditorLocation(
                path: path,
                line: sourceLine,
              );
            },
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '${line.oldLine ?? ''}',
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${line.newLine ?? ''}',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              line.text,
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

Now:

```text
Diff
  ↓
click line 42
  ↓
editorSelectionProvider
  ↓
Editor jumps to line 42
```

---

# 4. Add an editor navigation listener

Inside the editor screen:

```dart
class EditorSelectionListener
    extends ConsumerWidget {
  const EditorSelectionListener({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    ref.listen<EditorLocation?>(
      editorSelectionProvider(sessionId),
      (previous, next) {
        if (next == null) return;

        // Connect this to the actual editor.
        _openLocation(
          context,
          next,
        );
      },
    );

    return const SizedBox.shrink();
  }

  void _openLocation(
    BuildContext context,
    EditorLocation location,
  ) {
    // editor.openFile(location.path)
    // editor.goToLine(location.line)
  }
}
```

The exact implementation depends on your editor widget, so **don't fake an API that isn't in the existing codebase**.

The contract should simply be:

```text
openFile(path)
goToLine(line)
goToColumn(column)
```

---

# 5. Add "Open in editor"

The file header should have:

```text
SessionResource.java

[Open in editor] [Copy] [Revert]
```

Implementation:

```dart
TextButton.icon(
  onPressed: () {
    ref
        .read(
          editorSelectionProvider(sessionId)
              .notifier,
        )
        .state = EditorLocation(
      path: change.path,
      line: change.firstChangedLine,
    );
  },
  icon: const Icon(
    Icons.open_in_new,
    size: 16,
  ),
  label: const Text('Open in editor'),
)
```

---

# 6. Add changed-line navigation

This is particularly useful for large files.

At the top of the editor:

```text
SessionResource.java

← Previous change    3 / 8    Next change →
```

State:

```dart
final changedLineIndexProvider =
    StateProvider.family<int, String>(
  (ref, sessionId) => 0,
);
```

Then derive changed locations from the selected file.

```dart
final changedLocationsProvider =
    Provider.family<List<EditorLocation>, String>(
  (ref, sessionId) {
    final changes =
        ref.watch(changesProvider(sessionId));

    return [
      for (final change in changes)
        if (change.firstChangedLine != null)
          EditorLocation(
            path: change.path,
            line: change.firstChangedLine,
          ),
    ];
  },
);
```

Now:

```dart
void nextChange(
  WidgetRef ref,
  String sessionId,
) {
  final locations =
      ref.read(changedLocationsProvider(sessionId));

  if (locations.isEmpty) return;

  final index =
      ref.read(changedLineIndexProvider(sessionId));

  final next =
      (index + 1) % locations.length;

  ref
      .read(
        changedLineIndexProvider(sessionId)
            .notifier,
      )
      .state = next;

  ref
      .read(
        editorSelectionProvider(sessionId)
            .notifier,
      )
      .state = locations[next];
}
```

This gives the reviewer:

```text
Previous change    3 / 8    Next change
```

---

# 7. Add a review mode

Now let's make the workspace mode explicit.

```dart
enum WorkspaceMode {
  chat,
  review,
}
```

Provider:

```dart
final workspaceModeProvider =
    StateProvider.family<WorkspaceMode, String>(
  (ref, sessionId) => WorkspaceMode.chat,
);
```

When the user clicks **Review changes**:

```dart
ref
    .read(
      workspaceModeProvider(sessionId).notifier,
    )
    .state = WorkspaceMode.review;
```

---

# 8. Change the center workspace

Instead of navigating to another page:

```dart
final mode =
    ref.watch(workspaceModeProvider(sessionId));

return switch (mode) {
  WorkspaceMode.chat => ChatWorkspace(
      sessionId: sessionId,
    ),

  WorkspaceMode.review => ReviewWorkspace(
      sessionId: sessionId,
    ),
};
```

This is important.

The user should not feel like:

> "The agent sent me somewhere else."

It should feel like:

> "I am reviewing what the agent just did."

---

# 9. Build `ReviewWorkspace`

```dart
class ReviewWorkspace extends ConsumerWidget {
  const ReviewWorkspace({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final changes =
        ref.watch(changesProvider(sessionId));

    final selected =
        ref.watch(
          selectedChangeProvider(sessionId),
        );

    final change = changes
        .where((item) => item.path == selected)
        .firstOrNull;

    return Column(
      children: [
        ReviewToolbar(
          sessionId: sessionId,
        ),

        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 280,
                child: ReviewFileList(
                  sessionId: sessionId,
                  changes: changes,
                ),
              ),

              const VerticalDivider(
                width: 1,
              ),

              Expanded(
                child: change == null
                    ? const ReviewEmptyState()
                    : DiffView(
                        change: change,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

# 10. Review toolbar

```text
┌────────────────────────────────────────────────────────────┐
│ ← Back to agent    Review changes     3 files              │
│                                                            │
│                         [Reject all] [Accept all]          │
└────────────────────────────────────────────────────────────┘
```

Code:

```dart
class ReviewToolbar extends ConsumerWidget {
  const ReviewToolbar({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to agent',
            onPressed: () {
              ref
                  .read(
                    workspaceModeProvider(sessionId)
                        .notifier,
                  )
                  .state = WorkspaceMode.chat;
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            'Review changes',
          ),

          const Spacer(),

          TextButton(
            onPressed: () {
              // reject all
            },
            child: const Text(
              'Reject all',
            ),
          ),

          FilledButton(
            onPressed: () {
              // accept all
            },
            child: const Text(
              'Accept all',
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
```

---

# 11. Don't use "Accept all" immediately

There is an important distinction:

```text
Agent modified workspace
        ↓
Review
        ↓
User approves
        ↓
Changes become accepted
```

If the agent already physically modified the workspace, then "Accept" should mean **accepting the agent's proposed state**, not pretending the patch hasn't been applied.

So we need to decide what the backend actually does.

The correct model is:

```text
Working tree
    │
    ├── original snapshot
    │
    └── agent changes
             ↓
          review
             ↓
       accept / revert
```

If the existing backend does not maintain a snapshot, **do not implement destructive revert yet**. First expose the existing diff accurately.

---

# 12. Add a review status

```dart
enum ChangeReviewStatus {
  pending,
  accepted,
  rejected,
}
```

Then:

```dart
class FileChange {
  final String path;
  final FileChangeType type;
  final int additions;
  final int deletions;
  final ChangeReviewStatus reviewStatus;

  // ...
}
```

UI:

```text
M SessionResource.java       Pending
✓ SessionRepository.java     Accepted
× SessionTest.java           Rejected
```

This gives the user an explicit mental model.

---

# 13. Add an agent activity indicator to changes

While the agent is still running:

```text
CHANGES

M SessionResource.java
  Updating...

M SessionRepository.java
  Ready for review
```

The changes panel should therefore distinguish:

```dart
enum FileChangeState {
  modifying,
  ready,
  accepted,
  rejected,
}
```

This is much better than showing everything as a completed modification.

---

# 14. Now improve the agent timeline

The chat should expose the relationship:

```text
Agent
  ↓
modified SessionResource.java
  ↓
2 additions · 1 deletion
  ↓
[Review]
```

For example:

```text
┌───────────────────────────────────────────┐
│ ✓ Updated SessionResource.java            │
│                                           │
│ +12 -4                                    │
│                                           │
│ [Review file]                             │
└───────────────────────────────────────────┘
```

Clicking **Review file**:

```dart
ref
    .read(
      selectedChangeProvider(sessionId)
          .notifier,
    )
    .state = 'SessionResource.java';

ref
    .read(
      workspaceModeProvider(sessionId)
          .notifier,
    )
    .state = WorkspaceMode.review;
```

So the agent timeline and review workspace are directly connected.

---

# 15. The complete UX is now

```text
                   USER
                     │
                     ▼
              Ask Aljabr
                     │
                     ▼
              Agent executes
                     │
       ┌─────────────┼──────────────┐
       ▼             ▼              ▼
     Plan          Tools         Changes
       │             │              │
       │             │              ▼
       │             │         Review available
       │             │              │
       └─────────────┴──────────────┤
                                    ▼
                              Review workspace
                                    │
                         ┌──────────┴─────────┐
                         ▼                    ▼
                     Accept                Reject
                         │                    │
                         └──────────┬─────────┘
                                    ▼
                               Run tests
                                    │
                                    ▼
                                Complete
```

That is the interaction loop I would aim for.

---

## One architectural correction

At this point, **don't add more UI state just because we can**.

We now have four clear domains:

```text
Chat
Execution
Changes
Editor
```

The boundary should remain:

```text
Execution events
       │
       ├──────────→ Chat
       ├──────────→ Changes
       └──────────→ Editor
```

not:

```text
Chat ↔ Changes ↔ Editor ↔ Execution ↔ Chat
```

That second structure will eventually produce tangled Riverpod dependencies.

---

## Next after this

Once this is wired up, the next major improvement should be **the agent composer itself**:

```text
┌─────────────────────────────────────────────────────────┐
│ +  Ask Aljabr what to do...                             │
│                                                         │
│ @file  @folder  /command                               │
│                                                         │
│ Context: 3 files · main branch          ⌘ Enter         │
└─────────────────────────────────────────────────────────┘
```

That means adding:

* `@file` / `@folder` context selection
* slash commands
* attachment/context chips
* prompt history
* multiline input
* keyboard-first interaction
* model/agent mode selector
* token/context visibility
* stop/send state
* command palette integration

That is the next layer that will make the **actual daily interaction with Aljabr** feel polished rather than just making the execution output polished.


Next, let’s implement the **composer UX**. This is the surface the user touches most often, so it should become the fastest part of Aljabr.

We will build it around the existing agent/session architecture rather than introducing a second chat system.

## 1. Target composer

```text
┌──────────────────────────────────────────────────────────────┐
│ +  Ask Aljabr to change the authentication flow...           │
│                                                              │
│ @file  @folder  /test  /review  /fix                        │
│                                                              │
│ 3 files in context · Java · main                 ⌘↵ Send    │
└──────────────────────────────────────────────────────────────┘
```

During execution:

```text
┌──────────────────────────────────────────────────────────────┐
│ Aljabr is working...                                         │
│                                                              │
│ 3 files in context                               Esc Stop    │
└──────────────────────────────────────────────────────────────┘
```

---

# 1. Composer state

Create:

```text
lib/features/chat/composer/
├── composer_state.dart
├── composer_provider.dart
├── chat_composer.dart
├── context_chip.dart
├── command_menu.dart
└── composer_toolbar.dart
```

### `composer_state.dart`

```dart
enum ComposerMode {
  idle,
  submitting,
  disabled,
}

class ComposerState {
  final String text;
  final ComposerMode mode;
  final List<ComposerContext> contexts;

  const ComposerState({
    this.text = '',
    this.mode = ComposerMode.idle,
    this.contexts = const [],
  });

  bool get canSubmit =>
      text.trim().isNotEmpty &&
      mode == ComposerMode.idle;

  ComposerState copyWith({
    String? text,
    ComposerMode? mode,
    List<ComposerContext>? contexts,
  }) {
    return ComposerState(
      text: text ?? this.text,
      mode: mode ?? this.mode,
      contexts: contexts ?? this.contexts,
    );
  }
}

class ComposerContext {
  final String path;
  final String type;

  const ComposerContext({
    required this.path,
    required this.type,
  });
}
```

---

# 2. Composer notifier

```dart
class ComposerNotifier
    extends StateNotifier<ComposerState> {
  ComposerNotifier()
      : super(const ComposerState());

  void setText(String value) {
    state = state.copyWith(
      text: value,
    );
  }

  void setSubmitting() {
    state = state.copyWith(
      mode: ComposerMode.submitting,
    );
  }

  void setIdle() {
    state = state.copyWith(
      mode: ComposerMode.idle,
    );
  }

  void addContext(
    ComposerContext context,
  ) {
    if (state.contexts.any(
      (item) => item.path == context.path,
    )) {
      return;
    }

    state = state.copyWith(
      contexts: [
        ...state.contexts,
        context,
      ],
    );
  }

  void removeContext(String path) {
    state = state.copyWith(
      contexts: state.contexts
          .where((item) => item.path != path)
          .toList(),
    );
  }

  void clear() {
    state = const ComposerState();
  }
}

final composerProvider =
    StateNotifierProvider.family<
        ComposerNotifier,
        ComposerState,
        String>(
  (ref, sessionId) {
    return ComposerNotifier();
  },
);
```

---

# 3. Build the actual composer

```dart
class ChatComposer extends ConsumerStatefulWidget {
  const ChatComposer({
    super.key,
    required this.sessionId,
    required this.onSubmit,
    required this.onStop,
  });

  final String sessionId;
  final Future<void> Function(String prompt) onSubmit;
  final VoidCallback onStop;

  @override
  ConsumerState<ChatComposer> createState() =>
      _ChatComposerState();
}

class _ChatComposerState
    extends ConsumerState<ChatComposer> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
    focusNode = FocusNode();

    controller.addListener(() {
      ref
          .read(
            composerProvider(widget.sessionId)
                .notifier,
          )
          .setText(controller.text);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      composerProvider(widget.sessionId),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          _ContextRow(
            sessionId: widget.sessionId,
          ),

          const SizedBox(height: 8),

          _InputArea(
            controller: controller,
            focusNode: focusNode,
            state: state,
            onSubmit: _submit,
            onStop: widget.onStop,
          ),

          const SizedBox(height: 8),

          ComposerToolbar(
            sessionId: widget.sessionId,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final state = ref.read(
      composerProvider(widget.sessionId),
    );

    if (!state.canSubmit) return;

    ref
        .read(
          composerProvider(widget.sessionId)
              .notifier,
        )
        .setSubmitting();

    try {
      await widget.onSubmit(
        state.text.trim(),
      );

      controller.clear();
    } finally {
      ref
          .read(
            composerProvider(widget.sessionId)
                .notifier,
          )
          .setIdle();
    }
  }
}
```

---

# 4. Multiline input

The composer should behave like an IDE input, not a single-line search box.

```dart
class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.controller,
    required this.focusNode,
    required this.state,
    required this.onSubmit,
    required this.onStop,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ComposerState state;
  final VoidCallback onSubmit;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final running =
        state.mode == ComposerMode.submitting;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !running,
            minLines: 1,
            maxLines: 8,
            textInputAction:
                TextInputAction.newline,
            decoration: const InputDecoration(
              hintText:
                  'Ask Aljabr what to do...',
              border: InputBorder.none,
            ),
            onSubmitted: (_) {
              // Don't submit automatically from
              // ordinary Enter; use Cmd/Ctrl+Enter.
            },
          ),
        ),

        const SizedBox(width: 8),

        running
            ? IconButton.filled(
                tooltip: 'Stop',
                onPressed: onStop,
                icon: const Icon(
                  Icons.stop,
                ),
              )
            : IconButton.filled(
                tooltip: 'Send',
                onPressed: state.canSubmit
                    ? onSubmit
                    : null,
                icon: const Icon(
                  Icons.arrow_upward,
                ),
              ),
      ],
    );
  }
}
```

This is an important UX decision:

**Enter = newline.**

**Cmd/Ctrl + Enter = execute.**

That prevents accidental agent execution while writing a multi-line instruction.

---

# 5. Keyboard submission

Add:

```dart
Shortcuts(
  shortcuts: {
    const SingleActivator(
      LogicalKeyboardKey.enter,
      control: true,
    ): const SubmitPromptIntent(),

    const SingleActivator(
      LogicalKeyboardKey.enter,
      meta: true,
    ): const SubmitPromptIntent(),
  },
  child: Actions(
    actions: {
      SubmitPromptIntent:
          CallbackAction<SubmitPromptIntent>(
        onInvoke: (_) {
          onSubmit();
          return null;
        },
      ),
    },
    child: child,
  ),
)
```

Now both:

```text
Ctrl + Enter
Cmd  + Enter
```

submit.

---

# 6. Context chips

The user should be able to explicitly give Aljabr context.

```dart
class _ContextRow extends ConsumerWidget {
  const _ContextRow({
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      composerProvider(sessionId),
    );

    if (state.contexts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final item in state.contexts)
            ContextChip(
              context: item,
              onRemove: () {
                ref
                    .read(
                      composerProvider(sessionId)
                          .notifier,
                    )
                    .removeContext(
                      item.path,
                    );
              },
            ),
        ],
      ),
    );
  }
}
```

---

# 7. Context chip

```dart
class ContextChip extends StatelessWidget {
  const ContextChip({
    super.key,
    required this.context,
    required this.onRemove,
  });

  final ComposerContext context;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Icon(
        _icon(),
        size: 15,
      ),
      label: Text(
        this.context.path,
        overflow: TextOverflow.ellipsis,
      ),
      onDeleted: onRemove,
    );
  }

  IconData _icon() {
    return context.type == 'folder'
        ? Icons.folder_outlined
        : Icons.insert_drive_file_outlined;
  }
}
```

Now the prompt can visually communicate:

```text
@SessionResource.java
@SessionResourceTest.java
@src/main/java
```

rather than hiding context inside the prompt text.

---

# 8. Add `/commands`

When the user types:

```text
/
```

open:

```text
┌──────────────────────────────────────────┐
│ Commands                                 │
├──────────────────────────────────────────┤
│ /review     Review current changes       │
│ /test       Run tests                    │
│ /fix        Fix current issue            │
│ /explain    Explain selection            │
│ /search     Search workspace             │
└──────────────────────────────────────────┘
```

Model:

```dart
class ComposerCommand {
  final String command;
  final String title;
  final String description;
  final IconData icon;

  const ComposerCommand({
    required this.command,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const composerCommands = [
  ComposerCommand(
    command: '/review',
    title: 'Review changes',
    description: 'Analyze the current diff',
    icon: Icons.rate_review_outlined,
  ),
  ComposerCommand(
    command: '/test',
    title: 'Run tests',
    description: 'Run relevant tests',
    icon: Icons.play_arrow_outlined,
  ),
  ComposerCommand(
    command: '/fix',
    title: 'Fix issue',
    description: 'Analyze and fix the current issue',
    icon: Icons.build_outlined,
  ),
  ComposerCommand(
    command: '/explain',
    title: 'Explain',
    description: 'Explain the current selection',
    icon: Icons.help_outline,
  ),
];
```

---

# 9. Command menu

```dart
class CommandMenu extends StatelessWidget {
  const CommandMenu({
    super.key,
    required this.query,
    required this.onSelected,
  });

  final String query;
  final ValueChanged<ComposerCommand> onSelected;

  @override
  Widget build(BuildContext context) {
    final commands = composerCommands
        .where(
          (command) =>
              command.command
                  .startsWith(query) ||
              command.title
                  .toLowerCase()
                  .contains(
                    query
                        .replaceFirst('/', '')
                        .toLowerCase(),
                  ),
        )
        .toList();

    if (commands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 280,
          minWidth: 320,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: commands.length,
          itemBuilder: (_, index) {
            final command = commands[index];

            return ListTile(
              leading: Icon(command.icon),
              title: Text(command.command),
              subtitle: Text(
                command.description,
              ),
              onTap: () {
                onSelected(command);
              },
            );
          },
        ),
      ),
    );
  }
}
```

---

# 10. Add `@` context selection

The second major interaction is:

```text
@SessionRes...
```

Show:

```text
┌──────────────────────────────────────────┐
│ Context                                  │
├──────────────────────────────────────────┤
│ ◇ SessionResource.java                   │
│ ◇ SessionResourceTest.java               │
│ ◇ SessionRepository.java                 │
│ 📁 src/main/java                         │
│ 📁 src/test                              │
└──────────────────────────────────────────┘
```

The important part is that selecting a result should **create a chip**, not paste a giant path into the prompt.

```dart
void selectFile(
  WidgetRef ref,
  String sessionId,
  String path,
) {
  ref
      .read(
        composerProvider(sessionId)
            .notifier,
      )
      .addContext(
        ComposerContext(
          path: path,
          type: 'file',
        ),
      );
}
```

---

# 11. Add context count

At the bottom:

```text
3 files in context · Java · main
```

Don't show technical internals unless they help.

For example:

```dart
class ComposerContextSummary
    extends StatelessWidget {
  const ComposerContextSummary({
    super.key,
    required this.contexts,
    required this.branch,
  });

  final List<ComposerContext> contexts;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${contexts.length} '
      '${contexts.length == 1 ? 'file' : 'files'} '
      'in context · $branch',
      style: Theme.of(context)
          .textTheme
          .labelSmall,
    );
  }
}
```

---

# 12. Composer toolbar

```text
┌─────────────────────────────────────────────────────────┐
│ +   @ Context   / Commands              main   ⌘↵      │
└─────────────────────────────────────────────────────────┘
```

Implementation:

```dart
class ComposerToolbar extends ConsumerWidget {
  const ComposerToolbar({
    super.key,
    required this.sessionId,
    required this.onSubmit,
  });

  final String sessionId;
  final VoidCallback onSubmit;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      composerProvider(sessionId),
    );

    return Row(
      children: [
        IconButton(
          tooltip: 'Add context',
          onPressed: () {
            // Open context picker.
          },
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
        ),

        TextButton(
          onPressed: () {
            // Open command menu.
          },
          child: const Text('/ Command'),
        ),

        const Spacer(),

        Text(
          '${state.contexts.length} context',
          style: Theme.of(context)
              .textTheme
              .labelSmall,
        ),

        const SizedBox(width: 12),

        const Text(
          '⌘↵',
        ),
      ],
    );
  }
}
```

---

# 13. Prompt history

This is another very useful IDE behavior.

Store the last prompts:

```dart
class PromptHistoryNotifier
    extends StateNotifier<List<String>> {
  PromptHistoryNotifier()
      : super(const []);

  void add(String prompt) {
    if (prompt.trim().isEmpty) return;

    state = [
      prompt,
      ...state.where(
        (item) => item != prompt,
      ),
    ].take(50).toList();
  }
}
```

Then:

```text
↑
```

cycles through previous prompts.

For example:

```text
↑
"Run the SessionResource tests"

↑
"Explain why Hibernate is failing"

↑
"Fix the mapping"
```

This will make repeated development workflows significantly faster.

---

# 14. Add agent mode

The composer should eventually expose the execution intent:

```text
[Agent ▾]
```

Menu:

```text
Agent
────────────────
Agent
Plan only
Explain
Review
```

Model:

```dart
enum AgentMode {
  agent,
  plan,
  explain,
  review,
}
```

This is better than forcing everything through natural-language instructions.

For example:

```text
Plan only
```

should produce a plan without modifying the workspace.

---

# 15. Add a subtle context indicator

Don't overwhelm the composer.

Something like:

```text
Agent · 3 files · main
```

is enough.

Clicking it opens:

```text
Context

Files
  ✓ SessionResource.java
  ✓ SessionService.java
  ✓ SessionResourceTest.java

Workspace
  main
  Java
  128k tokens available
```

This makes context transparent without cluttering the main interface.

---

# 16. The resulting composer

The finished component should look approximately like:

```text
┌──────────────────────────────────────────────────────────────┐
│ @SessionResource.java @SessionResourceTest.java              │
│                                                              │
│ Fix the Hibernate mapping and make sure the tests cover      │
│ the new relationship.                                       │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│ +   / Command       2 files in context · main        ⌘↵ ↑   │
└──────────────────────────────────────────────────────────────┘
```

And when typing `/`:

```text
┌──────────────────────────────────────────────────────────────┐
│ /rev                                                         │
├──────────────────────────────────────────────────────────────┤
│ ◇ /review   Review current changes                           │
│ ◇ /review-test   Review tests                                │
└──────────────────────────────────────────────────────────────┘
```

---

# 17. The important UX principle

The composer should have **three layers of intent**:

```text
Natural language
       │
       ▼
"Fix the authentication bug"
       │
       ├── Context
       │     @AuthService.java
       │     @AuthController.java
       │
       └── Command
             /fix
```

The user can remain completely natural:

```text
Fix this authentication problem.
```

or become precise:

```text
/fix @AuthService.java @AuthController.java
```

Both should result in the same execution pipeline.

---

# 18. Next after composer

Once this is implemented, I would move to **workspace intelligence**:

```text
File tree
   ↓
right-click file
   ↓
Ask Aljabr
   ↓
Review / Explain / Fix / Test
```

For example:

```text
src/
 ├── main/
 │   └── java/
 │       └── SessionResource.java  ⋮
 └── test/
```

Click `⋮`:

```text
Ask Aljabr
──────────────
Explain this file
Fix this file
Write tests
Review changes
Find usages
Add to context
```

That connects the **editor, file tree, composer, agent and execution system** into one coherent interaction model.

The overall UX is then:

```text
                 ┌─────────────┐
                 │ File Tree   │
                 └──────┬──────┘
                        │
                  Add context
                        │
                        ▼
┌────────────┐     ┌───────────┐     ┌────────────┐
│   Editor   │◄───►│ Composer  │◄───►│   Agent    │
└─────┬──────┘     └───────────┘     └──────┬─────┘
      │                                      │
      │                                      ▼
      │                                Execution
      │                                      │
      └──────────────► Changes ◄─────────────┘
                           │
                           ▼
                         Diff
```

**That is the next implementation target: context-aware file-tree actions and connecting them directly into the composer.**


Next: **context-aware actions from the file tree and editor**. This closes the loop we just built.

The goal is that the user should not have to manually copy a file into the composer. From anywhere in the IDE:

> select something → choose an Aljabr action → composer is prepared → execute.

## 1. Define a shared Aljabr action model

Create:

```text
lib/features/agent_actions/
├── agent_action.dart
├── agent_action_type.dart
└── agent_action_runner.dart
```

### `agent_action_type.dart`

```dart
enum AgentActionType {
  explain,
  fix,
  review,
  test,
  findUsages,
  addToContext,
}
```

### `agent_action.dart`

```dart
class AgentAction {
  final AgentActionType type;
  final String label;
  final String? prompt;
  final String? path;

  const AgentAction({
    required this.type,
    required this.label,
    this.prompt,
    this.path,
  });
}
```

---

# 2. Centralize action execution

Don't let the file tree, editor, diff viewer, and chat each implement their own version.

```dart
class AgentActionRunner {
  const AgentActionRunner();

  void run({
    required WidgetRef ref,
    required String sessionId,
    required AgentAction action,
  }) {
    switch (action.type) {
      case AgentActionType.explain:
        _preparePrompt(
          ref,
          sessionId,
          action,
          'Explain this code and its purpose.',
        );
        break;

      case AgentActionType.fix:
        _preparePrompt(
          ref,
          sessionId,
          action,
          'Analyze this code and fix the problem.',
        );
        break;

      case AgentActionType.review:
        _preparePrompt(
          ref,
          sessionId,
          action,
          'Review this code for correctness, bugs, and maintainability.',
        );
        break;

      case AgentActionType.test:
        _preparePrompt(
          ref,
          sessionId,
          action,
          'Create or improve tests for this code.',
        );
        break;

      case AgentActionType.findUsages:
        _preparePrompt(
          ref,
          sessionId,
          action,
          'Find and explain the important usages of this code.',
        );
        break;

      case AgentActionType.addToContext:
        _addContext(
          ref,
          sessionId,
          action,
        );
        break;
    }
  }

  void _preparePrompt(
    WidgetRef ref,
    String sessionId,
    AgentAction action,
    String prompt,
  ) {
    final composer = ref.read(
      composerProvider(sessionId).notifier,
    );

    if (action.path != null) {
      composer.addContext(
        ComposerContext(
          path: action.path!,
          type: 'file',
        ),
      );
    }

    composer.setText(prompt);
  }

  void _addContext(
    WidgetRef ref,
    String sessionId,
    AgentAction action,
  ) {
    if (action.path == null) return;

    ref
        .read(
          composerProvider(sessionId).notifier,
        )
        .addContext(
          ComposerContext(
            path: action.path!,
            type: 'file',
          ),
        );
  }
}
```

Now every part of the application gets the same behavior.

---

# 3. File-tree context menu

Suppose the file tree currently renders:

```dart
ListTile(
  title: Text(file.name),
)
```

Add:

```dart
PopupMenuButton<AgentActionType>(
  onSelected: (type) {
    const AgentActionRunner().run(
      ref: ref,
      sessionId: sessionId,
      action: AgentAction(
        type: type,
        label: _label(type),
        path: file.path,
      ),
    );
  },
  itemBuilder: (_) => [
    const PopupMenuItem(
      value: AgentActionType.explain,
      child: Text('Explain this file'),
    ),
    const PopupMenuItem(
      value: AgentActionType.fix,
      child: Text('Fix this file'),
    ),
    const PopupMenuItem(
      value: AgentActionType.test,
      child: Text('Write tests'),
    ),
    const PopupMenuItem(
      value: AgentActionType.review,
      child: Text('Review'),
    ),
    const PopupMenuItem(
      value: AgentActionType.findUsages,
      child: Text('Find usages'),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      value: AgentActionType.addToContext,
      child: Text('Add to Aljabr context'),
    ),
  ],
)
```

Now the user gets:

```text
SessionResource.java  ⋮
                      │
                      ├─ Explain this file
                      ├─ Fix this file
                      ├─ Write tests
                      ├─ Review
                      ├─ Find usages
                      └─ Add to Aljabr context
```

---

# 4. Don't immediately execute

This is an important UX refinement.

For:

* Explain
* Fix
* Review
* Test
* Find usages

the first click should **prepare the composer**, not blindly execute.

So:

```text
Right-click file
       ↓
Fix this file
       ↓
Composer becomes:

@SessionResource.java

Analyze this file and fix the problem.
                                      [Send]
```

The user can edit the instruction before sending.

This preserves agency.

---

# 5. Add a "ready to send" state

Give the composer a subtle highlight when an action has prepared it.

```dart
class ComposerState {
  final String text;
  final ComposerMode mode;
  final List<ComposerContext> contexts;
  final bool preparedAction;

  const ComposerState({
    this.text = '',
    this.mode = ComposerMode.idle,
    this.contexts = const [],
    this.preparedAction = false,
  });

  ComposerState copyWith({
    String? text,
    ComposerMode? mode,
    List<ComposerContext>? contexts,
    bool? preparedAction,
  }) {
    return ComposerState(
      text: text ?? this.text,
      mode: mode ?? this.mode,
      contexts: contexts ?? this.contexts,
      preparedAction:
          preparedAction ?? this.preparedAction,
    );
  }
}
```

Then:

```dart
void prepareAction(String prompt) {
  state = state.copyWith(
    text: prompt,
    preparedAction: true,
  );
}
```

Composer:

```text
┌──────────────────────────────────────────────────────┐
│ ✦ Suggested action                                   │
│                                                      │
│ @SessionResource.java                                │
│                                                      │
│ Analyze this file and fix the problem.               │
│                                                      │
│                                      [Send]          │
└──────────────────────────────────────────────────────┘
```

---

# 6. Add editor selection actions

This is even more powerful.

If the user selects:

```java
sessionRepository.findById(id)
```

then right-click:

```text
Ask Aljabr
───────────────
Explain selection
Fix selection
Review selection
Write tests
Add selection to context
```

The context should include:

```dart
class ComposerSelection {
  final String path;
  final int startLine;
  final int endLine;
  final int startColumn;
  final int endColumn;

  const ComposerSelection({
    required this.path,
    required this.startLine,
    required this.endLine,
    required this.startColumn,
    required this.endColumn,
  });
}
```

Then the composer can show:

```text
@SessionResource.java:42-48
```

rather than the entire file.

---

# 7. Make context chips richer

Instead of:

```text
@SessionResource.java
```

use:

```text
┌──────────────────────────────┐
│ ◇ SessionResource.java  ×    │
│   lines 42–48                │
└──────────────────────────────┘
```

Model:

```dart
class ComposerContext {
  final String path;
  final String type;
  final int? startLine;
  final int? endLine;

  const ComposerContext({
    required this.path,
    required this.type,
    this.startLine,
    this.endLine,
  });
}
```

Display:

```dart
String get label {
  if (startLine != null && endLine != null) {
    return '$path:$startLine-$endLine';
  }

  return path;
}
```

This dramatically improves precision for code questions.

---

# 8. Add folder actions

Folder context should work differently.

```text
src/services/ ⋮

Ask Aljabr
──────────────
Explain architecture
Review folder
Find dependencies
Write tests
Add folder to context
```

For example:

```dart
const AgentAction(
  type: AgentActionType.review,
  label: 'Review folder',
  path: 'src/services',
);
```

The backend should receive the context as a folder rather than pretending it is a file.

---

# 9. Add selection-aware `/commands`

Now the command palette becomes context-aware.

If nothing is selected:

```text
/review
/test
/search
```

If a file is selected:

```text
/review this file
/test this file
/explain this file
/fix this file
```

If code is selected:

```text
/explain selection
/fix selection
/write tests for selection
```

This avoids showing irrelevant commands.

---

# 10. Add "Ask Aljabr" to the editor toolbar

At the editor top:

```text
SessionResource.java

[◇ Ask Aljabr ▾]       [Split] [⋮]
```

Menu:

```text
Explain
Review
Fix
Write tests
Find usages
Add to context
```

This should use the exact same `AgentActionRunner`.

---

# 11. Add "Ask Aljabr" to the diff

The diff viewer should also expose:

```text
Changed lines

[Explain change]
[Review change]
[Fix]
```

For example:

```dart
AgentAction(
  type: AgentActionType.explain,
  label: 'Explain change',
  path: change.path,
);
```

But ideally include the diff hunk as context:

```dart
class DiffContext {
  final String path;
  final String diff;
  final int? startLine;
  final int? endLine;

  const DiffContext({
    required this.path,
    required this.diff,
    this.startLine,
    this.endLine,
  });
}
```

Then the agent can answer:

> Why did you change this?

without having to rediscover the change.

---

# 12. Add "Explain this change"

This is one of the highest-value interactions.

User sees:

```diff
- private Session session;
+ private SessionService sessionService;
```

Clicks:

```text
Explain change
```

Composer becomes:

```text
@SessionResource.java
Change: lines 20–21

Why was this change made, and what problem does
it solve?
```

That makes the agent's own work inspectable.

---

# 13. Add action loading states

Don't allow multiple accidental submissions.

When executing:

```text
Fix this file
      ↓
[Working...]
```

The context menu action should become disabled while that operation is being prepared/executed.

But don't globally disable the entire application.

Good:

```text
File A
  Fix ✓

File B
  Explain ✓
```

Bad:

```text
Entire IDE frozen
```

---

# 14. Add action provenance to the timeline

When an action originated from the file tree, show it:

```text
You
  Fix SessionResource.java

Aljabr
  I'll inspect the resource and related mappings.

Tools
  Read SessionResource.java
  Read Session.java

Changes
  SessionResource.java +8 -3
```

This makes the execution understandable.

---

# 15. Add a lightweight "context inspector"

Click:

```text
3 files in context
```

and show:

```text
┌─────────────────────────────────────────┐
│ Context                                 │
├─────────────────────────────────────────┤
│ Files                                   │
│                                         │
│ ◇ SessionResource.java       lines 42–48│
│ ◇ SessionService.java                   │
│ ◇ SessionTest.java                      │
│                                         │
│ + Add files                              │
│                                         │
│ The agent will use these files as       │
│ explicit context for this request.      │
└─────────────────────────────────────────┘
```

This prevents the classic AI UX problem:

> "What exactly did the model see?"

---

# 16. Connect context to the backend request

Your existing request should evolve toward:

```dart
class AgentRequest {
  final String prompt;
  final List<AgentContextItem> context;
  final AgentMode mode;

  const AgentRequest({
    required this.prompt,
    required this.context,
    required this.mode,
  });
}
```

And:

```dart
class AgentContextItem {
  final String path;
  final String type;
  final int? startLine;
  final int? endLine;

  const AgentContextItem({
    required this.path,
    required this.type,
    this.startLine,
    this.endLine,
  });
}
```

Then the frontend isn't relying on magic prompt syntax such as:

```text
"@SessionResource.java please..."
```

The actual request is structured:

```json
{
  "prompt": "Fix the Hibernate mapping",
  "mode": "agent",
  "context": [
    {
      "path": "src/.../SessionResource.java",
      "type": "file",
      "startLine": 42,
      "endLine": 48
    }
  ]
}
```

That is a much better long-term architecture.

---

# 17. Add context serialization

Make it explicit:

```dart
extension AgentContextItemJson
    on AgentContextItem {
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type,
      if (startLine != null)
        'start_line': startLine,
      if (endLine != null)
        'end_line': endLine,
    };
  }
}
```

Request:

```dart
Map<String, dynamic> toJson() {
  return {
    'prompt': prompt,
    'mode': mode.name,
    'context': context
        .map((item) => item.toJson())
        .toList(),
  };
}
```

This also makes persisted sessions much easier to reconstruct.

---

# 18. One important UX improvement: preserve the user's prompt

When an agent run finishes, **don't automatically clear everything** if the request failed.

Bad:

```text
Agent failed
Prompt disappears
```

Good:

```text
Agent failed

Your request is still here:

"Fix the Hibernate mapping..."

[Retry]
```

Implementation:

```dart
try {
  await widget.onSubmit(state.text);
} catch (_) {
  ref
      .read(
        composerProvider(sessionId)
            .notifier,
      )
      .setIdle();

  rethrow;
}
```

Only clear after confirmed submission.

For a successful run, you can clear the text but retain useful context depending on the workflow.

---

# 19. Add retry

The timeline should show:

```text
⚠ Agent failed

Could not run Maven tests.

[Retry] [Edit prompt]
```

`Retry` should reuse the original structured request:

```dart
class AgentRunSnapshot {
  final String prompt;
  final AgentMode mode;
  final List<AgentContextItem> context;

  const AgentRunSnapshot({
    required this.prompt,
    required this.mode,
    required this.context,
  });
}
```

This is much safer than reconstructing a prompt from UI text.

---

# 20. Final interaction model

At this point the product should behave like this:

```text
                    FILE TREE
                       │
                  right click
                       │
                       ▼
                 Agent Action
                       │
                       ▼
EDITOR ◄──────► COMPOSER ◄──────► AGENT
  │                 │                │
  │                 │                │
selection        context          execution
  │                 │                │
  └─────────────────┴────────────────┘
                    │
                    ▼
                  DIFF
                    │
                    ▼
                 REVIEW
```

The critical design decision is:

**all these surfaces should feed the same structured `AgentRequest`.**

Don't create:

```text
FileTreeRequest
EditorRequest
DiffRequest
ChatRequest
```

Create one:

```dart
AgentRequest
```

with different UI entry points.

---

## What I would implement immediately after this

The next step is **execution control and observability**.

Specifically:

```text
Agent run
   │
   ├── Pause
   ├── Stop
   ├── Retry
   ├── Continue
   ├── Approval
   └── Inspect execution
```

Then build the execution drawer:

```text
┌────────────────────────────────────────────┐
│ Execution                                  │
├────────────────────────────────────────────┤
│ ✓ Planning                          1.2s   │
│ ✓ Read SessionResource.java         0.4s   │
│ ✓ Read Session.java                 0.2s   │
│ ● Applying changes...                      │
│ ○ Run tests                                │
│ ○ Verify                                   │
├────────────────────────────────────────────┤
│ Tokens      18.4k                          │
│ Duration   12.8s                           │
│ Tools      4                               │
└────────────────────────────────────────────┘
```

That will give us the final major piece of the UX: **the user can always understand what Aljabr is doing, stop it safely, and recover from failure.**



Absolutely. Let’s implement the **execution control + observability layer** next.

The goal is to make every agent run feel controllable:

```text
Running
  ↓
What is Aljabr doing?
  ↓
Why is it doing it?
  ↓
What changed?
  ↓
Can I stop it?
  ↓
Can I retry/continue?
```

## 1. Execution state

Create:

```text
lib/features/execution/
├── models/
│   ├── execution_state.dart
│   ├── execution_step.dart
│   └── execution_metrics.dart
├── providers/
│   └── execution_provider.dart
└── widgets/
    ├── execution_bar.dart
    ├── execution_drawer.dart
    ├── execution_step_tile.dart
    └── execution_metrics.dart
```

### `execution_state.dart`

```dart
enum ExecutionStatus {
  idle,
  running,
  waitingForApproval,
  stopping,
  stopped,
  completed,
  failed,
  paused,
}

class ExecutionState {
  final String? executionId;
  final ExecutionStatus status;
  final List<ExecutionStep> steps;
  final ExecutionMetrics metrics;
  final String? currentAction;
  final String? error;

  const ExecutionState({
    this.executionId,
    this.status = ExecutionStatus.idle,
    this.steps = const [],
    this.metrics = const ExecutionMetrics(),
    this.currentAction,
    this.error,
  });

  bool get isRunning =>
      status == ExecutionStatus.running ||
      status == ExecutionStatus.waitingForApproval ||
      status == ExecutionStatus.stopping;

  bool get canStop =>
      status == ExecutionStatus.running ||
      status == ExecutionStatus.waitingForApproval;

  bool get canRetry =>
      status == ExecutionStatus.failed ||
      status == ExecutionStatus.stopped;

  ExecutionState copyWith({
    String? executionId,
    ExecutionStatus? status,
    List<ExecutionStep>? steps,
    ExecutionMetrics? metrics,
    String? currentAction,
    String? error,
  }) {
    return ExecutionState(
      executionId: executionId ?? this.executionId,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      metrics: metrics ?? this.metrics,
      currentAction: currentAction ?? this.currentAction,
      error: error ?? this.error,
    );
  }
}
```

---

# 2. Execution step

```dart
enum ExecutionStepStatus {
  pending,
  running,
  completed,
  failed,
  skipped,
}

class ExecutionStep {
  final String id;
  final String title;
  final String? description;
  final ExecutionStepStatus status;
  final Duration? duration;
  final String? toolName;

  const ExecutionStep({
    required this.id,
    required this.title,
    this.description,
    this.status = ExecutionStepStatus.pending,
    this.duration,
    this.toolName,
  });

  ExecutionStep copyWith({
    ExecutionStepStatus? status,
    Duration? duration,
    String? description,
  }) {
    return ExecutionStep(
      id: id,
      title: title,
      description: description ?? this.description,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      toolName: toolName,
    );
  }
}
```

---

# 3. Execution metrics

```dart
class ExecutionMetrics {
  final Duration duration;
  final int tokens;
  final int toolCalls;
  final int filesChanged;

  const ExecutionMetrics({
    this.duration = Duration.zero,
    this.tokens = 0,
    this.toolCalls = 0,
    this.filesChanged = 0,
  });

  ExecutionMetrics copyWith({
    Duration? duration,
    int? tokens,
    int? toolCalls,
    int? filesChanged,
  }) {
    return ExecutionMetrics(
      duration: duration ?? this.duration,
      tokens: tokens ?? this.tokens,
      toolCalls: toolCalls ?? this.toolCalls,
      filesChanged: filesChanged ?? this.filesChanged,
    );
  }
}
```

---

# 4. Execution notifier

```dart
class ExecutionNotifier
    extends StateNotifier<ExecutionState> {
  ExecutionNotifier()
      : super(const ExecutionState());

  void start(String executionId) {
    state = ExecutionState(
      executionId: executionId,
      status: ExecutionStatus.running,
    );
  }

  void addStep(ExecutionStep step) {
    state = state.copyWith(
      steps: [
        ...state.steps,
        step,
      ],
    );
  }

  void updateStep(
    String id,
    ExecutionStepStatus status, {
    Duration? duration,
  }) {
    state = state.copyWith(
      steps: [
        for (final step in state.steps)
          if (step.id == id)
            step.copyWith(
              status: status,
              duration: duration,
            )
          else
            step,
      ],
    );
  }

  void setCurrentAction(String action) {
    state = state.copyWith(
      currentAction: action,
    );
  }

  void waitingForApproval() {
    state = state.copyWith(
      status: ExecutionStatus.waitingForApproval,
    );
  }

  void stopRequested() {
    state = state.copyWith(
      status: ExecutionStatus.stopping,
    );
  }

  void stopped() {
    state = state.copyWith(
      status: ExecutionStatus.stopped,
    );
  }

  void complete() {
    state = state.copyWith(
      status: ExecutionStatus.completed,
    );
  }

  void fail(String error) {
    state = state.copyWith(
      status: ExecutionStatus.failed,
      error: error,
    );
  }

  void updateMetrics(
    ExecutionMetrics metrics,
  ) {
    state = state.copyWith(
      metrics: metrics,
    );
  }

  void reset() {
    state = const ExecutionState();
  }
}
```

Provider:

```dart
final executionProvider =
    StateNotifierProvider.family<
        ExecutionNotifier,
        ExecutionState,
        String>(
  (ref, sessionId) {
    return ExecutionNotifier();
  },
);
```

---

# 5. Connect the event pipeline

This is where the previous work pays off.

Your event mapper becomes the central bridge:

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
        _started(ref, sessionId, event);
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

      case 'APPROVAL_REQUIRED':
        _approval(ref, sessionId, event);
        break;

      case 'PATCH_APPLIED':
        _patchApplied(ref, sessionId, event);
        break;

      case 'AGENT_COMPLETED':
        _completed(ref, sessionId);
        break;

      case 'AGENT_FAILED':
        _failed(ref, sessionId, event);
        break;
    }
  }
}
```

---

# 6. Agent started

```dart
void _started(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  ref
      .read(executionProvider(sessionId).notifier)
      .start(
        event['execution_id'],
      );

  ref
      .read(agentRunningProvider.notifier)
      .start();
}
```

Now the old running indicator and new execution state remain synchronized.

---

# 7. Tool started

```dart
void _toolStarted(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  final notifier =
      ref.read(
        executionProvider(sessionId).notifier,
      );

  notifier.addStep(
    ExecutionStep(
      id: event['tool_id'],
      title: event['summary'] ??
          'Running ${event['tool_name']}',
      description: event['input'],
      status: ExecutionStepStatus.running,
      toolName: event['tool_name'],
    ),
  );

  notifier.setCurrentAction(
    event['summary'] ??
        'Running ${event['tool_name']}',
  );
}
```

---

# 8. Tool completed

```dart
void _toolCompleted(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  final notifier =
      ref.read(
        executionProvider(sessionId).notifier,
      );

  notifier.updateStep(
    event['tool_id'],
    ExecutionStepStatus.completed,
    duration: Duration(
      milliseconds:
          event['duration_ms'] ?? 0,
    ),
  );

  notifier.updateMetrics(
    ref
        .read(
          executionProvider(sessionId),
        )
        .metrics
        .copyWith(
          toolCalls:
              ref
                  .read(
                    executionProvider(sessionId),
                  )
                  .metrics
                  .toolCalls +
              1,
        ),
  );
}
```

---

# 9. Execution bar

Now put a persistent lightweight bar above the composer.

```text
┌──────────────────────────────────────────────────────────────┐
│ ● Working · Applying SessionResource.java       [Stop] [⌄]  │
└──────────────────────────────────────────────────────────────┘
```

### `execution_bar.dart`

```dart
class ExecutionBar extends ConsumerWidget {
  const ExecutionBar({
    super.key,
    required this.sessionId,
    required this.onStop,
    required this.onOpenDetails,
  });

  final String sessionId;
  final VoidCallback onStop;
  final VoidCallback onOpenDetails;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final execution = ref.watch(
      executionProvider(sessionId),
    );

    if (!execution.isRunning) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .dividerColor,
          ),
          bottom: BorderSide(
            color: Theme.of(context)
                .dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              execution.currentAction ??
                  'Aljabr is working...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          TextButton(
            onPressed: onOpenDetails,
            child: const Text('Details'),
          ),

          const SizedBox(width: 4),

          OutlinedButton(
            onPressed:
                execution.canStop
                    ? onStop
                    : null,
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}
```

---

# 10. Execution drawer

When the user clicks **Details**:

```text
┌────────────────────────────────────────────────────┐
│ Execution                                     ×    │
├────────────────────────────────────────────────────┤
│                                                    │
│ ✓ Planning                                  1.2s   │
│                                                    │
│ ✓ Read SessionResource.java                  0.4s   │
│                                                    │
│ ✓ Read Session.java                          0.2s   │
│                                                    │
│ ● Applying changes...                              │
│                                                    │
│ ○ Run tests                                        │
│                                                    │
│ ○ Verify                                           │
│                                                    │
├────────────────────────────────────────────────────┤
│ Duration          12.8s                            │
│ Tool calls        4                                │
│ Tokens            18.4k                            │
│ Files changed     2                                │
└────────────────────────────────────────────────────┘
```

Build:

```dart
class ExecutionDrawer extends ConsumerWidget {
  const ExecutionDrawer({
    super.key,
    required this.sessionId,
    required this.onClose,
  });

  final String sessionId;
  final VoidCallback onClose;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final execution = ref.watch(
      executionProvider(sessionId),
    );

    return Material(
      child: SizedBox(
        width: 360,
        child: Column(
          children: [
            _Header(
              title: 'Execution',
              onClose: onClose,
            ),

            Expanded(
              child: ListView.builder(
                itemCount:
                    execution.steps.length,
                itemBuilder: (_, index) {
                  return ExecutionStepTile(
                    step:
                        execution.steps[index],
                  );
                },
              ),
            ),

            ExecutionMetricsView(
              metrics: execution.metrics,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

# 11. Step tile

```dart
class ExecutionStepTile
    extends StatelessWidget {
  const ExecutionStepTile({
    super.key,
    required this.step,
  });

  final ExecutionStep step;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _StatusIcon(
        status: step.status,
      ),
      title: Text(step.title),
      subtitle: step.description == null
          ? null
          : Text(
              step.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: step.duration == null
          ? null
          : Text(
              _formatDuration(
                step.duration!,
              ),
            ),
    );
  }

  String _formatDuration(
    Duration duration,
  ) {
    if (duration.inSeconds > 0) {
      return '${duration.inSeconds}.${duration.inMilliseconds % 1000 ~/ 100}s';
    }

    return '${duration.inMilliseconds}ms';
  }
}
```

---

# 12. Status icon

```dart
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.status,
  });

  final ExecutionStepStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ExecutionStepStatus.pending:
        return const Icon(
          Icons.circle_outlined,
          size: 16,
        );

      case ExecutionStepStatus.running:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );

      case ExecutionStepStatus.completed:
        return const Icon(
          Icons.check_circle_outline,
          size: 17,
        );

      case ExecutionStepStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 17,
        );

      case ExecutionStepStatus.skipped:
        return const Icon(
          Icons.remove_circle_outline,
          size: 17,
        );
    }
  }
}
```

---

# 13. Stop execution properly

The UI should not simply set:

```dart
agentRunning = false;
```

That only lies to the user.

Instead:

```text
UI
 │
 │ Stop
 ▼
Backend cancellation
 │
 ▼
AGENT_STOPPING
 │
 ▼
AGENT_STOPPED
```

Add a cancellation API:

```dart
Future<void> stopAgent({
  required String executionId,
}) async {
  await api.stopAgent(
    executionId: executionId,
  );
}
```

Then:

```dart
Future<void> stopExecution(
  WidgetRef ref,
  String sessionId,
) async {
  final execution = ref.read(
    executionProvider(sessionId),
  );

  final executionId =
      execution.executionId;

  if (executionId == null) return;

  ref
      .read(
        executionProvider(sessionId)
            .notifier,
      )
      .stopRequested();

  try {
    await api.stopAgent(
      executionId: executionId,
    );
  } catch (error) {
    // Keep execution state visible.
  }
}
```

---

# 14. Give stopping its own UI

Don't immediately change:

```text
Working → stopped
```

Show:

```text
Stopping...
```

```text
┌────────────────────────────────────────────┐
│ ◌ Stopping Aljabr...                       │
└────────────────────────────────────────────┘
```

This is important because cancellation can take time.

---

# 15. Approval state

When:

```text
APPROVAL_REQUIRED
```

arrives:

```dart
void _approval(
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> event,
) {
  ref
      .read(
        executionProvider(sessionId)
            .notifier,
      )
      .waitingForApproval();

  ref
      .read(
        approvalProvider(sessionId)
            .notifier,
      )
      .setPending(
        event,
      );
}
```

The execution bar becomes:

```text
🔒 Waiting for your approval                         [Review]
```

instead of:

```text
● Working...
```

That's a much more accurate mental model.

---

# 16. Failed execution

When execution fails:

```text
┌─────────────────────────────────────────────────────┐
│ ⚠ Agent couldn't complete this task                 │
│                                                     │
│ Maven test execution failed.                        │
│                                                     │
│ [Retry] [Edit request] [View execution]             │
└─────────────────────────────────────────────────────┘
```

Model:

```dart
class ExecutionFailure {
  final String message;
  final String? technicalDetail;
  final bool retryable;

  const ExecutionFailure({
    required this.message,
    this.technicalDetail,
    this.retryable = true,
  });
}
```

Do not expose a huge stack trace in the main UI.

Put it behind:

```text
View technical details
```

---

# 17. Retry correctly

Store the original request:

```dart
class AgentRunSnapshot {
  final String prompt;
  final AgentMode mode;
  final List<AgentContextItem> context;

  const AgentRunSnapshot({
    required this.prompt,
    required this.mode,
    required this.context,
  });
}
```

Then:

```dart
Future<void> retry(
  AgentRunSnapshot snapshot,
) async {
  await runAgent(
    prompt: snapshot.prompt,
    mode: snapshot.mode,
    context: snapshot.context,
  );
}
```

This is much safer than:

```dart
retry(lastMessage.text)
```

because context matters.

---

# 18. Continue after approval

We also want:

```text
Agent paused
     ↓
User approves
     ↓
Continue execution
```

The approval response should therefore be explicit:

```dart
enum ApprovalDecision {
  allowOnce,
  allow,
  deny,
}
```

And:

```dart
Future<void> respondToApproval({
  required String approvalId,
  required ApprovalDecision decision,
}) {
  return api.respondToApproval(
    approvalId: approvalId,
    decision: decision.name,
  );
}
```

---

# 19. Add execution metrics only when useful

Don't turn the main interface into a telemetry dashboard.

Main UI:

```text
Working · 12.8s
```

Details:

```text
Duration     12.8s
Tool calls   4
Tokens       18.4k
Files        2
```

Advanced:

```text
Model
Input tokens
Output tokens
Latency
Tool latency
```

This preserves a clean default experience.

---

# 20. Add execution history

Once runs are persistent, a session can have:

```text
Executions

✓ Fix Hibernate mapping
  42s · 3 files

✓ Add authentication tests
  1m 12s · 5 files

⚠ Refactor repository
  Failed · 18s
```

Model:

```dart
class ExecutionSummary {
  final String id;
  final String title;
  final ExecutionStatus status;
  final Duration duration;
  final DateTime startedAt;
  final int filesChanged;

  const ExecutionSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.duration,
    required this.startedAt,
    required this.filesChanged,
  });
}
```

Clicking one should reopen its execution details.

This will become extremely useful when debugging long-running agent work.

---

# 21. Put execution history in the session

Your hierarchy should now look like:

```text
Session
├── Conversation
├── Executions
│   ├── Execution #1
│   ├── Execution #2
│   └── Execution #3
├── Changes
└── Context
```

That is much cleaner than treating execution as another chat message.

---

# 22. Final workspace composition

Your main screen is now approaching:

```text
┌────────────────────────────────────────────────────────────────────┐
│ Aljabr                                             ● Connected     │
├───────────────┬────────────────────────────────────┬───────────────┤
│               │                                    │               │
│ FILE TREE     │          CHAT / EDITOR             │  CONTEXT      │
│               │                                    │               │
│ src/          │  You                               │  Files        │
│  main/        │  Fix the Hibernate mapping        │  3 selected   │
│  test/        │                                    │               │
│               │  Aljabr                            │  Session...   │
│               │  I'll inspect the mapping...      │  Service...   │
│               │                                    │               │
│               │  ✓ Read SessionResource.java      │               │
│               │  ✓ Read Session.java              │               │
│               │  ● Applying changes...            │               │
│               │                                    │               │
│               │  ┌──────────────────────────────┐  │               │
│               │  │ Changes                  2  │  │               │
│               │  │ SessionResource.java       │  │               │
│               │  │ SessionService.java        │  │               │
│               │  │ [Review changes]           │  │               │
│               │  └──────────────────────────────┘  │               │
│               │                                    │               │
├───────────────┴────────────────────────────────────┴───────────────┤
│ ● Applying changes...                         [Details] [Stop]     │
├────────────────────────────────────────────────────────────────────┤
│ @SessionResource.java                                              │
│ Fix the Hibernate mapping...                             ⌘↵       │
│ +   / Command                              1 file in context       │
└────────────────────────────────────────────────────────────────────┘
```

This is a substantial UX milestone.

---

## One backend requirement

At this stage, the frontend needs the backend to expose a **stable execution lifecycle**.

At minimum:

```text
AGENT_STARTED
TOOL_STARTED
TOOL_COMPLETED
TOOL_FAILED
APPROVAL_REQUIRED
PATCH_PROPOSED
PATCH_APPLIED
PATCH_REVERTED
AGENT_STOPPING
AGENT_STOPPED
AGENT_COMPLETED
AGENT_FAILED
```

And each execution needs:

```json
{
  "execution_id": "...",
  "timestamp": "...",
  "type": "...",
  "payload": {}
}
```

The important part is `execution_id`.

Without it, reconnecting, retrying, or restoring a session becomes fragile.

---

# Next: resilience

The next improvement should **not** be another visual component.

Now we should make this system survive real-world failures:

```text
network disconnect
       ↓
agent still running
       ↓
reconnect
       ↓
restore execution
       ↓
catch up missed events
       ↓
UI returns to exact state
```

That means implementing:

### **Execution persistence + reconnect/recovery**

including:

* event sequence numbers
* last-seen event ID
* reconnect
* missed-event replay
* execution restoration
* app restart recovery
* duplicate-event protection
* optimistic UI rollback
* offline composer preservation

That is the point where the polished UX becomes **production-grade UX**, rather than merely looking polished.


Good. Now we make the execution system **resilient**.

The key change is to stop thinking of an agent run as a transient UI state. Treat it as a **recoverable event stream**.

```text
Agent
  │
  ▼
Execution Event Store
  │
  ├── UI
  ├── persistence
  └── reconnect/replay
```

## 1. Add event sequence numbers

Every execution event should have a monotonically increasing sequence.

```dart
class ExecutionEvent {
  final String executionId;
  final int sequence;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> payload;

  const ExecutionEvent({
    required this.executionId,
    required this.sequence,
    required this.timestamp,
    required this.type,
    required this.payload,
  });
}
```

Example:

```json
{
  "execution_id": "exec_123",
  "sequence": 17,
  "timestamp": "2026-08-16T12:41:20Z",
  "type": "TOOL_COMPLETED",
  "payload": {
    "tool_id": "tool_7",
    "tool_name": "read_file"
  }
}
```

The frontend can now say:

> I have received events through sequence 17.

---

# 2. Track the last received event

```dart
class ExecutionCursor {
  final String executionId;
  final int lastSequence;

  const ExecutionCursor({
    required this.executionId,
    required this.lastSequence,
  });
}
```

Provider:

```dart
class ExecutionCursorNotifier
    extends StateNotifier<Map<String, int>> {
  ExecutionCursorNotifier()
      : super({});

  void advance(
    String executionId,
    int sequence,
  ) {
    final previous =
        state[executionId] ?? 0;

    if (sequence <= previous) {
      return;
    }

    state = {
      ...state,
      executionId: sequence,
    };
  }

  int lastSequence(String executionId) {
    return state[executionId] ?? 0;
  }
}
```

This gives you duplicate protection.

---

# 3. Never process an old event twice

Your event consumer should become:

```dart
void handleEvent(
  WidgetRef ref,
  ExecutionEvent event,
) {
  final cursor = ref.read(
    executionCursorProvider.notifier,
  );

  final last =
      cursor.lastSequence(
        event.executionId,
      );

  if (event.sequence <= last) {
    return;
  }

  cursor.advance(
    event.executionId,
    event.sequence,
  );

  ExecutionEventMapper().apply(
    ref,
    event,
  );
}
```

This is essential when reconnecting.

---

# 4. Persist the cursor

Use your existing persistence layer rather than creating another database abstraction.

Conceptually:

```dart
abstract class ExecutionCursorStore {
  Future<int> getLastSequence(
    String executionId,
  );

  Future<void> saveLastSequence(
    String executionId,
    int sequence,
  );
}
```

Then:

```dart
class PersistentExecutionCursor
    extends ExecutionCursorStore {
  // Implement with your existing
  // local persistence.
}
```

The important invariant:

```text
receive event
    ↓
process event
    ↓
persist sequence
```

Don't persist a cursor ahead of an event that wasn't successfully applied.

---

# 5. Reconnection manager

Create:

```text
lib/features/execution/
├── recovery/
│   ├── execution_recovery.dart
│   ├── connection_manager.dart
│   └── event_replay.dart
```

```dart
enum ConnectionStatus {
  connected,
  connecting,
  disconnected,
  reconnecting,
}
```

Provider:

```dart
final connectionStatusProvider =
    StateProvider<ConnectionStatus>(
  (_) => ConnectionStatus.connected,
);
```

---

# 6. Connection lifecycle

```dart
class ConnectionManager {
  ConnectionManager({
    required this.onEvent,
    required this.onStatusChanged,
  });

  final void Function(ExecutionEvent event) onEvent;
  final void Function(ConnectionStatus status)
      onStatusChanged;

  Future<void> reconnect() async {
    onStatusChanged(
      ConnectionStatus.reconnecting,
    );

    try {
      await _connect();

      onStatusChanged(
        ConnectionStatus.connected,
      );
    } catch (_) {
      onStatusChanged(
        ConnectionStatus.disconnected,
      );

      rethrow;
    }
  }

  Future<void> _connect() async {
    // Connect websocket/SSE transport.
  }
}
```

---

# 7. The UX during disconnect

Don't throw a giant error dialog at the user.

Use a small banner:

```text
┌──────────────────────────────────────────────────────────────┐
│ ◌ Connection interrupted · Reconnecting...                   │
└──────────────────────────────────────────────────────────────┘
```

If the agent is still executing:

```text
┌──────────────────────────────────────────────────────────────┐
│ ◌ Connection interrupted · Your agent may still be running   │
└──────────────────────────────────────────────────────────────┘
```

That's much better than:

> Connection failed.

because the latter makes the user think the agent itself failed.

---

# 8. Replay missed events

After reconnecting:

```text
Frontend
   │
   │ lastSequence = 17
   ▼
Backend
   │
   │ events 18...25
   ▼
Frontend
```

API:

```dart
Future<List<ExecutionEvent>> replayEvents({
  required String executionId,
  required int afterSequence,
}) async {
  return api.getExecutionEvents(
    executionId: executionId,
    afterSequence: afterSequence,
  );
}
```

Then:

```dart
Future<void> recoverExecution(
  WidgetRef ref,
  String executionId,
) async {
  final cursor = ref.read(
    executionCursorProvider.notifier,
  );

  final last =
      cursor.lastSequence(executionId);

  final events =
      await replayEvents(
        executionId: executionId,
        afterSequence: last,
      );

  for (final event in events) {
    handleEvent(ref, event);
  }
}
```

---

# 9. Recover active executions after app restart

This is a major UX improvement.

When Aljabr starts:

```text
Application startup
       ↓
Load active executions
       ↓
For each execution
       ↓
Get current server state
       ↓
Replay missing events
       ↓
Restore UI
```

Create:

```dart
class ExecutionRecoveryService {
  Future<void> recoverAll(
    WidgetRef ref,
  ) async {
    final executions =
        await api.getActiveExecutions();

    for (final execution in executions) {
      await recoverExecution(
        ref,
        execution.id,
      );
    }
  }
}
```

Then startup:

```dart
Future<void> initializeApp(
  WidgetRef ref,
) async {
  await loadWorkspace();

  await ExecutionRecoveryService()
      .recoverAll(ref);

  await restoreSessions();
}
```

Now closing and reopening Aljabr doesn't necessarily destroy the user's agent state.

---

# 10. Add server-side execution snapshot

Events alone aren't always enough.

Have an endpoint conceptually like:

```http
GET /executions/:id
```

Response:

```json
{
  "id": "exec_123",
  "status": "running",
  "current_action": "Running tests",
  "last_sequence": 25,
  "started_at": "...",
  "metrics": {
    "tokens": 18400,
    "tool_calls": 7
  }
}
```

Then recovery becomes:

```text
snapshot
   +
missing events
   ↓
exact UI state
```

---

# 11. Reconcile instead of blindly replaying

Suppose the frontend says:

```text
running
```

but the backend says:

```text
completed
```

The server wins.

Create:

```dart
class ExecutionReconciler {
  ExecutionState reconcile({
    required ExecutionState local,
    required ExecutionSnapshot remote,
  }) {
    return local.copyWith(
      status: remote.status,
      currentAction:
          remote.currentAction,
    );
  }
}
```

This prevents stale UI.

---

# 12. Offline composer preservation

If the network disappears while the user is typing:

**never lose the prompt.**

Persist draft state:

```dart
class ComposerDraft {
  final String sessionId;
  final String text;
  final List<ComposerContext> contexts;

  const ComposerDraft({
    required this.sessionId,
    required this.text,
    required this.contexts,
  });
}
```

Save on a small debounce:

```dart
Timer? _draftTimer;

void onTextChanged(String text) {
  _draftTimer?.cancel();

  _draftTimer = Timer(
    const Duration(milliseconds: 400),
    () {
      draftStore.save(
        ComposerDraft(
          sessionId: sessionId,
          text: text,
          contexts: contexts,
        ),
      );
    },
  );
}
```

On startup:

```dart
final draft =
    await draftStore.load(sessionId);

if (draft != null) {
  restoreDraft(draft);
}
```

---

# 13. Don't send twice

Network failures create a nasty problem:

```text
User clicks Send
       ↓
request reaches server
       ↓
response lost
       ↓
frontend thinks it failed
       ↓
user clicks Retry
       ↓
DUPLICATE AGENT RUN
```

Solve this with an idempotency key.

```dart
class AgentRequest {
  final String requestId;
  final String prompt;
  final AgentMode mode;
  final List<AgentContextItem> context;

  const AgentRequest({
    required this.requestId,
    required this.prompt,
    required this.mode,
    required this.context,
  });
}
```

Generate once:

```dart
final requestId =
    const Uuid().v4();
```

Retry using the **same** request ID.

Backend:

```text
request_id
     ↓
already executed?
     ├── yes → return existing execution
     └── no  → create execution
```

This is one of the most important reliability changes.

---

# 14. Optimistic UI

When the user sends:

```text
Fix the Hibernate mapping
```

show immediately:

```text
You
Fix the Hibernate mapping

Aljabr
Working...
```

Don't wait for the backend response before rendering the user message.

But mark it:

```dart
enum MessageDeliveryStatus {
  pending,
  sent,
  failed,
}
```

So a temporary network problem can show:

```text
You
Fix the Hibernate mapping
           ⚠ Not sent

[Retry]
```

rather than silently losing it.

---

# 15. Execution recovery banner

Create one reusable widget:

```dart
class ConnectionBanner
    extends ConsumerWidget {
  const ConnectionBanner({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final status = ref.watch(
      connectionStatusProvider,
    );

    switch (status) {
      case ConnectionStatus.connected:
        return const SizedBox.shrink();

      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return const _Banner(
          text: 'Reconnecting...',
        );

      case ConnectionStatus.disconnected:
        return const _Banner(
          text: 'Connection lost',
        );
    }
  }
}
```

Keep this global and reusable.

---

# 16. Handle "agent still running"

This case deserves special treatment.

If:

```text
frontend disconnected
backend agent continues
frontend reconnects
```

the user should see:

```text
✓ Reconnected

Agent is still running
Currently: Running tests

[Details]
```

Not:

```text
New session
```

Not:

```text
Agent stopped
```

The execution ID makes this possible.

---

# 17. Add event log inspection

For debugging advanced runs:

```text
Execution
────────────────────────────

12:41:01  AGENT_STARTED
12:41:02  TOOL_STARTED
12:41:02  TOOL_COMPLETED
12:41:03  TOOL_STARTED
12:41:04  PATCH_PROPOSED
12:41:06  APPROVAL_REQUIRED
```

Don't show this by default.

Add:

```text
View event log
```

inside the execution drawer.

---

# 18. Add safe state transitions

Don't let arbitrary code set:

```dart
status = ExecutionStatus.completed;
```

from anywhere.

Define valid transitions:

```dart
bool canTransition(
  ExecutionStatus from,
  ExecutionStatus to,
) {
  switch (from) {
    case ExecutionStatus.idle:
      return to == ExecutionStatus.running;

    case ExecutionStatus.running:
      return {
        ExecutionStatus.waitingForApproval,
        ExecutionStatus.stopping,
        ExecutionStatus.completed,
        ExecutionStatus.failed,
        ExecutionStatus.paused,
      }.contains(to);

    case ExecutionStatus.waitingForApproval:
      return {
        ExecutionStatus.running,
        ExecutionStatus.stopping,
        ExecutionStatus.failed,
      }.contains(to);

    case ExecutionStatus.stopping:
      return {
        ExecutionStatus.stopped,
        ExecutionStatus.failed,
      }.contains(to);

    case ExecutionStatus.paused:
      return {
        ExecutionStatus.running,
        ExecutionStatus.stopping,
      }.contains(to);

    case ExecutionStatus.stopped:
    case ExecutionStatus.completed:
    case ExecutionStatus.failed:
      return to == ExecutionStatus.running;
  }
}
```

Then:

```dart
void transition(
  ExecutionStatus next,
) {
  if (!canTransition(
    state.status,
    next,
  )) {
    return;
  }

  state = state.copyWith(
    status: next,
  );
}
```

This prevents subtle state corruption.

---

# 19. Add a state machine test

This is worth testing thoroughly.

```dart
test(
  'running can transition to completed',
  () {
    expect(
      canTransition(
        ExecutionStatus.running,
        ExecutionStatus.completed,
      ),
      true,
    );
  },
);

test(
  'completed cannot transition to stopping',
  () {
    expect(
      canTransition(
        ExecutionStatus.completed,
        ExecutionStatus.stopping,
      ),
      false,
    );
  },
);
```

And event replay:

```dart
test(
  'duplicate events are ignored',
  () {
    final cursor = ExecutionCursor(
      executionId: 'exec_1',
      lastSequence: 10,
    );

    expect(
      11 > cursor.lastSequence,
      true,
    );

    expect(
      10 > cursor.lastSequence,
      false,
    );
  },
);
```

---

# 20. The architecture now becomes clean

At this point, the frontend should roughly follow:

```text
                         ┌───────────────┐
                         │   Backend     │
                         └───────┬───────┘
                                 │
                          Event stream
                                 │
                                 ▼
                       ┌──────────────────┐
                       │ Event Processor  │
                       └────────┬─────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
             Cursor Store            Execution Store
                    │                       │
                    └───────────┬───────────┘
                                ▼
                         Execution State
                                │
              ┌─────────────────┼────────────────┐
              ▼                 ▼                ▼
         Status Bar          Drawer          Timeline
```

And separately:

```text
Composer
   │
   ▼
AgentRequest
   │
   ├── requestId
   ├── prompt
   ├── mode
   └── context
          │
          ▼
       Backend
```

That separation is important.

---

# 21. The UX is now resilient

The full flow becomes:

```text
User
 │
 ├── types prompt
 │
 ├── selects context
 │
 └── presses Cmd+Enter
          │
          ▼
      AgentRequest
          │
          ▼
      Execution #42
          │
          ├── planning
          ├── tools
          ├── changes
          └── tests
                │
                ▼
             complete
```

If the network breaks:

```text
Execution #42
      │
      ├──── backend continues
      │
      X frontend disconnects
      │
      ▼
 reconnect
      │
      ▼
lastSequence = 17
      │
      ▼
replay 18 → 31
      │
      ▼
exact execution restored
```

That is the difference between a demo-grade AI interface and a serious development tool.

---

## Next improvement: the actual code-change UX

Now that execution is reliable, the next layer should be **how Aljabr presents and applies changes**.

I would implement:

```text
                    AGENT
                      │
                 proposes patch
                      ▼
              ┌───────────────┐
              │ Change Preview│
              └───────┬───────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Review       Reject      Apply
          │                       │
          ▼                       ▼
      Diff view              Workspace
          │
          ▼
   Accept individual hunk
```

Specifically, the next code should introduce:

* `ChangeSet`
* `FileChange`
* `DiffHunk`
* per-hunk accept/reject
* side-by-side/unified diff
* "Apply all"
* "Revert"
* conflict detection
* changed-file badges
* inline **Ask Aljabr** on a diff
* automatic test result attached to the change

That will make the **agent → code → review → apply** loop feel genuinely polished rather than simply functional.



Yes. Let’s continue with the **code-change UX**.

This is the next major polish layer because the agent should not jump from:

> “I changed your code”

straight to modifying the workspace.

Instead:

```text
Agent
  ↓
Proposed changes
  ↓
Review
  ↓
Accept / reject
  ↓
Apply
  ↓
Test
  ↓
Verify
```

---

# 1. Create the change model

Add:

```text
lib/features/changes/
├── models/
│   ├── change_set.dart
│   ├── file_change.dart
│   └── diff_hunk.dart
├── providers/
│   └── change_provider.dart
└── widgets/
    ├── change_summary.dart
    ├── changed_file_tile.dart
    ├── diff_view.dart
    └── diff_hunk.dart
```

### `change_set.dart`

```dart
class ChangeSet {
  final String id;
  final String executionId;
  final List<FileChange> files;

  const ChangeSet({
    required this.id,
    required this.executionId,
    required this.files,
  });

  int get additions => files.fold(
        0,
        (sum, file) => sum + file.additions,
      );

  int get deletions => files.fold(
        0,
        (sum, file) => sum + file.deletions,
      );

  int get changedFiles => files.length;
}
```

---

# 2. File changes

```dart
enum FileChangeType {
  added,
  modified,
  deleted,
  renamed,
}

enum ChangeDecision {
  pending,
  accepted,
  rejected,
}

class FileChange {
  final String path;
  final String? oldPath;
  final FileChangeType type;
  final List<DiffHunk> hunks;
  final ChangeDecision decision;

  const FileChange({
    required this.path,
    this.oldPath,
    required this.type,
    required this.hunks,
    this.decision = ChangeDecision.pending,
  });

  int get additions => hunks.fold(
        0,
        (sum, hunk) => sum + hunk.additions,
      );

  int get deletions => hunks.fold(
        0,
        (sum, hunk) => sum + hunk.deletions,
      );

  FileChange copyWith({
    List<DiffHunk>? hunks,
    ChangeDecision? decision,
  }) {
    return FileChange(
      path: path,
      oldPath: oldPath,
      type: type,
      hunks: hunks ?? this.hunks,
      decision: decision ?? this.decision,
    );
  }
}
```

---

# 3. Diff hunks

```dart
class DiffHunk {
  final String id;
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final List<DiffLine> lines;
  final ChangeDecision decision;

  const DiffHunk({
    required this.id,
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.lines,
    this.decision = ChangeDecision.pending,
  });

  int get additions =>
      lines.where((line) => line.type == '+').length;

  int get deletions =>
      lines.where((line) => line.type == '-').length;

  DiffHunk copyWith({
    ChangeDecision? decision,
  }) {
    return DiffHunk(
      id: id,
      oldStart: oldStart,
      oldCount: oldCount,
      newStart: newStart,
      newCount: newCount,
      lines: lines,
      decision: decision ?? this.decision,
    );
  }
}

class DiffLine {
  final String type;
  final String text;
  final int? oldLine;
  final int? newLine;

  const DiffLine({
    required this.type,
    required this.text,
    this.oldLine,
    this.newLine,
  });
}
```

---

# 4. Change provider

```dart
class ChangeNotifier
    extends StateNotifier<ChangeSet?> {
  ChangeNotifier() : super(null);

  void setChangeSet(
    ChangeSet changeSet,
  ) {
    state = changeSet;
  }

  void acceptFile(String path) {
    final current = state;
    if (current == null) return;

    state = ChangeSet(
      id: current.id,
      executionId: current.executionId,
      files: [
        for (final file in current.files)
          file.path == path
              ? file.copyWith(
                  decision: ChangeDecision.accepted,
                )
              : file,
      ],
    );
  }

  void rejectFile(String path) {
    final current = state;
    if (current == null) return;

    state = ChangeSet(
      id: current.id,
      executionId: current.executionId,
      files: [
        for (final file in current.files)
          file.path == path
              ? file.copyWith(
                  decision: ChangeDecision.rejected,
                )
              : file,
      ],
    );
  }

  void acceptHunk(
    String path,
    String hunkId,
  ) {
    final current = state;
    if (current == null) return;

    state = ChangeSet(
      id: current.id,
      executionId: current.executionId,
      files: [
        for (final file in current.files)
          if (file.path == path)
            file.copyWith(
              hunks: [
                for (final hunk in file.hunks)
                  hunk.id == hunkId
                      ? hunk.copyWith(
                          decision:
                              ChangeDecision.accepted,
                        )
                      : hunk,
              ],
            )
          else
            file,
      ],
    );
  }
}
```

Provider:

```dart
final changeProvider =
    StateNotifierProvider.family<
        ChangeNotifier,
        ChangeSet?,
        String>(
  (ref, sessionId) {
    return ChangeNotifier();
  },
);
```

---

# 5. Change summary

When the agent proposes code:

```text
┌─────────────────────────────────────────────┐
│ Changes                                     │
│                                             │
│ 3 files changed      +42  -17               │
│                                             │
│ ✓ SessionResource.java       +18  -4       │
│ ✓ SessionService.java        +21  -8       │
│ + SessionTest.java            +3  -5       │
│                                             │
│              [Review changes] [Apply all]   │
└─────────────────────────────────────────────┘
```

Build:

```dart
class ChangeSummary extends ConsumerWidget {
  const ChangeSummary({
    super.key,
    required this.sessionId,
    required this.onReview,
    required this.onApply,
  });

  final String sessionId;
  final VoidCallback onReview;
  final VoidCallback onApply;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final changes = ref.watch(
      changeProvider(sessionId),
    );

    if (changes == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_note_outlined,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Changes',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${changes.changedFiles} files',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '+${changes.additions} '
              '-${changes.deletions}',
            ),

            const SizedBox(height: 12),

            for (final file in changes.files)
              ChangedFileTile(
                file: file,
              ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReview,
                  child: const Text(
                    'Review changes',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onApply,
                  child: const Text(
                    'Apply all',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

# 6. Changed file tile

```dart
class ChangedFileTile extends StatelessWidget {
  const ChangedFileTile({
    super.key,
    required this.file,
  });

  final FileChange file;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _icon(),
        size: 18,
      ),
      title: Text(
        file.path,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '+${file.additions} '
        '-${file.deletions}',
      ),
      trailing: _decisionIcon(),
    );
  }

  IconData _icon() {
    switch (file.type) {
      case FileChangeType.added:
        return Icons.add_circle_outline;

      case FileChangeType.modified:
        return Icons.edit_outlined;

      case FileChangeType.deleted:
        return Icons.delete_outline;

      case FileChangeType.renamed:
        return Icons.drive_file_rename_outline;
    }
  }

  Widget _decisionIcon() {
    switch (file.decision) {
      case ChangeDecision.accepted:
        return const Icon(
          Icons.check_circle_outline,
        );

      case ChangeDecision.rejected:
        return const Icon(
          Icons.cancel_outlined,
        );

      case ChangeDecision.pending:
        return const Icon(
          Icons.circle_outlined,
        );
    }
  }
}
```

---

# 7. The diff view

The diff should be the center of the review experience.

```text
SessionResource.java

@@ -42,7 +42,12 @@

  public Session getSession(...) {
-   return repository.find(id);
+   Session session =
+       repository.find(id);
+
+   if (session == null) {
+     throw new NotFoundException();
+   }
+
+   return session;
  }
```

Every hunk gets its own action:

```text
[Accept hunk] [Reject hunk] [Ask Aljabr]
```

---

# 8. Diff hunk widget

```dart
class DiffHunkView extends ConsumerWidget {
  const DiffHunkView({
    super.key,
    required this.sessionId,
    required this.path,
    required this.hunk,
  });

  final String sessionId;
  final String path;
  final DiffHunk hunk;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        _HunkHeader(
          hunk: hunk,
          onAccept: () {
            ref
                .read(
                  changeProvider(sessionId)
                      .notifier,
                )
                .acceptHunk(
                  path,
                  hunk.id,
                );
          },
        ),

        for (final line in hunk.lines)
          _DiffLineView(
            line: line,
          ),
      ],
    );
  }
}
```

---

# 9. Hunk header

```dart
class _HunkHeader extends StatelessWidget {
  const _HunkHeader({
    required this.hunk,
    required this.onAccept,
  });

  final DiffHunk hunk;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '@@ -${hunk.oldStart},'
              '${hunk.oldCount} '
              '+${hunk.newStart},'
              '${hunk.newCount} @@',
            ),
          ),

          TextButton(
            onPressed: onAccept,
            child: const Text('Accept'),
          ),

          TextButton(
            onPressed: () {
              // Reject hunk.
            },
            child: const Text('Reject'),
          ),

          IconButton(
            tooltip: 'Ask Aljabr',
            onPressed: () {
              // Open contextual composer.
            },
            icon: const Icon(
              Icons.auto_awesome_outlined,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

# 10. Diff line

```dart
class _DiffLineView extends StatelessWidget {
  const _DiffLineView({
    required this.line,
  });

  final DiffLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            '${line.oldLine ?? ''}',
            textAlign: TextAlign.right,
          ),
        ),

        SizedBox(
          width: 48,
          child: Text(
            '${line.newLine ?? ''}',
            textAlign: TextAlign.right,
          ),
        ),

        SizedBox(
          width: 24,
          child: Text(
            line.type,
            textAlign: TextAlign.center,
          ),
        ),

        Expanded(
          child: Text(
            line.text,
          ),
        ),
      ],
    );
  }
}
```

For a production editor, use a monospace font and virtualized rendering rather than building thousands of widgets at once.

---

# 11. Add "Ask Aljabr" directly to a hunk

This is where the previous composer architecture becomes powerful.

Click:

```text
✦ Ask Aljabr
```

and prepare:

```text
@SessionResource.java:42-48

Explain why this change is necessary and
whether there is a safer alternative.
```

Or:

```text
@SessionResource.java:42-48

Review this change for correctness.
```

The action runner can now accept a selection:

```dart
const AgentAction(
  type: AgentActionType.review,
  label: 'Review hunk',
  path: 'SessionResource.java',
);
```

with:

```dart
startLine: 42,
endLine: 48,
```

---

# 12. Apply should be explicit

Don't immediately apply every patch simply because the agent generated it.

Create:

```dart
class ChangeApplier {
  Future<void> apply(
    ChangeSet changes,
  ) async {
    final acceptedFiles =
        changes.files.where(
      (file) =>
          file.decision ==
          ChangeDecision.accepted,
    );

    for (final file in acceptedFiles) {
      await _applyFile(file);
    }
  }

  Future<void> _applyFile(
    FileChange file,
  ) async {
    // Apply accepted hunks.
  }
}
```

For a file with individual hunk decisions:

```text
File
 ├── Hunk A ✓
 ├── Hunk B ✕
 └── Hunk C ✓
```

Only A and C are applied.

---

# 13. Default the generated changes to pending

```dart
ChangeDecision.pending
```

is the correct default.

The user sees:

```text
3 files changed

[Review changes] [Apply all]
```

not:

```text
3 files silently modified
```

---

# 14. Add apply confirmation for risky changes

Not every change needs a confirmation dialog.

For normal code:

```text
[Apply all]
```

For destructive changes:

```text
⚠ Delete 4 files?

[Cancel] [Review] [Delete files]
```

Model risk:

```dart
enum ChangeRisk {
  low,
  medium,
  high,
}

class FileChange {
  // ...

  final ChangeRisk risk;
}
```

Examples:

```text
Modify Java file       low
Add test               low
Delete source file     high
Change build config    medium
Change database schema high
```

---

# 15. Detect conflicts before applying

This is critical.

Suppose:

```text
Agent reads file at version A
        ↓
User edits file
        ↓
Agent tries to apply patch
```

Don't overwrite the user's work.

Capture the original content hash:

```dart
class FileChange {
  final String path;
  final String baseHash;

  // ...
}
```

Before applying:

```dart
final currentHash =
    await workspace.hashFile(
      file.path,
    );

if (currentHash != file.baseHash) {
  throw ChangeConflictException(
    file.path,
  );
}
```

Then:

```text
⚠ File changed since Aljabr created this patch.

SessionResource.java

[Review conflict]
[Rebase change]
[Cancel]
```

---

# 16. Rebase workflow

The ideal UX:

```text
Agent patch
    +
User's latest file
    ↓
Rebase
    ↓
New patch
    ↓
Review again
```

Don't silently resolve complicated conflicts.

---

# 17. Show changed-file badges in the tree

After a patch is proposed:

```text
src/
 ├── SessionResource.java   M  +18 -4
 ├── SessionService.java    M  +21 -8
 └── SessionTest.java       A  +3
```

This makes changes discoverable without opening the diff.

A simple model:

```dart
class FileChangeBadge {
  final FileChangeType type;
  final int additions;
  final int deletions;

  const FileChangeBadge({
    required this.type,
    required this.additions,
    required this.deletions,
  });
}
```

---

# 18. Editor gutter markers

Inside the editor:

```text
42 │ return session;
43 │
44 │ + if (session == null) {
45 │ +   throw NotFoundException();
46 │ + }
```

Add a gutter marker:

```text
44 │ ●
45 │ ●
46 │ ●
```

Clicking it opens the change hunk.

This makes the editor and diff view feel like one system.

---

# 19. Apply state

After clicking Apply:

```text
Pending
   ↓
Applying
   ↓
Applied
```

The UI should show:

```text
Applying 3 changes...

✓ SessionResource.java
● SessionService.java
○ SessionTest.java
```

Then:

```text
✓ Changes applied

3 files · +42 -17
```

---

# 20. Automatically verify after apply

Don't stop at:

> Changes applied.

Run the relevant verification.

```text
Apply
 ↓
Format
 ↓
Compile
 ↓
Test
 ↓
Verify
```

Execution timeline:

```text
✓ Patch applied
✓ Formatting
✓ Compile
● Running tests
○ Verification
```

If tests pass:

```text
✓ Changes applied and verified

Tests
128 passed · 0 failed
```

If tests fail:

```text
⚠ Changes applied, but verification failed

128 passed · 3 failed

[Inspect failures]
[Ask Aljabr to fix]
```

---

# 21. "Fix failing tests" should reuse context

Clicking:

```text
[Ask Aljabr to fix]
```

should create:

```text
/fix

The latest changes caused these test failures:

SessionResourceTest.shouldReturn404
SessionServiceTest.shouldRejectMissingSession
```

Context:

```text
@SessionResource.java
@SessionService.java
@SessionResourceTest.java
@test output
```

This should be a structured `AgentRequest`, not just a pasted terminal log.

---

# 22. Add revert

After applying:

```text
✓ Changes applied

[Review] [Revert]
```

Revert should create a reversible workspace operation.

```dart
class ChangeReverter {
  Future<void> revert(
    ChangeSet changes,
  ) async {
    // Restore only files belonging
    // to this change set.
  }
}
```

Never implement this as:

```text
git reset --hard
```

because that can destroy unrelated user work.

The revert must be scoped to the exact applied change set.

---

# 23. Add change-set identity

Every modification needs:

```dart
class AppliedChangeSet {
  final String id;
  final String executionId;
  final DateTime appliedAt;
  final List<String> files;

  const AppliedChangeSet({
    required this.id,
    required this.executionId,
    required this.appliedAt,
    required this.files,
  });
}
```

Now the UI can say:

```text
Applied by Aljabr
Execution #42
3 files
2 minutes ago
```

---

# 24. The resulting interaction

The entire agent coding loop becomes:

```text
User
 │
 │ "Fix authentication"
 ▼
Agent
 │
 ├── inspect
 ├── reason
 ├── propose
 ▼
ChangeSet
 │
 ├── SessionService.java
 ├── AuthController.java
 └── AuthTest.java
 │
 ▼
Review
 │
 ├── Accept hunk
 ├── Reject hunk
 └── Ask Aljabr
 │
 ▼
Apply
 │
 ▼
Verify
 │
 ├── ✓ compile
 ├── ✓ tests
 └── ✓ checks
 │
 ▼
Completed
```

This is the core **agentic development loop**.

---

# 25. One more UX improvement: don't force the user into diff mode

The change summary should support three levels:

### Level 1 — glance

```text
3 files · +42 -17

[Review] [Apply]
```

### Level 2 — file review

```text
SessionService.java
+21 -8

[Accept] [Reject]
```

### Level 3 — hunk review

```text
@@ -42 +42,8 @@

- return repository.find(id);
+ ...
 
[Accept hunk] [Reject] [Ask Aljabr]
```

This is important because not every change deserves the same cognitive load.

---

# 26. Architecture after this step

You now have four strong subsystems:

```text
┌──────────────────────────────────────────────┐
│                  ALJABR                      │
│                                              │
│  Composer                                    │
│      │                                       │
│      ▼                                       │
│  AgentRequest ──────► Execution              │
│                           │                  │
│                           ▼                  │
│                     Event Stream              │
│                           │                  │
│                           ▼                  │
│                     ChangeSet                 │
│                           │                  │
│                           ▼                  │
│                      Diff UI                  │
│                           │                  │
│                    Accept / Reject            │
│                           │                  │
│                           ▼                  │
│                       Apply                   │
│                           │                  │
│                           ▼                  │
│                      Verify                   │
└──────────────────────────────────────────────┘
```

The next thing I would tackle is **the editor itself**.

Not another generic UI pass—the editor should become deeply integrated with Aljabr:

```text
code selection
     │
     ├── Explain
     ├── Fix
     ├── Refactor
     ├── Generate tests
     ├── Find usages
     └── Ask Aljabr
             │
             ▼
       inline response
```

And, importantly, the response should appear **beside the code being discussed**, rather than forcing the user to jump back into chat.

That is the next layer that will make Aljabr feel like an actual AI-native development environment rather than a chat application attached to an IDE.





Let’s move into the **AI-native editor layer**.

The objective is simple: the user should be able to stay in the code and invoke Aljabr **at the exact location where the problem exists**.

---

# 1. Code selection becomes a first-class context

Create:

```text
lib/features/editor/
├── models/
│   ├── code_selection.dart
│   └── editor_context.dart
├── providers/
│   ├── editor_selection_provider.dart
│   └── editor_context_provider.dart
└── widgets/
    ├── selection_toolbar.dart
    ├── inline_ai_panel.dart
    └── editor_action_menu.dart
```

### `code_selection.dart`

```dart
class CodeSelection {
  final String filePath;
  final int startLine;
  final int endLine;
  final int startColumn;
  final int endColumn;
  final String text;

  const CodeSelection({
    required this.filePath,
    required this.startLine,
    required this.endLine,
    required this.startColumn,
    required this.endColumn,
    required this.text,
  });

  bool get isSingleLine =>
      startLine == endLine;

  int get lineCount =>
      endLine - startLine + 1;
}
```

This is more useful than simply storing selected text.

The system now knows:

```text
SessionService.java
lines 42–51
columns 8–32
```

---

# 2. Editor context

```dart
class EditorContext {
  final String filePath;
  final String language;
  final CodeSelection? selection;
  final int cursorLine;
  final int cursorColumn;

  const EditorContext({
    required this.filePath,
    required this.language,
    this.selection,
    required this.cursorLine,
    required this.cursorColumn,
  });
}
```

Provider:

```dart
final editorContextProvider =
    StateProvider<EditorContext?>(
  (_) => null,
);
```

Whenever the cursor or selection changes:

```dart
ref
    .read(editorContextProvider.notifier)
    .state = EditorContext(
      filePath: filePath,
      language: language,
      selection: selection,
      cursorLine: line,
      cursorColumn: column,
    );
```

---

# 3. Selection toolbar

When code is selected, show a small contextual toolbar.

```text
┌──────────────────────────────────────────────────────┐
│ Explain  Fix  Refactor  Test  Review  ✦ Ask Aljabr  │
└──────────────────────────────────────────────────────┘
                         │
                         ▼
                   selected code
```

Don't make it huge.

The toolbar should feel like a native editor affordance.

---

# 4. Build the toolbar

```dart
class SelectionToolbar extends ConsumerWidget {
  const SelectionToolbar({
    super.key,
    required this.contextData,
  });

  final EditorContext contextData;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Material(
      elevation: 6,
      borderRadius:
          BorderRadius.circular(8),
      child: Padding(
        padding:
            const EdgeInsets.all(4),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            _Action(
              label: 'Explain',
              icon: Icons.lightbulb_outline,
              onPressed: () =>
                  _run(
                    ref,
                    AgentAction.explain,
                  ),
            ),
            _Action(
              label: 'Fix',
              icon: Icons.build_outlined,
              onPressed: () =>
                  _run(
                    ref,
                    AgentAction.fix,
                  ),
            ),
            _Action(
              label: 'Refactor',
              icon: Icons.auto_fix_high_outlined,
              onPressed: () =>
                  _run(
                    ref,
                    AgentAction.refactor,
                  ),
            ),
            _Action(
              label: 'Tests',
              icon: Icons.science_outlined,
              onPressed: () =>
                  _run(
                    ref,
                    AgentAction.generateTests,
                  ),
            ),
            _Action(
              label: 'Ask',
              icon: Icons.auto_awesome_outlined,
              onPressed: () =>
                  _run(
                    ref,
                    AgentAction.ask,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _run(
    WidgetRef ref,
    AgentAction action,
  ) {
    // Convert editor context
    // into an AgentRequest.
  }
}
```

---

# 5. Structured agent actions

Don't construct prompts everywhere.

Create:

```dart
enum AgentAction {
  explain,
  fix,
  refactor,
  generateTests,
  review,
  ask,
}
```

Then:

```dart
class AgentActionRequestBuilder {
  AgentRequest build({
    required AgentAction action,
    required EditorContext context,
    String? additionalInstruction,
  }) {
    return AgentRequest(
      requestId: const Uuid().v4(),
      prompt: _promptFor(
        action,
        context,
        additionalInstruction,
      ),
      mode: AgentMode.code,
      context: [
        AgentContextItem.file(
          path: context.filePath,
        ),
        if (context.selection != null)
          AgentContextItem.selection(
            selection: context.selection!,
          ),
      ],
    );
  }

  String _promptFor(
    AgentAction action,
    EditorContext context,
    String? instruction,
  ) {
    switch (action) {
      case AgentAction.explain:
        return 'Explain the selected code.';

      case AgentAction.fix:
        return 'Identify and fix the problem '
            'in the selected code.';

      case AgentAction.refactor:
        return 'Refactor the selected code '
            'while preserving behavior.';

      case AgentAction.generateTests:
        return 'Generate appropriate tests '
            'for the selected code.';

      case AgentAction.review:
        return 'Review the selected code '
            'for correctness and maintainability.';

      case AgentAction.ask:
        return instruction ??
            'Analyze the selected code.';
    }
  }
}
```

This gives you consistent behavior across the application.

---

# 6. The important part: inline AI

For **Explain**, don't automatically open the full chat.

Instead:

```text
SessionService.java

42 │ final session = repository.find(id);
43 │
44 │ if (session == null) {
45 │   throw new NotFoundException();
46 │ }

        ┌──────────────────────────────────────────┐
        │ ✦ Aljabr                                 │
        │                                          │
        │ This check prevents a null Session from │
        │ reaching the caller. The exception also │
        │ gives the API layer a predictable       │
        │ failure path.                           │
        │                                          │
        │ [Ask follow-up] [Open in chat]          │
        └──────────────────────────────────────────┘
```

This dramatically reduces context switching.

---

# 7. Inline AI model

```dart
enum InlineAiStatus {
  loading,
  streaming,
  completed,
  failed,
}

class InlineAiResponse {
  final String id;
  final CodeSelection selection;
  final InlineAiStatus status;
  final String text;

  const InlineAiResponse({
    required this.id,
    required this.selection,
    required this.status,
    this.text = '',
  });
}
```

Provider:

```dart
final inlineAiProvider =
    StateNotifierProvider<
        InlineAiNotifier,
        InlineAiResponse?>(
  (ref) => InlineAiNotifier(),
);
```

---

# 8. Streaming response

The response should appear progressively.

```text
✦ Aljabr

This method first retrieves the session...
```

then:

```text
✦ Aljabr

This method first retrieves the session
from the repository. If the repository
returns null, the method throws...
```

Don't wait 8 seconds before rendering the whole answer.

---

# 9. Inline panel

```dart
class InlineAiPanel extends ConsumerWidget {
  const InlineAiPanel({
    super.key,
    required this.response,
  });

  final InlineAiResponse response;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Aljabr',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () {
                    ref
                        .read(
                          inlineAiProvider
                              .notifier,
                        )
                        .clear();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SelectableText(
              response.text,
            ),

            if (response.status ==
                InlineAiStatus.loading)
              const Padding(
                padding:
                    EdgeInsets.only(top: 8),
                child:
                    LinearProgressIndicator(),
              ),

            const SizedBox(height: 8),

            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ask follow-up',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Open in chat',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

# 10. Fix should produce a patch

There is an important distinction:

```text
Explain
    → Inline answer

Review
    → Inline findings

Fix
    → Proposed ChangeSet

Refactor
    → Proposed ChangeSet

Tests
    → Proposed ChangeSet
```

Don't make every action behave like chat.

That distinction makes the product feel intelligent.

---

# 11. Review inline

For review:

```text
┌──────────────────────────────────────────────┐
│ ✦ Review                                     │
│                                              │
│ ⚠ Potential null handling issue              │
│                                              │
│ `repository.find()` may return null here.   │
│ The caller currently assumes a valid value. │
│                                              │
│ [Explain] [Fix this]                         │
└──────────────────────────────────────────────┘
```

The **Fix this** button should generate a targeted patch.

---

# 12. Multiple review findings

Don't create five giant panels.

Use markers:

```text
42 │ repository.find(id);
   │ ▲ Possible null handling

51 │ session.getUser();
   │ ▲ Possible lazy-loading issue
```

Then clicking a marker opens the relevant finding.

Model:

```dart
enum FindingSeverity {
  info,
  warning,
  error,
}

class CodeFinding {
  final String id;
  final String filePath;
  final int startLine;
  final int endLine;
  final FindingSeverity severity;
  final String title;
  final String description;

  const CodeFinding({
    required this.id,
    required this.filePath,
    required this.startLine,
    required this.endLine,
    required this.severity,
    required this.title,
    required this.description,
  });
}
```

---

# 13. Editor gutter integration

Your editor should eventually have a unified gutter:

```text
      42 │ repository.find(id);
         │      ▲
      43 │
      44 │ if (session == null) {
         │ ● changed
      45 │   throw ...
         │ ● changed
```

Different markers mean different things:

```text
● changed by Aljabr
▲ review finding
◆ breakpoint
```

Don't overload the same visual marker.

---

# 14. Context menu

Right-click / secondary-click:

```text
┌─────────────────────────────┐
│ Cut                         │
│ Copy                        │
│ Paste                       │
├─────────────────────────────┤
│ ✦ Explain with Aljabr       │
│ ✦ Fix with Aljabr           │
│ ✦ Refactor with Aljabr      │
│ ✦ Generate tests            │
│ ✦ Review selection          │
├─────────────────────────────┤
│ Go to definition            │
│ Find references             │
└─────────────────────────────┘
```

The AI actions should sit naturally alongside existing editor operations.

---

# 15. Keyboard shortcuts

Power users should never need the mouse.

```dart
final editorShortcuts = {
  LogicalKeySet(
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.keyE,
  ): AgentAction.explain,

  LogicalKeySet(
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.keyF,
  ): AgentAction.fix,

  LogicalKeySet(
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.keyR,
  ): AgentAction.review,
};
```

On Windows/Linux map these to `Control`.

Don't hard-code platform assumptions into the command itself.

---

# 16. Command registry

At this point, shortcuts, menus, buttons and command palette shouldn't each implement their own behavior.

Create:

```dart
class EditorCommand {
  final String id;
  final String label;
  final String? shortcut;
  final IconData icon;
  final bool requiresSelection;
  final Future<void> Function() execute;

  const EditorCommand({
    required this.id,
    required this.label,
    this.shortcut,
    required this.icon,
    this.requiresSelection = false,
    required this.execute,
  });
}
```

Then:

```dart
final commands = [
  EditorCommand(
    id: 'ai.explain',
    label: 'Explain with Aljabr',
    shortcut: '⌘E',
    icon: Icons.lightbulb_outline,
    requiresSelection: true,
    execute: explainSelection,
  ),

  EditorCommand(
    id: 'ai.fix',
    label: 'Fix with Aljabr',
    shortcut: '⌘F',
    icon: Icons.build_outlined,
    requiresSelection: true,
    execute: fixSelection,
  ),
];
```

Now:

```text
Command Palette
        │
        ├── keyboard shortcut
        ├── context menu
        ├── toolbar
        └── command button
```

all invoke the **same command**.

This prevents UX drift.

---

# 17. Command palette

Now your `⌘K` / `Ctrl+K` experience can become:

```text
┌─────────────────────────────────────────────┐
│ Search commands...                          │
├─────────────────────────────────────────────┤
│ ✦ Explain selection                 ⌘ E     │
│ ✦ Fix selection                     ⌘ F     │
│ ✦ Review selection                 ⇧⌘ R     │
│ ✦ Generate tests                             │
│                                             │
│ Open file                           ⌘ P     │
│ Find in files                       ⇧⌘ F     │
│ Toggle terminal                     ⌘ `      │
└─────────────────────────────────────────────┘
```

This becomes the central navigation mechanism.

---

# 18. Context-aware commands

Commands should disappear or disable themselves when irrelevant.

No selection:

```text
Explain selection    disabled
Fix selection        disabled
Review selection     disabled
```

With selection:

```text
Explain selection    enabled
Fix selection        enabled
Review selection     enabled
```

During an active patch:

```text
Apply changes
Reject changes
Review changes
```

become available.

This dramatically reduces visual noise.

---

# 19. Context chips

When an AI request originates from code, show its scope in the composer:

```text
┌──────────────────────────────────────────────┐
│ @SessionService.java:42–51                   │
│                                              │
│ Why is this null check necessary?            │
│                                              │
│                              ⌘↵              │
└──────────────────────────────────────────────┘
```

The user can remove the context:

```text
@SessionService.java:42–51  ×
```

or add another:

```text
+ Add context
```

---

# 20. Make context inspectable

Click the chip:

```text
@SessionService.java:42–51
```

and show:

```text
Context

SessionService.java
Lines 42–51

12 lines
Java

[Open in editor]
[Remove]
```

This addresses a major AI UX problem:

> “What exactly is the AI looking at?”

The user should never have to guess.

---

# 21. Don't hide AI scope

For every AI operation, the request should conceptually be:

```text
Prompt
+
Explicit context
+
Implicit context
```

Example:

```text
Explicit:
SessionService.java:42–51

Implicit:
Current project
Language: Java
Active branch
Related test file
```

The UI doesn't need to expose everything, but it should make the important scope visible.

---

# 22. Selection → agent → patch

Now we have a very clean pipeline:

```text
User selects code
       │
       ▼
SelectionToolbar
       │
       ▼
AgentAction
       │
       ▼
AgentRequest
       │
       ▼
Execution
       │
       ▼
Response
       │
       ├──────────────┐
       ▼              ▼
Inline answer     ChangeSet
                      │
                      ▼
                   Diff UI
```

That's the architecture I would keep.

---

# 23. One important polish: preserve selection

When Aljabr opens an inline response, don't destroy the editor selection.

The user should be able to:

```text
select code
   ↓
Ask Aljabr
   ↓
read response
   ↓
continue editing
```

Store:

```dart
class EditorSelectionSnapshot {
  final String filePath;
  final int start;
  final int end;

  const EditorSelectionSnapshot({
    required this.filePath,
    required this.start,
    required this.end,
  });
}
```

When closing the inline panel:

```dart
editor.restoreSelection(snapshot);
```

Tiny detail, but it makes the product feel much more deliberate.

---

# 24. Don't block the editor

While Aljabr is thinking:

```text
Editor: editable
AI panel: loading
```

not:

```text
████████████████████████
Editor locked
Waiting for AI...
████████████████████████
```

The user may realize something else and edit another area.

If the AI-generated patch becomes stale because of that edit, the conflict system we built earlier catches it.

That's the correct architecture.

---

# 25. The editor now feels like this

```text
┌──────────────────────────────────────────────────────────────┐
│ SessionService.java                                  ●      │
├──────────────────────────────────────────────────────────────┤
│ 40 │ public Session getSession(String id) {                  │
│ 41 │                                                          │
│ 42 │   final session = repository.find(id);          ▲       │
│ 43 │                                                          │
│ 44 │   if (session == null) {                         ●       │
│ 45 │     throw new NotFoundException();              ●       │
│ 46 │   }                                                      │
│ 47 │                                                          │
│ 48 │   return session;                                         │
│ 49 │ }                                                        │
│                                                              │
│       ┌──────────────────────────────────────────────┐       │
│       │ ✦ Aljabr                                    │       │
│       │                                              │       │
│       │ Potential null handling issue.               │       │
│       │                                              │       │
│       │ [Fix this] [Explain] [Dismiss]              │       │
│       └──────────────────────────────────────────────┘       │
└──────────────────────────────────────────────────────────────┘
```

That is the direction I'd take.

---

## Next: make the whole workspace feel coherent

We've now built the major functional primitives:

```text
✓ Execution lifecycle
✓ Recovery/reconnect
✓ ChangeSet
✓ Diff/hunk review
✓ Apply/revert
✓ Verification
✓ Editor selection
✓ Inline AI
✓ Context-aware actions
✓ Command registry
```

The next pass should be **workspace-level UX polish**:

```text
┌──────────────┬──────────────────────────┬──────────────┐
│ Explorer     │ Editor / Chat            │ Context      │
│              │                          │              │
│ project      │                          │ files        │
│ sessions     │                          │ symbols      │
│ changes      │                          │ execution    │
│              │                          │ changes      │
├──────────────┴──────────────────────────┴──────────────┤
│ Terminal / Problems / Output / Execution               │
├────────────────────────────────────────────────────────┤
│ Composer                                                │
└────────────────────────────────────────────────────────┘
```

Then implement:

1. **Resizable panels**
2. **Persistent workspace layout**
3. **Tabs**
4. **Editor/chat split modes**
5. **Problems panel**
6. **Terminal integration**
7. **Global search**
8. **Breadcrumb navigation**
9. **Command palette**
10. **Focus management**
11. **Empty states**
12. **Loading/skeleton states**
13. **Toast/notification system**
14. **Undo/redo across AI operations**
15. **Project/session restoration**

That is the next big pass: making all these powerful pieces feel like **one coherent application**, rather than a collection of features.

Next, let’s implement the **workspace shell**. This is where all the pieces we built start feeling like one polished application rather than separate features.

The priorities are:

```text
Workspace
├── persistent layout
├── resizable panels
├── tabs
├── breadcrumbs
├── bottom utility panel
├── focus management
└── restored state
```

---

# 1. Define the workspace layout

Create:

```text
lib/features/workspace/
├── models/
│   ├── workspace_layout.dart
│   ├── workspace_panel.dart
│   └── workspace_tab.dart
├── providers/
│   ├── workspace_provider.dart
│   └── workspace_persistence.dart
└── widgets/
    ├── workspace_shell.dart
    ├── sidebar.dart
    ├── editor_area.dart
    ├── right_panel.dart
    ├── bottom_panel.dart
    ├── workspace_tab_bar.dart
    └── resize_handle.dart
```

---

# 2. Workspace layout model

```dart
enum WorkspacePanel {
  explorer,
  editor,
  context,
  bottom,
}

class WorkspaceLayout {
  final double leftWidth;
  final double rightWidth;
  final double bottomHeight;

  final bool leftVisible;
  final bool rightVisible;
  final bool bottomVisible;

  const WorkspaceLayout({
    this.leftWidth = 260,
    this.rightWidth = 320,
    this.bottomHeight = 240,
    this.leftVisible = true,
    this.rightVisible = true,
    this.bottomVisible = false,
  });

  WorkspaceLayout copyWith({
    double? leftWidth,
    double? rightWidth,
    double? bottomHeight,
    bool? leftVisible,
    bool? rightVisible,
    bool? bottomVisible,
  }) {
    return WorkspaceLayout(
      leftWidth: leftWidth ?? this.leftWidth,
      rightWidth: rightWidth ?? this.rightWidth,
      bottomHeight:
          bottomHeight ?? this.bottomHeight,
      leftVisible:
          leftVisible ?? this.leftVisible,
      rightVisible:
          rightVisible ?? this.rightVisible,
      bottomVisible:
          bottomVisible ?? this.bottomVisible,
    );
  }
}
```

---

# 3. Workspace tabs

The editor needs tabs independent of the file tree.

```dart
enum WorkspaceTabType {
  file,
  diff,
  execution,
  search,
}

class WorkspaceTab {
  final String id;
  final String title;
  final WorkspaceTabType type;
  final String? path;
  final bool dirty;
  final bool pinned;

  const WorkspaceTab({
    required this.id,
    required this.title,
    required this.type,
    this.path,
    this.dirty = false,
    this.pinned = false,
  });

  WorkspaceTab copyWith({
    String? title,
    bool? dirty,
    bool? pinned,
  }) {
    return WorkspaceTab(
      id: id,
      title: title ?? this.title,
      type: type,
      path: path,
      dirty: dirty ?? this.dirty,
      pinned: pinned ?? this.pinned,
    );
  }
}
```

---

# 4. Workspace state

```dart
class WorkspaceState {
  final WorkspaceLayout layout;
  final List<WorkspaceTab> tabs;
  final String? activeTabId;

  const WorkspaceState({
    this.layout = const WorkspaceLayout(),
    this.tabs = const [],
    this.activeTabId,
  });

  WorkspaceTab? get activeTab {
    for (final tab in tabs) {
      if (tab.id == activeTabId) {
        return tab;
      }
    }

    return null;
  }

  WorkspaceState copyWith({
    WorkspaceLayout? layout,
    List<WorkspaceTab>? tabs,
    String? activeTabId,
  }) {
    return WorkspaceState(
      layout: layout ?? this.layout,
      tabs: tabs ?? this.tabs,
      activeTabId:
          activeTabId ?? this.activeTabId,
    );
  }
}
```

---

# 5. Workspace notifier

```dart
class WorkspaceNotifier
    extends StateNotifier<WorkspaceState> {
  WorkspaceNotifier()
      : super(const WorkspaceState());

  void setLayout(
    WorkspaceLayout layout,
  ) {
    state = state.copyWith(
      layout: layout,
    );
  }

  void toggleLeft() {
    state = state.copyWith(
      layout: state.layout.copyWith(
        leftVisible:
            !state.layout.leftVisible,
      ),
    );
  }

  void toggleRight() {
    state = state.copyWith(
      layout: state.layout.copyWith(
        rightVisible:
            !state.layout.rightVisible,
      ),
    );
  }

  void toggleBottom() {
    state = state.copyWith(
      layout: state.layout.copyWith(
        bottomVisible:
            !state.layout.bottomVisible,
      ),
    );
  }

  void resizeLeft(double width) {
    state = state.copyWith(
      layout: state.layout.copyWith(
        leftWidth:
            width.clamp(180, 480),
      ),
    );
  }

  void resizeRight(double width) {
    state = state.copyWith(
      layout: state.layout.copyWith(
        rightWidth:
            width.clamp(240, 520),
      ),
    );
  }

  void resizeBottom(double height) {
    state = state.copyWith(
      layout: state.layout.copyWith(
        bottomHeight:
            height.clamp(120, 500),
      ),
    );
  }
}
```

Provider:

```dart
final workspaceProvider =
    StateNotifierProvider<
        WorkspaceNotifier,
        WorkspaceState>(
  (_) => WorkspaceNotifier(),
);
```

---

# 6. The actual shell

Now create the central composition:

```dart
class WorkspaceShell extends ConsumerWidget {
  const WorkspaceShell({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workspace =
        ref.watch(workspaceProvider);

    final layout =
        workspace.layout;

    return Scaffold(
      body: Column(
        children: [
          const WorkspaceHeader(),

          Expanded(
            child: Row(
              children: [
                if (layout.leftVisible)
                  SizedBox(
                    width: layout.leftWidth,
                    child: const ExplorerPanel(),
                  ),

                if (layout.leftVisible)
                  ResizeHandle(
                    onDrag: (delta) {
                      ref
                          .read(
                            workspaceProvider
                                .notifier,
                          )
                          .resizeLeft(
                            layout.leftWidth +
                                delta,
                          );
                    },
                  ),

                Expanded(
                  child: Column(
                    children: [
                      const WorkspaceTabBar(),

                      Expanded(
                        child:
                            const EditorArea(),
                      ),

                      if (layout.bottomVisible)
                        SizedBox(
                          height:
                              layout.bottomHeight,
                          child:
                              const BottomPanel(),
                        ),
                    ],
                  ),
                ),

                if (layout.rightVisible)
                  ResizeHandle(
                    onDrag: (delta) {
                      ref
                          .read(
                            workspaceProvider
                                .notifier,
                          )
                          .resizeRight(
                            layout.rightWidth -
                                delta,
                          );
                    },
                  ),

                if (layout.rightVisible)
                  SizedBox(
                    width: layout.rightWidth,
                    child:
                        const ContextPanel(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

# 7. Resize handle

Don't use a giant visible divider.

Use a subtle hit area:

```dart
class ResizeHandle extends StatelessWidget {
  const ResizeHandle({
    super.key,
    required this.onDrag,
  });

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior:
            HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          onDrag(details.delta.dx);
        },
        child: const SizedBox(
          width: 6,
          child: Center(
            child: SizedBox(
              width: 1,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
```

The divider should become slightly more visible on hover.

---

# 8. Tabs

The tab bar should support:

```text
┌─────────────────────────────────────────────────────────────┐
│ SessionService.java × │ SessionTest.java × │ Diff ×        │
└─────────────────────────────────────────────────────────────┘
```

Implement:

```dart
class WorkspaceTabBar
    extends ConsumerWidget {
  const WorkspaceTabBar({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workspace =
        ref.watch(workspaceProvider);

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection:
            Axis.horizontal,
        itemCount:
            workspace.tabs.length,
        itemBuilder: (_, index) {
          final tab =
              workspace.tabs[index];

          return WorkspaceTabItem(
            tab: tab,
            active:
                tab.id ==
                workspace.activeTabId,
          );
        },
      ),
    );
  }
}
```

---

# 9. Active tab

```dart
class WorkspaceTabItem
    extends ConsumerWidget {
  const WorkspaceTabItem({
    super.key,
    required this.tab,
    required this.active,
  });

  final WorkspaceTab tab;
  final bool active;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return InkWell(
      onTap: () {
        // Activate tab.
      },
      child: Container(
        constraints:
            const BoxConstraints(
          minWidth: 120,
          maxWidth: 220,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Row(
          children: [
            _TabIcon(type: tab.type),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                tab.title,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),

            if (tab.dirty)
              const Padding(
                padding:
                    EdgeInsets.only(right: 4),
                child: Text('•'),
              ),

            if (!tab.pinned)
              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
                icon: const Icon(
                  Icons.close,
                  size: 15,
                ),
                onPressed: () {
                  // Close tab.
                },
              ),
          ],
        ),
      ),
    );
  }
}
```

---

# 10. Don't duplicate tabs

Opening:

```text
SessionService.java
```

five times should still produce:

```text
SessionService.java
```

once.

```dart
void openFile(String path) {
  final existing = state.tabs
      .where((tab) => tab.path == path)
      .firstOrNull;

  if (existing != null) {
    state = state.copyWith(
      activeTabId: existing.id,
    );
    return;
  }

  final tab = WorkspaceTab(
    id: 'file:$path',
    title: basename(path),
    type: WorkspaceTabType.file,
    path: path,
  );

  state = state.copyWith(
    tabs: [
      ...state.tabs,
      tab,
    ],
    activeTabId: tab.id,
  );
}
```

This is a small feature that makes a big difference.

---

# 11. Dirty state

If the user edits a file:

```text
SessionService.java •
```

The dot means unsaved.

When saved:

```text
SessionService.java
```

When an AI change is pending:

```text
SessionService.java  ✦
```

Don't reuse the same indicator for different states.

I'd use:

```text
•   local unsaved changes
✦   AI-proposed changes
●   active execution/change
```

---

# 12. Breadcrumbs

Above the editor:

```text
src / main / java / com / wayang / SessionService.java
```

Then symbols:

```text
SessionService.java
  › getSession()
  › validateSession()
```

Model:

```dart
class EditorBreadcrumb {
  final String label;
  final String? path;
  final int? line;

  const EditorBreadcrumb({
    required this.label,
    this.path,
    this.line,
  });
}
```

This makes navigating large projects much easier.

---

# 13. Editor header

Compose:

```text
┌──────────────────────────────────────────────────────────┐
│ SessionService.java   Java    main                       │
│ src/main/java/... > SessionService > getSession()        │
└──────────────────────────────────────────────────────────┘
```

Don't waste vertical space.

Keep it around 64–72px total.

---

# 14. Bottom panel

The bottom panel should become a unified utility area:

```text
┌──────────────────────────────────────────────────────────┐
│ Problems  Terminal  Output  Tests  Execution              │
├──────────────────────────────────────────────────────────┤
│ ✓ 128 tests passed                                       │
│ ⚠ 1 warning                                             │
└──────────────────────────────────────────────────────────┘
```

Not separate floating windows everywhere.

---

# 15. Bottom panel state

```dart
enum BottomPanelTab {
  problems,
  terminal,
  output,
  tests,
  execution,
}

class BottomPanelState {
  final bool visible;
  final BottomPanelTab activeTab;

  const BottomPanelState({
    this.visible = false,
    this.activeTab =
        BottomPanelTab.problems,
  });
}
```

---

# 16. Problems panel

Create:

```dart
enum ProblemSeverity {
  error,
  warning,
  info,
}

class Problem {
  final String id;
  final String filePath;
  final int line;
  final int column;
  final ProblemSeverity severity;
  final String message;

  const Problem({
    required this.id,
    required this.filePath,
    required this.line,
    required this.column,
    required this.severity,
    required this.message,
  });
}
```

UI:

```text
Problems · 3

ERROR   SessionService.java:42
        Possible null reference

WARNING AuthController.java:81
        Deprecated API

INFO    SessionTest.java:22
        Test can be simplified
```

Clicking a problem:

```text
→ opens file
→ jumps to line
→ highlights range
```

---

# 17. Tests panel

After verification:

```text
Tests

✓ SessionResourceTest
✓ SessionServiceTest
✓ AuthenticationTest
✕ SessionControllerTest

3 passed
1 failed

[Run failed tests]
[Ask Aljabr to fix]
```

That button should automatically create a structured agent request using:

```text
failed test
stack trace
changed files
test file
relevant implementation
```

---

# 18. Terminal panel

The terminal should not compete with chat.

Use:

```text
Terminal  Output  Tests  Problems
```

and allow multiple terminal sessions:

```text
Terminal
├── bash
├── tests
└── server
```

Model:

```dart
class TerminalSession {
  final String id;
  final String title;
  final String shell;
  final bool running;

  const TerminalSession({
    required this.id,
    required this.title,
    required this.shell,
    this.running = false,
  });
}
```

---

# 19. Right-side context panel

Now connect everything we've built:

```text
Context

FILES
3
  SessionService.java
  SessionTest.java
  AuthController.java

SELECTION
SessionService.java
Lines 42–51

CHANGES
3 files
+42 -17

EXECUTION
Running tests
12.8s

MEMORY
Project conventions
2 items
```

This is powerful because the user can understand:

> What is Aljabr currently using?

without opening multiple windows.

---

# 20. Context sections should collapse

Don't show everything expanded.

Default:

```text
Context

▾ Files                 3
▸ Selection
▸ Changes               3
▸ Execution
▸ Memory
```

When something becomes important, automatically expand it.

For example, while reviewing:

```text
▾ Changes                3
```

During execution:

```text
▾ Execution
  Running tests
```

---

# 21. Persistent layout

Save:

```dart
class WorkspacePreferences {
  final WorkspaceLayout layout;
  final List<String> openTabs;
  final String? activeTab;
  final BottomPanelTab? bottomTab;

  const WorkspacePreferences({
    required this.layout,
    required this.openTabs,
    this.activeTab,
    this.bottomTab,
  });
}
```

Persist after meaningful changes:

```dart
void persistWorkspace(
  WorkspaceState state,
) {
  preferences.save(
    WorkspacePreferences(
      layout: state.layout,
      openTabs:
          state.tabs.map(
            (tab) => tab.id,
          ).toList(),
      activeTab:
          state.activeTabId,
    ),
  );
}
```

Don't write to storage on every pixel of a resize.

Debounce it.

---

# 22. Restore workspace

On project open:

```dart
Future<void> restoreWorkspace() async {
  final preferences =
      await workspaceStore.load();

  if (preferences == null) {
    return;
  }

  restoreLayout(
    preferences.layout,
  );

  restoreTabs(
    preferences.openTabs,
  );

  activateTab(
    preferences.activeTab,
  );
}
```

The user's workspace should feel persistent.

---

# 23. Focus management

This is one of the most overlooked UX details.

Define:

```dart
enum WorkspaceFocus {
  explorer,
  editor,
  terminal,
  composer,
  search,
  commandPalette,
}
```

Provider:

```dart
final workspaceFocusProvider =
    StateProvider<WorkspaceFocus>(
  (_) => WorkspaceFocus.editor,
);
```

Now shortcuts know where they belong.

---

# 24. Focus shortcuts

Examples:

```text
⌘1    Explorer
⌘2    Editor
⌘3    Context
⌘J    Bottom panel
⌘K    Command palette
⌘P    Quick open
⌘L    Composer
Esc   Clear transient UI
```

Centralize these.

Do not let individual widgets fight over keyboard events.

---

# 25. Global command handler

```dart
class WorkspaceCommandHandler {
  bool handle(
    KeyEvent event,
    BuildContext context,
  ) {
    if (event is! KeyDownEvent) {
      return false;
    }

    if (_isCommandPalette(event)) {
      openCommandPalette();
      return true;
    }

    if (_isQuickOpen(event)) {
      openQuickOpen();
      return true;
    }

    if (_isBottomPanel(event)) {
      toggleBottomPanel();
      return true;
    }

    return false;
  }
}
```

This should sit near the workspace root.

---

# 26. Quick Open

`⌘P` should be more than "open file".

Search:

```text
┌──────────────────────────────────────────────┐
│ Search files, symbols, commands...           │
├──────────────────────────────────────────────┤
│ SessionService.java                          │
│ SessionResource.java                         │
│ SessionServiceTest.java                      │
│                                              │
│ Symbols                                      │
│ getSession()                                 │
│ validateSession()                            │
└──────────────────────────────────────────────┘
```

Eventually it can search:

```text
files
symbols
commands
sessions
changes
```

---

# 27. Empty states

Avoid:

```text
No files
```

Instead:

```text
No file open

Open a file from the Explorer,
or press ⌘P to search.

[Open file]
```

For no context:

```text
No context selected

Select a file or code range to give
Aljabr more precise context.
```

For no changes:

```text
No pending changes

Changes proposed by Aljabr will
appear here for review.
```

Empty states should teach the workflow.

---

# 28. Loading states

Avoid giant spinners.

Bad:

```text
Loading...
```

Better:

```text
Reading SessionService.java
```

Then:

```text
Analyzing authentication flow
```

Then:

```text
Preparing changes
```

This reuses the execution state we already built.

---

# 29. Notifications

Create a centralized notification service:

```dart
enum NotificationType {
  info,
  success,
  warning,
  error,
}

class AppNotification {
  final NotificationType type;
  final String title;
  final String? message;
  final Duration duration;

  const AppNotification({
    required this.type,
    required this.title,
    this.message,
    this.duration =
        const Duration(seconds: 4),
  });
}
```

Use it for:

```text
✓ Changes applied
✓ Tests passed
⚠ 3 tests failed
✕ Could not connect
```

But avoid notifications for things already visible in the active UI.

---

# 30. Undo should be global

A major polish point:

If Aljabr applies a change:

```text
⌘Z
```

should undo that change when appropriate.

Don't create a second unrelated "AI undo" system.

Instead, integrate AI operations into the workspace undo stack:

```dart
abstract class WorkspaceOperation {
  Future<void> apply();
  Future<void> undo();
}
```

Example:

```dart
class ApplyChangeOperation
    implements WorkspaceOperation {
  final ChangeSet changeSet;

  ApplyChangeOperation(
    this.changeSet,
  );

  @override
  Future<void> apply() async {
    // Apply changes.
  }

  @override
  Future<void> undo() async {
    // Revert only this change set.
  }
}
```

Now:

```text
User edit
   ↓
AI edit
   ↓
format
   ↓
AI edit
```

can eventually participate in a coherent history.

---

# 31. The resulting shell

We now have:

```text
┌──────────────────────────────────────────────────────────────────┐
│ Project    Branch       Search                  ⌘K   Account     │
├──────────────┬──────────────────────────────────────┬────────────┤
│              │ Tabs                                 │            │
│ Explorer     ├──────────────────────────────────────┤ Context    │
│              │ Breadcrumbs                           │            │
│ Files        │                                      │ Files      │
│ Sessions     │              Editor                  │ Selection  │
│ Changes      │                                      │ Changes    │
│              │                                      │ Execution  │
│              │                                      │            │
├──────────────┴──────────────────────────────────────┴────────────┤
│ Problems  Terminal  Output  Tests  Execution                    │
├─────────────────────────────────────────────────────────────────┤
│ @context  Ask Aljabr...                              ⌘↵        │
└─────────────────────────────────────────────────────────────────┘
```

At this point, the product architecture is becoming coherent.

---

## Next pass: interaction polish

Now we should stop adding major panels and make the existing ones **feel excellent**.

The next implementation pass should cover:

```text
1. Motion system
2. Hover states
3. Keyboard navigation
4. Command palette ranking
5. Drag/drop files
6. Multi-select context
7. Context chips
8. Smart composer
9. Streaming markdown
10. Code block actions
11. Toast behavior
12. Modal behavior
13. Confirmation patterns
14. Accessibility
15. Responsive collapse
```

The biggest one is the **smart composer**, because it is the primary interaction surface with Aljabr. We should make it behave more like a professional IDE command bar than a conventional chat textbox.
