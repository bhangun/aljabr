Yes. I reviewed the GUI architecture together with the Aljabr API/engine and the underlying Wayang runtime. The biggest opportunity is **not adding more features**; it is making the existing capabilities feel like one coherent coding-agent workspace.

The current GUI already has the right foundation: projects, sessions, persistent transcripts, forking, pinning, Riverpod state management, tool calls, approvals, settings, keyboard shortcuts, and a three-column IDE layout.

## My priority order

### 1. Make the main workspace feel like an IDE, not a chat app

You already have:

**Sidebar → Chat → Editor**

from `IdeHomeScreen`. 

I would polish this into a very deliberate hierarchy:

```text
┌─────────────────────────────────────────────────────────────────────┐
│  Aljabr   Project: Wayang ▾     ● Connected     model ▾   ⚙        │
├────────────┬──────────────────────────────────┬─────────────────────┤
│            │                                  │                     │
│ PROJECT    │  Session: Fix Hibernate mapping  │  EXPLORER           │
│            │                                  │                     │
│ + New      │  user                            │  src/                │
│            │  Fix the Hibernate mapping...    │   main/              │
│ Sessions   │                                  │   test/              │
│ ─────────  │  agent                           │                     │
│ ● Fix DB   │  I'll inspect the mapping...     │  ─────────────────  │
│ ○ API      │                                  │  SessionResource... │
│ ○ Auth     │                                  │                     │
│            │  ┌─ Tool execution ──────────┐   │                     │
│            │  │ ✓ grep ...                 │   │                     │
│            │  │ ✓ mvnw test                │   │                     │
│            │  └────────────────────────────┘   │                     │
│            │                                  │                     │
│            │                                  │                     │
│            │  ┌────────────────────────────┐  │                     │
│            │  │ Ask Aljabr...          ↑   │  │                     │
│            │  └────────────────────────────┘  │                     │
└────────────┴──────────────────────────────────┴─────────────────────┘
```

The key is **visual hierarchy**:

* project context at the top
* session context immediately below
* conversation as the primary surface
* execution/tool activity visually subordinate
* editor/files available without competing with the conversation

---

# 2. The biggest UX improvement: make agent execution understandable

This is especially important because Aljabr isn't merely an LLM chat wrapper.

The runtime has concepts such as:

* planning
* tool execution
* approval
* pause/resume
* cancellation
* verification
* patches
* execution risk
* diagnostics
* artifacts
* hypotheses/debugging
* resource limits

For example, the runtime explicitly supports pausing, resuming and cancelling executions. 

And the engine has explicit execution states such as `SUCCESS`, `FAILED`, `TIMED_OUT`, and `CANCELLED`. 

**The UI should expose this model.**

Instead of:

> Agent is thinking...

show:

```text
● Working

Plan
✓ Inspect Hibernate mapping
✓ Locate SessionResource tests
● Run targeted tests
○ Apply fix
○ Verify full test suite
```

Then when something needs permission:

```text
┌───────────────────────────────────────────────────┐
│  Permission required                              │
│                                                   │
│  Run terminal command                             │
│                                                   │
│  ./mvnw test -Dtest=SessionResourceTest           │
│                                                   │
│  Risk: SAFE                                      │
│                                                   │
│       Deny             Allow once     Always allow │
└───────────────────────────────────────────────────┘
```

This would make Aljabr feel significantly more trustworthy.

---

# 3. Tool calls should become first-class UX components

Your current UI already has tool-call models and renders execution details. The agent message also exposes actions such as Copy, Fork, Helpful, Unhelpful and Metrics. 

I would make tool calls much more polished.

### Collapsed

```text
✓ Run command                         11s
  ./mvnw test -Dtest=SessionResourceTest
```

### Expanded

```text
✓ Run command                                    11.2s

COMMAND
./mvnw test -Dtest=SessionResourceTest

OUTPUT
──────────────────────────────────────────────────
Tests run: 6, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS

[Copy output]                         [Open terminal]
```

Different tool types should have different visual treatments:

| Tool      | UI                     |
| --------- | ---------------------- |
| Terminal  | terminal card          |
| File read | file card              |
| File edit | diff card              |
| Search    | search result card     |
| Test      | test summary           |
| Browser   | browser preview        |
| MCP       | integration/tool badge |
| Approval  | permission card        |
| Artifact  | artifact card          |

This becomes particularly valuable because the engine already models execution results, diagnostics and artifacts. 

---

# 4. Introduce a real "Run Timeline"

This is probably the single feature I would add before doing lots of visual tweaking.

Instead of showing a flat transcript:

```text
User
Agent
Tool
Agent
Tool
Agent
```

give the user an optional execution timeline:

```text
RUN #1842                              1m 42s

✓ Understand request                   1.2s
✓ Search workspace                     0.8s
✓ Inspect SessionResource.java        2.1s
✓ Inspect Hibernate mapping            1.4s
✓ Create change plan                   0.6s
✓ Apply patch                          0.4s
✓ Run tests                           34.2s
✓ Verify result                        2.3s

RESULT
6 tests passed
2 files changed
0 diagnostics

[View changes] [View tests] [View execution]
```

That would align extremely well with the engine's execution-oriented architecture.

---

# 5. Make changes/diffs a primary UX

The engine has explicit patch concepts:

* `ChangePlan`
* `PatchProposal`
* `PatchOperation`
* `PatchEdit`
* `PatchValidationResult`
* `AppliedPatch`

and tracks repository snapshots.

The GUI should therefore not make code changes feel like invisible magic.

After an agent modifies code, show:

```text
2 files changed

M  src/main/java/.../SessionResource.java
M  src/test/java/.../SessionResourceTest.java

────────────────────────────────────────

+ @Column(...)
+ private String sessionId;

────────────────────────────────────────

[Review changes]     [Revert]     [Keep]
```

And ideally:

**Review changes**

opens a proper GitHub/VS Code-style diff viewer.

This will make Aljabr feel dramatically more professional.

---

# 6. Add a persistent run-status bar

Your connection provider already distinguishes:

* connecting
* connected
* reconnecting
* offline. 

Don't hide this in settings.

Put a tiny status indicator in the top bar:

```text
● Connected
```

Clicking it:

```text
Backend
────────────────────
● Connected

Protocol
gRPC

Agent
Coder

Model
Gemma 4 12B

Workspace
~/Workspace/Wayang

Latency
42 ms
```

When disconnected:

```text
⚠ Offline

Messages will be queued locally.
Reconnect automatically
```

This is much better UX than making connectivity feel mysterious.

---

# 7. Don't expose gRPC/REST as a normal user decision

Your GUI currently has a `BackendProtocol` switch between gRPC and REST. 

That's useful for development, but I would **hide it from normal users**.

Instead:

**Settings → Advanced → Transport**

```text
Transport
● Automatic

Fallback
REST

Diagnostics
[Copy connection diagnostics]
```

Most users should never have to understand the transport mechanism.

---

# 8. Improve the composer dramatically

The message composer should become the command center.

Instead of just:

```text
Ask Aljabr...
```

use:

```text
┌─────────────────────────────────────────────────────┐
│ Ask Aljabr to modify this project...                │
│                                                     │
│                                                     │
│  ＋ Attach   @ Context   / Commands      Model ▾    │
│                                      [↑ Send]        │
└─────────────────────────────────────────────────────┘
```

Useful affordances:

* `/test`
* `/review`
* `/fix`
* `/explain`
* `/search`
* `/run`
* `/commit`
* `/plan`

And context shortcuts:

```text
@file
@folder
@selection
@test
@session
```

The backend already understands projects, sessions, workspace paths, providers/models and attachments, so this isn't an arbitrary UX abstraction. 

---

# 9. Add "Plan before execution"

The engine already has a `ChangePlan` abstraction and risk information. 

Expose that.

For a complicated request:

```text
I'll make these changes:

PLAN

1. Inspect SessionResource persistence
2. Update Hibernate mapping
3. Add regression test
4. Run targeted tests
5. Run verification

Risk: LOW

[Execute plan]    [Edit plan]
```

For simple requests, skip it.

This gives users a **sense of control without forcing them through bureaucracy**.

---

# 10. Risk should be visible before dangerous actions

The engine explicitly models:

```text
SAFE
MODERATE
HIGH
```

for execution risk. 

Use that directly.

For example:

```text
RUN COMMAND

npm install

Risk
LOW

Workspace access
Current project

Network
Required

[Cancel]                         [Allow]
```

For something more dangerous:

```text
⚠ HIGH RISK

rm -rf build/

This command will permanently delete files.

[Cancel]        [Review command]        [Allow]
```

That is much better than generic "Are you sure?"

---

# 11. Settings need a serious UX cleanup

Your settings model is currently very broad: appearance, notifications, privacy/telemetry, security, sandboxing, browser automation, artifact review, etc.

The danger is creating a giant "control panel."

I would restructure:

### General

* Appearance
* Font
* Conversation width
* Keyboard shortcuts

### Agent

* Default model
* Behavior
* Verbosity
* Memory

### Permissions

* Terminal
* Files
* Outside workspace
* Browser
* Artifact review
* Sandbox

### Workspace

* Default project
* Workspace path
* Auto-save

### Notifications

* Desktop
* Sound
* Completion
* Errors

### Privacy

* Telemetry
* Analytics
* Crash reports

### Advanced

* Backend
* Transport
* Logs
* Experimental features

This makes the settings architecture much easier to understand.

---

# 12. Replace "settings values" that don't actually persist

One important issue I noticed from the GUI source: several settings widgets appear to have placeholder callbacks such as:

```dart
onChanged: (v) {},
```

The browser and security settings shown in the source have this pattern. 

That creates a particularly bad UX:

> UI says something changed → application does nothing.

Before adding more settings, make every visible control follow:

```text
UI
 ↓
Riverpod state
 ↓
Persistent settings
 ↓
Backend/runtime if required
 ↓
UI confirmation
```

For example:

```text
Sandbox Mode
● Enabled

Saved automatically
```

or:

```text
Sandbox Mode
● Enabled

Saving...
```

then:

```text
✓ Saved
```

---

# 13. Use optimistic UI carefully

For things like:

* pin session
* rename session
* archive session
* theme
* conversation width

change the UI immediately and persist asynchronously.

For dangerous operations:

* delete session
* discard changes
* revert patch
* cancel execution

use confirmation/undo.

For deletion I'd actually prefer:

```text
Session archived

                 Undo
```

rather than a confirmation dialog every time.

You already have archiving and pinning concepts in the application. 

---

# 14. Session sidebar needs better information density

Instead of:

```text
Fix Hibernate
API work
Authentication
```

show:

```text
TODAY

● Fix Hibernate mapping
  2 files · 6 tests · 4m ago

○ API pagination
  8 messages · yesterday

○ Authentication
  23 messages · Aug 14

PINNED
★ Architecture review
```

Session metadata already includes things such as message count, pending count, queue size, duration and file changes. 

Use that information selectively.

Don't show everything.

---

# 15. Improve empty states

Avoid:

> No sessions.

Instead:

```text
No sessions yet

Start a coding session with your project.

        [Start new session]
```

For a new project:

```text
Welcome to Wayang

This workspace hasn't been indexed yet.

Indexing allows Aljabr to understand:
• files
• symbols
• references
• dependencies

[Index workspace]
```

This is particularly appropriate because the engine has explicit indexing/reference concepts. 

---

# 16. Make errors actionable

Current API errors can essentially surface as:

```text
API error 500: ...
```

That's developer-friendly but poor UX.

Transform them into:

```text
Couldn't connect to Aljabr

The agent backend didn't respond within 15 seconds.

Possible causes:
• backend isn't running
• workspace service unavailable
• network connection interrupted

[Retry]     [Connection diagnostics]
```

For execution:

```text
Command failed

./mvnw test -Dtest=SessionResourceTest

Exit code: 1

1 test failed

[View output] [Open failing test] [Ask Aljabr to fix]
```

The engine already exposes diagnostics and execution status, so the GUI can provide much better explanations. 

---

# 17. Streaming should feel alive

The backend supports streaming agent execution. 

Use it visually.

Instead of waiting for the complete answer:

```text
I'll inspect the mapping and...
```

show:

```text
I'll inspect the mapping and
compare it with the failing test...

● Searching SessionResource.java
```

Then progressively reveal:

```text
● Searching...
✓ Found 4 references

● Inspecting Hibernate mapping...
✓ Found mismatch

● Planning fix...
```

The user should always know **something is happening**.

---

# 18. Add a compact "Agent status" header

Something like:

```text
CODER
● Working

Gemma 4 12B
Balanced
Sandboxed
```

Click:

```text
Agent configuration

Agent
Coder

Model
Gemma 4 12B

Behavior
Balanced

Sandbox
Enabled

Memory
Enabled

Tools
12 available
```

The underlying runtime already has agents, skills, tools and execution pipelines as first-class concepts. 

---

# 19. Keyboard UX is already a strength — lean into it

You already have shortcuts for navigation, send, new line, search, export, pause/resume/cancel, zoom and sidebar toggle. 

Make them discoverable.

A small:

```text
⌘K
```

command palette would be excellent:

```text
┌────────────────────────────────────────────┐
│ Search commands...                         │
├────────────────────────────────────────────┤
│ Run tests                                  │
│ Search workspace                           │
│ Fork session                               │
│ Pause agent                                │
│ Resume agent                               │
│ Open command palette                       │
│ Toggle sidebar                              │
│ Export session                              │
└────────────────────────────────────────────┘
```

This would make the application feel much more like a professional developer tool.

---

# 20. Visual polish: establish a design system

I'd standardize:

### Spacing

Use a strict 4/8 px rhythm:

```text
4
8
12
16
24
32
48
```

### Radius

Avoid many different corner radii.

Something like:

* controls: 6px
* cards: 8px
* dialogs: 12px

### Typography

Three levels are enough:

```text
Title       18–20
Body        14–15
Metadata    12–13
```

### Color

Keep the dark UI restrained.

Use accent color primarily for:

* active state
* primary action
* selection
* progress

Don't color every tool card differently.

Use semantic colors only for:

```text
success
warning
error
info
```

---

# 21. Reduce visual noise in chat

The current agent action row has Copy, Fork, Helpful, Unhelpful and Metrics. 

That's useful, but showing all of them under every message creates noise.

Instead:

```text
Agent response
──────────────────────────────

...response...

             ⋯
```

Hover:

```text
Copy   Fork   Like   Dislike   Metrics
```

Keep the conversation itself clean.

---

# 22. Make the editor context-aware

If Aljabr says:

> I found the issue in `SessionResource.java:142`.

the UI should make that clickable:

```text
SessionResource.java:142
```

Click → editor opens exactly there.

Similarly:

```text
6 tests passed
```

Click → test panel.

```text
2 files changed
```

Click → diff.

This is where Aljabr can differentiate itself from generic AI chat.

---

# 23. Add a bottom "Changes / Tests / Terminal" drawer

Rather than permanently consuming editor space:

```text
┌──────────────────────────────────────────┐
│ Changes (2) │ Tests (6 ✓) │ Terminal    │
├──────────────────────────────────────────┤
│                                          │
│               editor                     │
│                                          │
├──────────────────────────────────────────┤
│ Changes (2)                         ^    │
└──────────────────────────────────────────┘
```

Collapsed by default.

Open only when needed.

---

# 24. The most important architectural UX improvement

I would introduce a single frontend abstraction:

```text
ExecutionViewModel
```

containing something like:

```text
Execution
 ├── status
 ├── phase
 ├── progress
 ├── plan
 ├── toolCalls[]
 ├── approvals[]
 ├── changes[]
 ├── diagnostics[]
 ├── artifacts[]
 ├── tests[]
 ├── duration
 └── error
```

Then all UI surfaces consume that same model:

```text
Chat
  ↓
ExecutionViewModel
  ├── Timeline
  ├── Tool cards
  ├── Approval cards
  ├── Diff
  ├── Test results
  ├── Status bar
  └── Notifications
```

This is important because your backend/runtime already has a rich execution model, while the GUI currently appears to treat many things primarily as `ChatEntry` objects.

That is the fundamental UX gap.

---

# What I would build first

If the goal is **"make Aljabr feel polished"**, I would do it in this sequence:

### Phase 1 — Immediate polish

1. Refine spacing/typography/radii
2. Simplify chat message actions
3. Improve sidebar
4. Improve composer
5. Improve loading/error/empty states
6. Add connection indicator
7. Add command palette

### Phase 2 — Agent UX

8. Execution timeline
9. Rich tool-call cards
10. Approval cards
11. Plan preview
12. Risk indicators
13. Streaming status
14. Pause/resume/cancel controls

### Phase 3 — Coding UX

15. Proper diff viewer
16. Changes drawer
17. Test result panel
18. Clickable file/line references
19. Terminal output panel
20. Artifact viewer

### Phase 4 — Advanced Aljabr UX

21. Execution history
22. Memory/context visibility
23. Agent/skill/tool inspector
24. Debug/hypothesis visualization
25. Provenance/evidence view
26. Resource/runtime diagnostics

The engine is already developing concepts such as hypotheses, evidence, repair plans, change plans, verification and execution risk.  **Those should eventually become visible UX primitives rather than remaining invisible backend machinery.**

## The design direction I'd recommend

Don't aim for **"better ChatGPT UI."**

Aim for:

> **VS Code + agent control center + execution debugger.**

The user's mental model should be:

**Project → Task → Plan → Agent execution → Tool activity → Changes → Verification → Result**

rather than:

**Prompt → Chat response**

That distinction is, in my view, the biggest UX opportunity in the current Aljabr GUI.


Yes. I would turn the UX recommendations into a **concrete Flutter implementation plan**, using the structures that already exist in your GUI rather than introducing an entirely new architecture.

The important point is that your GUI already has much of the required domain model: `ChatEntry` can carry `toolCall`, `approval`, `plan`, errors, job IDs and queue position; sessions already track changes, pending work, queue size and duration.

So I would implement this incrementally.

---

# 1. First: introduce an execution-oriented UI model

Right now the UI is heavily transcript-oriented. The backend/runtime, however, is execution-oriented: the Wayang agent emits agent start/thought/tool start/tool result/end/error events, while the runtime has approval, policy, guardrail, retry and timeout stages.

Create:

```text
lib/features/execution/
├── models/
│   ├── execution_view_model.dart
│   ├── execution_phase.dart
│   ├── execution_step.dart
│   └── execution_status.dart
├── providers/
│   └── execution_provider.dart
└── widgets/
    ├── execution_timeline.dart
    ├── execution_step_tile.dart
    └── execution_status_header.dart
```

### `execution_status.dart`

```dart
enum ExecutionStatus {
  idle,
  planning,
  running,
  waitingForApproval,
  verifying,
  completed,
  failed,
  cancelled,
  paused,
}
```

### `execution_phase.dart`

```dart
enum ExecutionPhase {
  understand,
  inspect,
  analyze,
  modify,
  test,
  verify,
  repair,
}
```

These map naturally to the engine's existing plan step types: `OBSERVE`, `INSPECT`, `ANALYZE`, `MODIFY`, `TEST`, `VERIFY`, and `REPAIR`. 

---

# 2. `ExecutionStep`

```dart
class ExecutionStep {
  final String id;
  final String title;
  final ExecutionPhase phase;
  final ExecutionStatus status;

  final String? detail;
  final Duration? duration;

  final RiskLevel? risk;

  const ExecutionStep({
    required this.id,
    required this.title,
    required this.phase,
    required this.status,
    this.detail,
    this.duration,
    this.risk,
  });

  ExecutionStep copyWith({
    ExecutionStatus? status,
    String? detail,
    Duration? duration,
  }) {
    return ExecutionStep(
      id: id,
      title: title,
      phase: phase,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      duration: duration ?? this.duration,
      risk: risk,
    );
  }
}
```

Your GUI already has a `RiskLevel` with Safe/Caution/Dangerous semantics. 

I would eventually reconcile that UI enum with the engine's `LOW/MEDIUM/HIGH/CRITICAL` risk model rather than maintaining two unrelated concepts. The engine currently defines those four levels. 

---

# 3. Execution state

```dart
class ExecutionViewModel {
  final String sessionId;

  final ExecutionStatus status;
  final ExecutionPhase? phase;

  final List<ExecutionStep> steps;

  final int filesChanged;
  final int testsPassed;
  final int testsFailed;

  final String? error;

  const ExecutionViewModel({
    required this.sessionId,
    this.status = ExecutionStatus.idle,
    this.phase,
    this.steps = const [],
    this.filesChanged = 0,
    this.testsPassed = 0,
    this.testsFailed = 0,
    this.error,
  });

  ExecutionViewModel copyWith({
    ExecutionStatus? status,
    ExecutionPhase? phase,
    List<ExecutionStep>? steps,
    int? filesChanged,
    int? testsPassed,
    int? testsFailed,
    String? error,
  }) {
    return ExecutionViewModel(
      sessionId: sessionId,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      steps: steps ?? this.steps,
      filesChanged: filesChanged ?? this.filesChanged,
      testsPassed: testsPassed ?? this.testsPassed,
      testsFailed: testsFailed ?? this.testsFailed,
      error: error ?? this.error,
    );
  }
}
```

---

# 4. Riverpod provider

You already use Riverpod heavily, so don't introduce another state-management mechanism.

```dart
final executionProvider = StateNotifierProvider.family<
    ExecutionNotifier,
    ExecutionViewModel,
    String>((ref, sessionId) {
  return ExecutionNotifier(sessionId);
});
```

Then:

```dart
class ExecutionNotifier
    extends StateNotifier<ExecutionViewModel> {
  ExecutionNotifier(String sessionId)
      : super(
          ExecutionViewModel(sessionId: sessionId),
        );

  void startPlanning() {
    state = state.copyWith(
      status: ExecutionStatus.planning,
      phase: ExecutionPhase.understand,
    );
  }

  void startStep({
    required String id,
    required String title,
    required ExecutionPhase phase,
  }) {
    final step = ExecutionStep(
      id: id,
      title: title,
      phase: phase,
      status: ExecutionStatus.running,
    );

    state = state.copyWith(
      status: ExecutionStatus.running,
      phase: phase,
      steps: [
        ...state.steps,
        step,
      ],
    );
  }

  void completeStep(String id, Duration duration) {
    state = state.copyWith(
      steps: state.steps.map((step) {
        if (step.id != id) return step;

        return step.copyWith(
          status: ExecutionStatus.completed,
          duration: duration,
        );
      }).toList(),
    );
  }

  void requireApproval() {
    state = state.copyWith(
      status: ExecutionStatus.waitingForApproval,
    );
  }

  void complete() {
    state = state.copyWith(
      status: ExecutionStatus.completed,
    );
  }

  void fail(String message) {
    state = state.copyWith(
      status: ExecutionStatus.failed,
      error: message,
    );
  }
}
```

---

# 5. Build the execution header

Create:

```text
features/execution/widgets/execution_status_header.dart
```

```dart
class ExecutionStatusHeader extends ConsumerWidget {
  const ExecutionStatusHeader({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.watch(
      executionProvider(sessionId),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context)
                .dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          _StatusIndicator(
            status: execution.status,
          ),

          const SizedBox(width: 10),

          Text(
            _statusLabel(execution.status),
            style: Theme.of(context)
                .textTheme
                .labelLarge,
          ),

          const Spacer(),

          if (execution.filesChanged > 0)
            _Metric(
              label: 'Files',
              value: '${execution.filesChanged}',
            ),

          if (execution.testsPassed > 0)
            _Metric(
              label: 'Tests',
              value: '${execution.testsPassed} ✓',
            ),
        ],
      ),
    );
  }

  String _statusLabel(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.idle:
        return 'Ready';
      case ExecutionStatus.planning:
        return 'Planning';
      case ExecutionStatus.running:
        return 'Working';
      case ExecutionStatus.waitingForApproval:
        return 'Waiting for approval';
      case ExecutionStatus.verifying:
        return 'Verifying';
      case ExecutionStatus.completed:
        return 'Completed';
      case ExecutionStatus.failed:
        return 'Failed';
      case ExecutionStatus.cancelled:
        return 'Cancelled';
      case ExecutionStatus.paused:
        return 'Paused';
    }
  }
}
```

This gives the application a consistent top-level execution state.

---

# 6. Execution timeline

This is the component I would make visually prominent.

```dart
class ExecutionTimeline extends ConsumerWidget {
  const ExecutionTimeline({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution =
        ref.watch(executionProvider(sessionId));

    return Column(
      children: [
        for (final step in execution.steps)
          ExecutionStepTile(step: step),
      ],
    );
  }
}
```

Then:

```dart
class ExecutionStepTile extends StatelessWidget {
  const ExecutionStepTile({
    super.key,
    required this.step,
  });

  final ExecutionStep step;

  @override
  Widget build(BuildContext context) {
    final icon = switch (step.status) {
      ExecutionStatus.completed =>
        Icons.check_circle_outline,
      ExecutionStatus.running =>
        Icons.sync,
      ExecutionStatus.failed =>
        Icons.error_outline,
      ExecutionStatus.waitingForApproval =>
        Icons.lock_outline,
      _ => Icons.radio_button_unchecked,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(step.title),

                if (step.detail != null)
                  Text(
                    step.detail!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
              ],
            ),
          ),

          if (step.duration != null)
            Text(
              _formatDuration(step.duration!),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 1) {
      return '${duration.inMilliseconds}ms';
    }

    return '${duration.inSeconds}s';
  }
}
```

---

# 7. Make `ToolCall` a rich UI component

You already have `ToolCall` with:

* summary
* input
* output
* status
* risk
* duration
* error
* subtasks
* result
* progress
* blocking state. 

So don't create another tool model.

Create:

```text
features/chat/widgets/tool_call_card.dart
```

```dart
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
```

And:

```dart
class _ToolCallCardState
    extends State<ToolCallCard> {

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.toolCall;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _statusIcon(tool.status),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      tool.summary,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),

                  if (tool.duration != null)
                    Text(
                      '${tool.duration!.inSeconds}s',
                    ),

                  const SizedBox(width: 8),

                  Icon(
                    expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),

          if (expanded)
            _ToolDetails(tool: tool),
        ],
      ),
    );
  }
}
```

The expanded body:

```dart
class _ToolDetails extends StatelessWidget {
  const _ToolDetails({
    required this.tool,
  });

  final ToolCall tool;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          if (tool.detailInput != null) ...[
            const Text('INPUT'),
            const SizedBox(height: 4),
            SelectableText(
              tool.detailInput.toString(),
            ),
          ],

          const SizedBox(height: 12),

          if (tool.detailOutput != null) ...[
            const Text('OUTPUT'),
            const SizedBox(height: 4),
            SelectableText(
              tool.detailOutput.toString(),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

# 8. Approval card

This is particularly important because the Wayang runtime actually has a `WaitForApproval` decision and policy evaluation can return `RequireApproval`. 

Don't represent that as ordinary chat.

Create:

```text
features/chat/widgets/approval_card.dart
```

```dart
class ApprovalCard extends ConsumerWidget {
  const ApprovalCard({
    super.key,
    required this.sessionId,
    required this.entry,
  });

  final String sessionId;
  final ChatEntry entry;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final approval = entry.approval!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.lock_outline),
                SizedBox(width: 8),
                Text(
                  'Permission required',
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              approval.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 8),

            SelectableText(
              approval.description,
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // deny
                  },
                  child: const Text('Deny'),
                ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: () {
                    // approve
                  },
                  child: const Text('Allow'),
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

I would then add:

```text
Allow once
Always allow for this tool
Deny
```

rather than only Allow/Deny.

---

# 9. Plan card

Your GUI already has `AgentPlan` and `PlanStep`, while the engine has an `AgentPlan` with statuses such as `PENDING`, `IN_PROGRESS`, `COMPLETED`, `FAILED`, and `SKIPPED`.

Build:

```text
features/chat/widgets/agent_plan_card.dart
```

```dart
class AgentPlanCard extends StatelessWidget {
  const AgentPlanCard({
    super.key,
    required this.plan,
  });

  final AgentPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              plan.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 12),

            for (final step in plan.steps)
              _PlanStepTile(step: step),
          ],
        ),
      ),
    );
  }
}
```

This can replace a lot of verbose textual "I'll do X, then Y..." messages.

---

# 10. Improve `ChatEntryRenderer`

Your existing architecture already appears to dispatch different entry types.

I'd make that explicit:

```dart
Widget buildChatEntry(
  BuildContext context,
  ChatEntry entry,
) {
  switch (entry.type) {
    case ChatEntryType.userPrompt:
      return UserMessageBubble(entry: entry);

    case ChatEntryType.agentText:
      return AgentMessageBubble(entry: entry);

    case ChatEntryType.toolCall:
      return ToolCallCard(
        toolCall: entry.toolCall!,
      );

    case ChatEntryType.approval:
      return ApprovalCard(
        sessionId: entry.metadata?['sessionId'],
        entry: entry,
      );

    case ChatEntryType.plan:
      return AgentPlanCard(
        plan: entry.plan!,
      );

    case ChatEntryType.stepEvent:
      return ExecutionEventTile(
        entry: entry,
      );
  }
}
```

That is the point where the chat becomes an **execution UI**.

---

# 11. Improve the composer

Create:

```text
features/chat/widgets/chat_composer.dart
```

I'd structure it as:

```dart
class ChatComposer extends ConsumerStatefulWidget {
  const ChatComposer({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  ConsumerState<ChatComposer> createState() =>
      _ChatComposerState();
}
```

UI:

```dart
@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
    ),
    child: Column(
      children: [
        TextField(
          controller: _controller,
          minLines: 1,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText:
                'Ask Aljabr to modify this project...',
            border: InputBorder.none,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.attach_file,
              ),
              onPressed: _attach,
            ),

            TextButton.icon(
              icon: const Icon(
                Icons.alternate_email,
              ),
              label: const Text('Context'),
              onPressed: _showContextPicker,
            ),

            TextButton.icon(
              icon: const Icon(
                Icons.auto_awesome,
              ),
              label: const Text('Commands'),
              onPressed: _showCommands,
            ),

            const Spacer(),

            _ModelSelector(),

            const SizedBox(width: 8),

            FilledButton(
              onPressed: _send,
              child: const Icon(
                Icons.arrow_upward,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

---

# 12. Add slash commands

```dart
const commands = [
  ChatCommand(
    name: '/review',
    description: 'Review the current changes',
  ),
  ChatCommand(
    name: '/test',
    description: 'Run relevant tests',
  ),
  ChatCommand(
    name: '/fix',
    description: 'Find and fix the current issue',
  ),
  ChatCommand(
    name: '/explain',
    description: 'Explain selected code',
  ),
  ChatCommand(
    name: '/search',
    description: 'Search the workspace',
  ),
];
```

Then detect:

```dart
void _handleInput(String value) {
  if (!value.startsWith('/')) return;

  final match = commands.where(
    (command) =>
        command.name.startsWith(value),
  );

  // show autocomplete popup
}
```

---

# 13. Add `@context`

Similarly:

```dart
const contextItems = [
  '@file',
  '@folder',
  '@selection',
  '@test',
  '@session',
];
```

Then:

```text
@file SessionResource.java
```

can be converted into an attachment/context object before calling:

```dart
backendService.runAgent(
  sessionId: sessionId,
  prompt: prompt,
  workspacePath: workspacePath,
  attachments: attachments,
);
```

Your existing backend interface already accepts `attachments`, `workspacePath`, `providerId` and `modelId`. 

---

# 14. Diff viewer

This should become a separate feature:

```text
features/changes/
├── models/
│   └── file_diff.dart
├── providers/
│   └── changes_provider.dart
└── widgets/
    ├── changes_drawer.dart
    ├── diff_view.dart
    └── file_change_tile.dart
```

You already have `FileDiff` references in the GUI persistence layer, although diff caching is currently TODO. 

Start simple:

```dart
class FileDiff {
  final String path;
  final int additions;
  final int deletions;
  final String diff;

  const FileDiff({
    required this.path,
    required this.additions,
    required this.deletions,
    required this.diff,
  });
}
```

Then:

```dart
class ChangesDrawer extends StatelessWidget {
  const ChangesDrawer({
    super.key,
    required this.diffs,
  });

  final List<FileDiff> diffs;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        '${diffs.length} files changed',
      ),
      children: [
        for (final diff in diffs)
          ListTile(
            title: Text(diff.path),
            trailing: Text(
              '+${diff.additions} '
              '-${diff.deletions}',
            ),
          ),
      ],
    );
  }
}
```

Then later replace the diff body with a real syntax-aware diff renderer.

---

# 15. Change the main `IdeHomeScreen`

This is where everything comes together.

Conceptually:

```dart
Row(
  children: [
    SizedBox(
      width: sidebarWidth,
      child: ProjectSidebar(),
    ),

    Expanded(
      child: Column(
        children: [
          ExecutionStatusHeader(
            sessionId: activeSessionId,
          ),

          Expanded(
            child: ChatPanel(
              sessionId: activeSessionId,
            ),
          ),

          ChangesDrawer(
            sessionId: activeSessionId,
          ),

          ChatComposer(
            sessionId: activeSessionId,
          ),
        ],
      ),
    ),

    if (showEditor)
      SizedBox(
        width: editorWidth,
        child: EditorPanel(),
      ),
  ],
)
```

This is the layout I would target.

---

# 16. Don't rebuild the backend yet

This is important.

Your backend already exposes:

```dart
Stream<Map<String, dynamic>> runAgent(...)
```

and the API's `runAgent` is already streaming events from the orchestrator.

However, there is currently an important mismatch: `ChatServiceImpl.runAgent()` maps the orchestrator stream to only:

```text
TEXT
```

and then emits:

```text
DONE
```



That means the frontend **cannot yet build the rich execution timeline from the backend reliably**.

This is where I would make the next backend change.

---

# 17. Upgrade `RunAgentEvent`

Instead of:

```text
TEXT
DONE
```

I would make the event contract support:

```text
AGENT_STARTED
PLAN_CREATED
PLAN_STEP_STARTED
PLAN_STEP_COMPLETED

TOOL_STARTED
TOOL_APPROVAL_REQUIRED
TOOL_COMPLETED
TOOL_FAILED

TEXT

PATCH_PROPOSED
PATCH_APPLIED

TEST_STARTED
TEST_COMPLETED

VERIFICATION_STARTED
VERIFICATION_COMPLETED

DONE
ERROR
```

For example:

```proto
message RunAgentEvent {
  string execution_id = 1;
  string type = 2;

  string content = 3;

  string tool_name = 4;
  string tool_input = 5;
  string tool_output = 6;

  string step_id = 7;
  string step_title = 8;

  string status = 9;
  string error = 10;

  int64 duration_ms = 11;

  string risk = 12;
}
```

That would allow the Flutter layer to consume the actual execution semantics.

---

# 18. Map backend events into the UI

Create:

```dart
class ExecutionEventMapper {
  static void apply(
    ExecutionNotifier notifier,
    Map<String, dynamic> event,
  ) {
    switch (event['type']) {
      case 'AGENT_STARTED':
        notifier.startPlanning();
        break;

      case 'PLAN_STEP_STARTED':
        notifier.startStep(
          id: event['step_id'],
          title: event['step_title'],
          phase: _phase(event['step_type']),
        );
        break;

      case 'PLAN_STEP_COMPLETED':
        notifier.completeStep(
          event['step_id'],
          Duration(
            milliseconds:
                event['duration_ms'] ?? 0,
          ),
        );
        break;

      case 'TOOL_APPROVAL_REQUIRED':
        notifier.requireApproval();
        break;

      case 'DONE':
        notifier.complete();
        break;

      case 'ERROR':
        notifier.fail(
          event['error'] ?? 'Unknown error',
        );
        break;
    }
  }
}
```

Now the backend event stream becomes the source of truth for the execution UI.

---

# 19. Use the Wayang listener architecture

This is actually a very good fit for the architecture you already have.

The Wayang agent exposes callbacks for:

```text
onAgentStart
onThought
onToolStart
onToolResult
onAgentEnd
onAgentError
```



So I would create an adapter:

```text
Wayang Agent Events
        ↓
Aljabr Execution Events
        ↓
gRPC RunAgentEvent
        ↓
Flutter ExecutionEventMapper
        ↓
ExecutionNotifier
        ↓
Timeline / Tool Cards / Approval / Status
```

That is the clean architecture.

---

# 20. One thing I would fix immediately

Your current `observeSession()` implementation in the API returns an empty stream:

```java
@Override
public Multi<ChatMessage> observeSession(
    ObserveSessionRequest request) {
    return Multi.createFrom().empty();
}
```

So the GUI's live-session architecture cannot actually receive persistent session events through that endpoint yet. 

The GUI already has the right abstraction:

```dart
Stream<ChatEntry> observeSession(String sessionId);
```

but the production gRPC implementation depends on a backend stream that currently acknowledges with nothing. 

That should be fixed as part of the execution-event work.

---

# 21. Recommended actual implementation order

I would **not** try to implement all of this at once.

### Commit 1 — UI foundation

```text
features/execution/
  models/
  providers/
  widgets/
```

Implement:

* `ExecutionStatus`
* `ExecutionPhase`
* `ExecutionStep`
* `ExecutionViewModel`
* `ExecutionNotifier`
* `ExecutionStatusHeader`
* `ExecutionTimeline`

No backend changes yet.

---

### Commit 2 — Tool UX

Implement:

```text
ToolCallCard
ToolDetails
ApprovalCard
AgentPlanCard
ExecutionEventTile
```

Reuse the existing:

```text
ChatEntry
ToolCall
Approval
AgentPlan
```

rather than duplicating models.

---

### Commit 3 — Composer

Implement:

```text
ChatComposer
CommandPicker
ContextPicker
ModelSelector
AttachmentPicker
```

Then add:

```text
/review
/test
/fix
/explain
/search
```

---

### Commit 4 — Backend event contract

Change:

```text
RunAgentEvent
```

from:

```text
TEXT
DONE
```

to the richer event model.

This is the biggest architectural change.

---

### Commit 5 — Event adapter

Implement:

```text
Wayang listener
      ↓
Aljabr RunAgentEvent
      ↓
gRPC
```

Then:

```text
gRPC
 ↓
Flutter
 ↓
ExecutionEventMapper
 ↓
ExecutionNotifier
```

---

### Commit 6 — Changes

Implement:

```text
ChangesProvider
ChangesDrawer
FileChangeTile
DiffViewer
```

Then connect it to the engine's patch/change information.

The engine already has `PlannedChange`, risk levels and semantic patch validation, so this is a natural next layer. 

---

### Commit 7 — Final polish

Then do:

* spacing
* typography
* animation
* hover states
* keyboard navigation
* command palette
* responsive layout
* empty states
* error states
* connection indicator
* settings cleanup

---

## The key architectural change

I would summarize the implementation as:

```text
CURRENT

Agent
  ↓
ChatEntry
  ↓
Chat UI


TARGET

Wayang Agent
     │
     ├── Plan
     ├── Tool
     ├── Approval
     ├── Patch
     ├── Test
     ├── Verification
     └── Result
           │
           ▼
    Aljabr ExecutionEvent
           │
           ▼
    ExecutionViewModel
           │
     ┌─────┼──────────┐
     ▼     ▼          ▼
   Chat  Timeline   Changes
     │     │          │
     └─────┼──────────┘
           ▼
       IDE Workspace
```

That is the code-level version of the UX direction I recommended.

And importantly, **you don't need to throw away the existing GUI**. Your current `ChatEntry`/`ToolCall`/`AgentPlan`/`Approval` architecture is already surprisingly close; the main missing layer is a first-class execution state/event model tying those pieces together.


Next, I would **stop discussing the UX at a high level and start implementing Phase 1**.

Given the current codebase, the best next move is:

## Step 1 — Build the execution UI foundation

Do this before touching the visual polish.

### Create

```text
lib/features/execution/
├── models/
│   ├── execution_status.dart
│   ├── execution_phase.dart
│   ├── execution_step.dart
│   └── execution_view_model.dart
├── providers/
│   └── execution_provider.dart
└── widgets/
    ├── execution_status_header.dart
    ├── execution_timeline.dart
    └── execution_step_tile.dart
```

The first milestone should be a working UI like:

```text
┌─────────────────────────────────────────────────────────┐
│ ● Working                                      12.4s    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ✓ Understand request                            0.4s   │
│ ✓ Inspect workspace                              1.2s   │
│ ● Analyze Hibernate mapping                            │
│ ○ Apply changes                                        │
│ ○ Run tests                                             │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ I'll inspect the mapping and identify the mismatch...  │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ Ask Aljabr...                                    ↑     │
└─────────────────────────────────────────────────────────┘
```

**Don't connect it to the backend yet.** Initially feed it fake/local state so we can get the UX right.

---

# Step 2 — Refactor the chat renderer

Then take the existing `ChatEntry` model and make rendering explicitly component-based:

```text
ChatEntry
   │
   ├── user       → UserMessage
   ├── agent      → AgentMessage
   ├── tool       → ToolCallCard
   ├── approval   → ApprovalCard
   ├── plan       → PlanCard
   └── event      → ExecutionEvent
```

This is where the current chat starts becoming an **agent workspace** rather than a conventional chatbot.

---

# Step 3 — Make tool calls beautiful

This is probably the highest-impact visual change.

For example:

```text
✓ Run tests                                      12.4s
  ./mvnw test -Dtest=SessionResourceTest

  6 tests passed · 0 failures

  [View output]
```

Collapsed by default.

Click:

```text
┌───────────────────────────────────────────────┐
│ ✓ Run tests                             12.4s │
├───────────────────────────────────────────────┤
│ COMMAND                                       │
│ ./mvnw test -Dtest=SessionResourceTest        │
│                                               │
│ OUTPUT                                        │
│ Tests run: 6, Failures: 0, Errors: 0          │
│ BUILD SUCCESS                                 │
│                                               │
│ [Copy]                            [Terminal ↗] │
└───────────────────────────────────────────────┘
```

Your existing `ToolCall` already contains enough information to support this, so this is mostly a frontend job. 

---

# Step 4 — Then fix the event pipeline

Only after the UI works should we change the backend.

Right now, the important limitation is that the API stream effectively reduces agent execution to text/done events. 

We want:

```text
Wayang
  ↓
agent/tool/plan events
  ↓
Aljabr RunAgentEvent
  ↓
gRPC
  ↓
Flutter
  ↓
ExecutionNotifier
```

The Wayang side already has agent lifecycle/tool callbacks, so we can build the adapter around those. 

---

# Step 5 — Then build the diff experience

Once execution events work:

```text
2 files changed

M SessionResource.java       +12 -4
M SessionResourceTest.java   +18 -2

[Review changes]
```

Clicking **Review changes** opens the diff.

This should become one of Aljabr's signature interactions.

---

# Step 6 — Finally polish the shell

Only after the execution model is working:

* sidebar spacing
* typography
* colors
* hover states
* animations
* composer
* command palette
* connection status
* empty states
* error states
* responsive resizing

Otherwise we'll spend time polishing UI components that will later be structurally replaced.

---

## So, concretely, I suggest we do this next:

**I can take the existing GUI code and write the actual first implementation for you:**

```text
1. execution models
2. Riverpod execution provider
3. execution header
4. execution timeline
5. execution step cards
6. integration into IdeHomeScreen
7. mock execution flow so you can immediately see it working
```

That gives us a **real visible milestone first**, before touching the backend.


