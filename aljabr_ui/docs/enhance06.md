Yes. **Next: the actual IDE shell and layout system.**

Now we turn the architecture into a concrete Flutter UI foundation. The goal is that every screen—Editor, Agent, Git, Verification, Problems—lives inside one consistent workspace.

---

# 1. Start with the shell

Create:

```text
lib/
├── app/
│   ├── app.dart
│   └── app_theme.dart
│
├── workspace/
│   ├── workspace_shell.dart
│   ├── workspace_layout.dart
│   ├── workspace_controller.dart
│   └── workspace_state.dart
│
├── actions/
│   ├── action.dart
│   ├── action_registry.dart
│   └── shortcut_manager.dart
│
├── editor/
├── explorer/
├── agent/
├── git/
├── verification/
└── problems/
```

The important part is:

```text
WorkspaceShell
    ├── ActivityRail
    ├── SidePanel
    ├── EditorArea
    ├── AuxiliaryPanel
    └── BottomPanel
```

---

# 2. Layout state

Don't hard-code panel sizes.

```dart
enum PanelPosition {
  left,
  right,
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
    this.leftWidth = 280,
    this.rightWidth = 360,
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

# 3. Main shell

```dart
class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({
    super.key,
  });

  @override
  State<WorkspaceShell> createState() =>
      _WorkspaceShellState();
}

class _WorkspaceShellState
    extends State<WorkspaceShell> {

  WorkspaceLayout layout =
      const WorkspaceLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WorkspaceTopBar(),

          Expanded(
            child: Row(
              children: [
                const ActivityRail(),

                if (layout.leftVisible)
                  SizedBox(
                    width: layout.leftWidth,
                    child: const WorkspaceSidePanel(),
                  ),

                Expanded(
                  child: Column(
                    children: [
                      const Expanded(
                        child: EditorArea(),
                      ),

                      if (layout.bottomVisible)
                        SizedBox(
                          height: layout.bottomHeight,
                          child: const BottomPanel(),
                        ),
                    ],
                  ),
                ),

                if (layout.rightVisible)
                  SizedBox(
                    width: layout.rightWidth,
                    child: const AuxiliaryPanel(),
                  ),
              ],
            ),
          ),

          const WorkspaceStatusBar(),
        ],
      ),
    );
  }
}
```

This is the backbone.

---

# 4. Top bar

Keep it deliberately minimal.

```dart
class WorkspaceTopBar extends StatelessWidget {
  const WorkspaceTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 12),

          const AppLogo(),

          const SizedBox(width: 16),

          const WorkspaceSwitcher(),

          const Spacer(),

          const UniversalLauncher(),

          const SizedBox(width: 8),

          const WorkspaceHealthIndicator(),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
```

Don't fill the top bar with 15 buttons.

---

# 5. Activity rail

This is your persistent navigation.

```text
┌────┐
│ ◉  │ Agent
│    │
│ ◇  │ Explorer
│    │
│ ⎇  │ Git
│    │
│ ✓  │ Verify
│    │
│ ⚠  │ Problems
│    │
│    │
│ ⚙  │ Settings
└────┘
```

Implementation:

```dart
enum Activity {
  explorer,
  agent,
  git,
  verification,
  problems,
  settings,
}
```

```dart
class ActivityRail extends StatelessWidget {
  const ActivityRail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // switch activity
      },
      labelType:
          NavigationRailLabelType.none,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Explorer'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: Text('Agent'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_tree_outlined),
          selectedIcon: Icon(Icons.account_tree),
          label: Text('Git'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.check_circle_outline),
          selectedIcon: Icon(Icons.check_circle),
          label: Text('Verify'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.warning_amber_outlined),
          selectedIcon: Icon(Icons.warning),
          label: Text('Problems'),
        ),
      ],
    );
  }
}
```

---

# 6. Don't use `NavigationRail` state directly

Connect it to your workspace:

```dart
class WorkspaceNavigation {
  final Activity activity;

  const WorkspaceNavigation({
    this.activity = Activity.explorer,
  });

  WorkspaceNavigation copyWith({
    Activity? activity,
  }) {
    return WorkspaceNavigation(
      activity: activity ?? this.activity,
    );
  }
}
```

Now navigation becomes persistent state.

---

# 7. Resizable panels

This is where the UX becomes much more polished.

Create:

```dart
class ResizeHandle extends StatelessWidget {
  final Axis axis;
  final ValueChanged<double> onResize;

  const ResizeHandle({
    super.key,
    required this.axis,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: axis == Axis.vertical
          ? SystemMouseCursors.resizeUpDown
          : SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onPanUpdate: (details) {
          final delta = axis == Axis.horizontal
              ? details.delta.dx
              : details.delta.dy;

          onResize(delta);
        },
        child: SizedBox(
          width:
              axis == Axis.horizontal ? 5 : null,
          height:
              axis == Axis.vertical ? 5 : null,
        ),
      ),
    );
  }
}
```

---

# 8. Use constraints

Never allow:

```text
left panel = 2px
```

or:

```text
agent panel = 1800px
```

Use:

```dart
double clampPanelWidth(
  double width,
) {
  return width.clamp(
    200,
    600,
  );
}
```

For the bottom:

```dart
double clampBottomHeight(
  double height,
) {
  return height.clamp(
    120,
    500,
  );
}
```

---

# 9. Editor tabs

The editor should support multiple tabs.

```dart
class EditorTab {
  final String id;
  final String path;
  final bool dirty;
  final bool pinned;

  const EditorTab({
    required this.id,
    required this.path,
    this.dirty = false,
    this.pinned = false,
  });
}
```

UI:

```text
┌───────────────────────────────────────────────────┐
│ AuthService.java × │ Session.java × │ +           │
├───────────────────────────────────────────────────┤
│                                                   │
│                  CODE                             │
│                                                   │
└───────────────────────────────────────────────────┘
```

---

# 10. Tab manager

```dart
class EditorTabManager
    extends ChangeNotifier {

  final List<EditorTab> _tabs = [];

  String? _activeId;

  List<EditorTab> get tabs =>
      List.unmodifiable(_tabs);

  EditorTab? get activeTab {
    for (final tab in _tabs) {
      if (tab.id == _activeId) {
        return tab;
      }
    }

    return null;
  }

  void open(EditorTab tab) {
    final existing = _tabs.any(
      (item) => item.path == tab.path,
    );

    if (!existing) {
      _tabs.add(tab);
    }

    _activeId = tab.id;

    notifyListeners();
  }
}
```

---

# 11. Don't duplicate files

If the user opens:

```text
AuthService.java
```

from Explorer and then Quick Open, don't create:

```text
AuthService.java
AuthService.java
```

The tab manager owns identity.

---

# 12. Dirty tabs

Show:

```text
AuthService.java ●
```

rather than:

```text
AuthService.java *
```

The dot is cleaner.

Click close:

```text
Unsaved changes

AuthService.java has unsaved changes.

[Cancel] [Discard] [Save]
```

---

# 13. Split editor

Now support:

```text
┌──────────────────────┬──────────────────────┐
│ AuthService.java     │ AuthServiceTest.java │
│                      │                      │
│                      │                      │
│                      │                      │
└──────────────────────┴──────────────────────┘
```

Model:

```dart
class EditorGroup {
  final String id;
  final List<EditorTab> tabs;
  final String? activeTabId;

  const EditorGroup({
    required this.id,
    this.tabs = const [],
    this.activeTabId,
  });
}
```

Then:

```dart
class EditorLayout {
  final List<EditorGroup> groups;

  const EditorLayout({
    this.groups = const [],
  });
}
```

---

# 14. Split actions

Add:

```dart
enum ActionId {
  // ...

  splitEditorRight,
  splitEditorDown,
  closeEditorGroup,
  focusNextGroup,
}
```

This is exactly why the action registry we built earlier matters.

---

# 15. Breadcrumbs

Above the editor:

```text
AuthService.java
  › Authentication
  › refreshSession()
```

Model:

```dart
class BreadcrumbItem {
  final String label;
  final String? symbolId;

  const BreadcrumbItem({
    required this.label,
    this.symbolId,
  });
}
```

Clicking:

```text
refreshSession()
```

jumps directly to that symbol.

---

# 16. Sticky editor header

When scrolling:

```text
┌─────────────────────────────────────┐
│ refreshSession()                    │
└─────────────────────────────────────┘
```

Keep the current symbol visible.

This is a small feature with a large perceived-quality impact.

---

# 17. Explorer

Explorer should have three layers:

```text
EXPLORER

WORKSPACE
  src/
  tests/

OPEN EDITORS
  AuthService.java
  SessionService.java

OUTLINE
  authenticate()
  refreshSession()
  logout()
```

Don't overload one tree.

---

# 18. Explorer header

```text
EXPLORER                         ⋯
─────────────────────────────────
Search files...
```

Actions:

```text
New File
New Folder
Refresh
Collapse All
```

Again, all via `ActionRegistry`.

---

# 19. File tree model

```dart
enum FileNodeType {
  file,
  folder,
}

class FileNode {
  final String path;
  final String name;
  final FileNodeType type;

  final bool expanded;

  final List<FileNode> children;

  const FileNode({
    required this.path,
    required this.name,
    required this.type,
    this.expanded = false,
    this.children = const [],
  });
}
```

---

# 20. Git status inside Explorer

Combine the earlier Git model:

```text
src/
├── AuthService.java        M
├── SessionService.java     M
└── RefreshToken.java       A
```

But don't use bright colors everywhere.

Use subtle status indicators:

```text
M
A
D
R
```

and reserve stronger visual emphasis for the currently selected file.

---

# 21. Agent panel

The right panel should not be a generic chat sidebar.

Structure it:

```text
AGENT

Current Task
──────────────────────────────
Refactor authentication flow

STATUS
✓ Planning
✓ Changes generated
● Verification

CHANGESET
3 files
7 hunks

[Review Changes]
```

Then conversation below if needed.

---

# 22. Agent context bar

At the bottom:

```text
Context
──────────────────────────────
AuthService.java
SessionService.java
AuthServiceTest.java

+ Add context
```

This is important.

The user should know what the agent is seeing.

---

# 23. Context chips

```text
[AuthService.java ×]
[SessionService.java ×]
[AuthServiceTest.java ×]
[+]
```

Click `+`:

```text
Add context

Current file
Selection
Related files
Git changes
Verification failures
Search...
```

---

# 24. Bottom panel

Use it for transient tools:

```text
┌─────────────────────────────────────────────────────┐
│ TERMINAL  PROBLEMS  OUTPUT  VERIFICATION  GIT      │
├─────────────────────────────────────────────────────┤
│                                                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

Don't make these permanent competing panels.

---

# 25. Bottom panel tabs

```dart
enum BottomPanel {
  terminal,
  problems,
  output,
  verification,
  git,
}
```

Opening a panel:

```dart
void openBottomPanel(
  BottomPanel panel,
) {
  layout = layout.copyWith(
    bottomVisible: true,
  );

  activeBottomPanel = panel;
}
```

---

# 26. Automatic panel opening

When verification fails:

```text id="0d8grj"
Run tests
   ↓
failure
   ↓
Problems panel opens
```

But don't steal focus.

Instead:

```text
Problems   2
```

appears and the panel can open automatically if configured.

---

# 27. Focus policy

Create:

```dart
enum FocusPolicy {
  preserve,
  reveal,
  steal,
}
```

Default:

```text
normal action → preserve
navigation → reveal
critical error → reveal
modal approval → steal
```

This prevents annoying UI jumps.

---

# 28. Status bar

Keep it information-dense but quiet:

```text
main  • 4 changes
✓ verified
Java 21
UTF-8
Ln 84, Col 12
```

Potentially:

```text
[main] [4 changes] [✓ Verified] [Java] [Ln 84:12]
```

---

# 29. Workspace health

The status bar should reuse:

```dart
WorkspaceHealth
```

So:

```text
✓ Healthy
```

becomes:

```text
⚠ Verification stale
```

or:

```text
✕ 2 Problems
```

without creating separate logic.

---

# 30. Layout persistence

Save:

```dart
class SavedWorkspaceLayout {
  final WorkspaceLayout layout;

  final Activity activity;

  final EditorLayout editor;

  const SavedWorkspaceLayout({
    required this.layout,
    required this.activity,
    required this.editor,
  });
}
```

Persist:

```text
workspace/
  .aljabr/
    layout.json
```

Example:

```json
{
  "leftWidth": 286,
  "rightWidth": 372,
  "bottomHeight": 248,
  "leftVisible": true,
  "rightVisible": true,
  "bottomVisible": false,
  "activity": "explorer"
}
```

---

# 31. Restore intelligently

Don't blindly restore everything.

If the monitor is smaller:

```dart
WorkspaceLayout normalizeLayout(
  WorkspaceLayout layout,
  double availableWidth,
) {
  final total =
      layout.leftWidth +
      layout.rightWidth;

  if (total >
      availableWidth * 0.7) {
    return layout.copyWith(
      leftWidth: 240,
      rightWidth: 320,
    );
  }

  return layout;
}
```

---

# 32. Responsive behavior

Desktop:

```text
Activity | Explorer | Editor | Agent
```

Smaller window:

```text
Activity | Editor
```

Very small:

```text
Editor
```

Then panels become overlays.

```text
┌────────────────────────────┐
│ Editor                     │
│                            │
│                            │
└────────────────────────────┘

       ↓ click Agent

┌────────────────────────────┐
│ Editor                     │
│                     ┌──────┤
│                     │Agent │
│                     │      │
│                     └──────┤
└────────────────────────────┘
```

---

# 33. Don't just use `MediaQuery`

Create a layout mode:

```dart
enum WorkspaceMode {
  desktop,
  compact,
  mobile,
}
```

```dart
WorkspaceMode workspaceMode(
  double width,
) {
  if (width >= 1400) {
    return WorkspaceMode.desktop;
  }

  if (width >= 900) {
    return WorkspaceMode.compact;
  }

  return WorkspaceMode.mobile;
}
```

---

# 34. Desktop layout

At `1400+`:

```text
┌──────────────────────────────────────────────────────────┐
│ Top bar                                                   │
├───┬──────────────┬──────────────────────┬─────────────────┤
│ A │ Explorer     │ Editor               │ Agent           │
│ c │              │                      │                 │
│ t │              │                      │                 │
│ i │              │                      │                 │
│ v │              │                      │                 │
│ i │              │                      │                 │
│ t │              │                      │                 │
│ y │              │                      │                 │
├───┴──────────────┴──────────────────────┴─────────────────┤
│ Status                                                    │
└───────────────────────────────────────────────────────────┘
```

---

# 35. Compact layout

```text
┌───────────────────────────────────────────┐
│ Top bar                                   │
├────┬──────────────────────────────────────┤
│ A  │ Editor                               │
│ c  │                                      │
│ t  │                                      │
│ i  │                                      │
│ v  │                                      │
│ i  │                                      │
│ t  │                                      │
│ y  │                                      │
└────┴──────────────────────────────────────┘
```

Explorer and Agent slide over the editor.

---

# 36. Motion

Don't animate everything.

Use animation for:

```text
Panel opening
Panel closing
Tab changes
Command palette
Diff review
Notifications
```

Avoid animation for:

```text
Every tree expansion
Every keystroke
Every editor update
```

---

# 37. Panel animation

```dart
AnimatedContainer(
  duration:
      const Duration(milliseconds: 180),
  curve: Curves.easeOutCubic,
  width: layout.leftVisible
      ? layout.leftWidth
      : 0,
  child: const WorkspaceSidePanel(),
)
```

Keep it around `150–200ms`.

---

# 38. Focus transitions

When opening Command Palette:

```text
Current editor
      ↓
Palette
      ↓
Esc
      ↓
exact previous editor focus
```

Store:

```dart
class FocusSnapshot {
  final String? activeFile;
  final int? cursorOffset;

  const FocusSnapshot({
    this.activeFile,
    this.cursorOffset,
  });
}
```

This tiny detail makes the UI feel professional.

---

# 39. Global overlay manager

You'll eventually have:

```text
Command Palette
Quick Open
Search
Notifications
Confirmation dialogs
Agent approval
Diff review
```

Don't let every widget create arbitrary overlays.

Create:

```dart
enum OverlayType {
  commandPalette,
  quickOpen,
  search,
  confirmation,
  agentApproval,
  diffReview,
}
```

Then one `OverlayManager`.

---

# 40. Final shell architecture

At this stage:

```text
App
│
└── WorkspaceShell
    │
    ├── TopBar
    │   └── UniversalLauncher
    │
    ├── ActivityRail
    │
    ├── SidePanel
    │   ├── Explorer
    │   ├── Agent
    │   ├── Git
    │   ├── Verification
    │   └── Problems
    │
    ├── EditorArea
    │   ├── Tabs
    │   ├── Breadcrumbs
    │   ├── Editor
    │   └── SplitGroups
    │
    ├── AuxiliaryPanel
    │   └── Agent / Context / Review
    │
    ├── BottomPanel
    │   ├── Terminal
    │   ├── Problems
    │   ├── Verification
    │   └── Git
    │
    └── StatusBar
```

---

# 41. And the state architecture

```text
                 WorkspaceState
                       │
       ┌───────────────┼────────────────┐
       │               │                │
    Navigation       Editor            Git
       │               │                │
       │               │                │
       └───────────────┼────────────────┘
                       │
                     Agent
                       │
                  Verification
                       │
                    Problems
                       │
                  WorkspaceHealth
```

While actions remain:

```text
Keyboard
    │
Palette
    │
Context menu
    │
Buttons
    │
    ↓
ActionRegistry
    ↓
ActionExecutor
    ↓
Services / Controllers
    ↓
WorkspaceState
```

This gives you a proper separation between **UI, state, actions, and domain logic**.

---

# 42. One more important polish layer: empty states

Every panel needs a useful empty state.

### Explorer

```text
No workspace opened

Open a folder to get started.

[Open Folder]
```

### Agent

```text
Ready when you are.

Ask Aljabr to inspect, plan,
or modify your workspace.

[Start a Task]
```

### Verification

```text
No verification run yet.

[Run Verification]
```

### Git

```text
No changes

Your working tree is clean.
```

### Problems

```text
✓ No problems

Your workspace looks healthy.
```

Empty states should guide—not merely report absence.

---

# 43. The next actual coding step

At this point I would **stop adding architecture** and build the shell in this order:

```text
01  WorkspaceShell
02  ActivityRail
03  ResizableSidePanel
04  EditorTabs
05  BottomPanel
06  StatusBar
07  WorkspaceState
08  ActionRegistry
09  CommandPalette
10  QuickOpen
11  Keyboard shortcuts
12  Layout persistence
13  Responsive layout
```

Once those are physically working, we can plug the already-designed:

```text
Agent
Git
Verification
Problems
```

into the shell.

**Next improvement after that: the Editor itself**—tabs, split views, breadcrumbs, minimap, diagnostics, inline AI actions, diff mode, code selection/context capture, and the polished **“Ask / Explain / Fix / Refactor”** interaction that ties the editor directly into the Agent system.


Absolutely. **Next: the Editor itself.**

This is the most important surface in the product. The shell gives Aljabr structure; the editor is where the **AI + code + Git + verification** experience becomes tangible.

The target is:

```text
┌──────────────────────────────────────────────────────────────┐
│ AuthService.java  ● │ SessionService.java │ +               │
├──────────────────────────────────────────────────────────────┤
│ AuthService.java › Authentication › refreshSession()        │
├──────────────────────────────────────────────────────────────┤
│  78 │                                                       │
│  79 │   Future<Session> refreshSession() {                  │
│  80 │                                                       │
│  81 │     final token = session.refreshToken;               │
│  82 │                         ^^^^^^^^^^^^^                 │
│     │                         ⚠ nullable-access             │
│  83 │                                                       │
│  84 │     return sessionManager.refresh(token);             │
│  85 │   }                                                   │
│                                                              │
│                         ┌─────────────────────────────┐      │
│                         │ Explain   Fix   Refactor    │      │
│                         └─────────────────────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

The key improvement is that **the code editor becomes an entry point into the entire Aljabr system**.

---

# 1. Editor state

Start with a proper editor model.

```dart
enum EditorMode {
  code,
  diff,
  review,
}

class EditorState {
  final String filePath;

  final int cursorOffset;

  final int selectionStart;
  final int selectionEnd;

  final EditorMode mode;

  final bool dirty;

  const EditorState({
    required this.filePath,
    this.cursorOffset = 0,
    this.selectionStart = 0,
    this.selectionEnd = 0,
    this.mode = EditorMode.code,
    this.dirty = false,
  });

  bool get hasSelection =>
      selectionStart != selectionEnd;

  EditorState copyWith({
    int? cursorOffset,
    int? selectionStart,
    int? selectionEnd,
    EditorMode? mode,
    bool? dirty,
  }) {
    return EditorState(
      filePath: filePath,
      cursorOffset:
          cursorOffset ?? this.cursorOffset,
      selectionStart:
          selectionStart ?? this.selectionStart,
      selectionEnd:
          selectionEnd ?? this.selectionEnd,
      mode: mode ?? this.mode,
      dirty: dirty ?? this.dirty,
    );
  }
}
```

---

# 2. Separate document from editor state

This is important.

Don't mix:

```text
file content
```

with:

```text
cursor
selection
scroll position
```

Use:

```dart
class TextDocument {
  final String path;
  final String content;
  final String version;

  const TextDocument({
    required this.path,
    required this.content,
    required this.version,
  });
}
```

Then:

```text
Document
   │
   ├── content
   └── version

EditorState
   │
   ├── cursor
   ├── selection
   ├── scroll
   └── mode
```

This makes diffing, undo, AI changes, and multi-tab editing much easier.

---

# 3. Editor controller

```dart
class EditorController extends ChangeNotifier {
  TextDocument _document;

  EditorState _state;

  EditorController({
    required TextDocument document,
  })  : _document = document,
        _state = EditorState(
          filePath: document.path,
        );

  TextDocument get document => _document;

  EditorState get state => _state;

  void updateSelection({
    required int start,
    required int end,
  }) {
    _state = _state.copyWith(
      selectionStart: start,
      selectionEnd: end,
    );

    notifyListeners();
  }

  void updateCursor(int offset) {
    _state = _state.copyWith(
      cursorOffset: offset,
    );

    notifyListeners();
  }
}
```

---

# 4. Editor toolbar

Keep it small.

```text
┌─────────────────────────────────────────────────────────┐
│ AuthService.java  ●                                      │
│─────────────────────────────────────────────────────────│
│ ←  →   AuthService.java › Auth › refreshSession()       │
│                                                         │
│                                  ⋯  Split  More          │
└─────────────────────────────────────────────────────────┘
```

Avoid putting:

```text
Save
Undo
Redo
Copy
Paste
Format
Git
AI
Run
Test
```

all into the header.

Most of these already have keyboard shortcuts or contextual access.

---

# 5. Breadcrumbs

Create:

```dart
class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumbs({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            const Icon(
              Icons.chevron_right,
              size: 14,
            ),

          InkWell(
            onTap: () {
              // navigate
            },
            child: Text(
              items[i].label,
            ),
          ),
        ],
      ],
    );
  }
}
```

---

# 6. Sticky symbol header

When the user scrolls deep into:

```text
AuthService.java
```

show:

```text
refreshSession()
```

at the top.

Model:

```dart
class SymbolLocation {
  final String name;

  final int startLine;
  final int endLine;

  final String kind;

  const SymbolLocation({
    required this.name,
    required this.startLine,
    required this.endLine,
    required this.kind,
  });
}
```

The editor can determine:

```text
current cursor
      ↓
current symbol
      ↓
sticky header
```

---

# 7. Selection-aware AI

This is one of the biggest UX improvements.

If the user selects:

```java
return sessionManager.refresh(token);
```

a contextual toolbar appears:

```text
Explain   Fix   Refactor   Test   Ask Aljabr
```

Not a giant permanent AI panel.

---

# 8. Selection actions

Add these to the registry:

```dart
enum ActionId {
  // ...

  explainSelection,
  fixSelection,
  refactorSelection,
  generateTests,
  askAboutSelection,
  addSelectionToContext,
}
```

Then:

```dart
AppAction(
  id: ActionId.explainSelection,
  title: 'Explain Selection',
  category: ActionCategory.agent,
  enabled: (context) {
    return context.selectedText != null &&
        context.selectedText!.isNotEmpty;
  },
  execute: (context) async {
    // send selection to agent
  },
)
```

---

# 9. Selection toolbar

```dart
class SelectionActions extends StatelessWidget {
  const SelectionActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius:
          BorderRadius.circular(8),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          _ActionButton(
            label: 'Explain',
            action: ActionId.explainSelection,
          ),
          _ActionButton(
            label: 'Fix',
            action: ActionId.fixSelection,
          ),
          _ActionButton(
            label: 'Refactor',
            action: ActionId.refactorSelection,
          ),
          _ActionButton(
            label: 'Test',
            action: ActionId.generateTests,
          ),
        ],
      ),
    );
  }
}
```

---

# 10. Don't automatically open the Agent panel

This is important.

User clicks:

```text
Explain
```

The result should initially appear **near the code**.

For example:

```text
┌──────────────────────────────────────────┐
│ Explanation                              │
│                                          │
│ This method refreshes the session using  │
│ the stored refresh token.                │
│                                          │
│ [Ask follow-up] [Add to Agent]           │
└──────────────────────────────────────────┘
```

The Agent panel can remain closed.

This preserves focus.

---

# 11. Inline AI response

Model it:

```dart
class InlineAssistantResult {
  final String id;

  final String filePath;

  final int anchorOffset;

  final String content;

  final List<ActionId> actions;

  const InlineAssistantResult({
    required this.id,
    required this.filePath,
    required this.anchorOffset,
    required this.content,
    this.actions = const [],
  });
}
```

---

# 12. Inline fix

For:

```text
⚠ nullable-access
```

click:

```text
Fix
```

The editor should show a proposed patch:

```diff
- final token = session.refreshToken;
+ final token = session?.refreshToken;
```

Then:

```text
[Accept] [Reject] [Explain]
```

This should use the same `ChangeSet` architecture we already built.

---

# 13. Never mutate directly from inline AI

The flow should be:

```text
Inline Fix
    ↓
Agent operation
    ↓
ChangeSet
    ↓
Review
    ↓
Apply transaction
```

not:

```text
Fix button
    ↓
replace text
```

This keeps all AI changes reversible and auditable.

---

# 14. Diagnostics inside editor

Create:

```dart
class DiagnosticMarker {
  final Diagnostic diagnostic;

  final int startOffset;
  final int endOffset;

  const DiagnosticMarker({
    required this.diagnostic,
    required this.startOffset,
    required this.endOffset,
  });
}
```

Then the editor can render:

```text
session.refreshToken
^^^^^^^^^^^^^^^^^^^^
```

with a subtle underline.

---

# 15. Diagnostic hover

Hover:

```text
session.refreshToken
^^^^^^^^^^^^^^^^^^^^

⚠ nullable-access

Possible null value.

Source: compiler

[Explain] [Fix]
```

The actions come from the same registry.

---

# 16. Multiple diagnostics

Don't create five overlapping tooltips.

Aggregate them:

```text
⚠ 3 issues
```

Click:

```text
┌────────────────────────────────────────┐
│ AuthService.java                       │
├────────────────────────────────────────┤
│ ✕ nullable-access                      │
│ ⚠ unused-variable                      │
│ ⚠ deprecated-api                       │
└────────────────────────────────────────┘
```

---

# 17. Gutter

Your editor gutter should communicate:

```text
78
79
80  ●
81
82  ✕
83
84  ●
```

Different markers:

```text
● breakpoint
✕ error
⚠ warning
✓ test coverage
```

Don't overload it.

---

# 18. Test coverage

This is particularly useful for an AI IDE.

Show:

```text
78 │
79 │
80 │  Future<Session> refreshSession()
81 │
```

with a subtle coverage indicator.

For example:

```text
green-ish indicator = covered
neutral = uncovered
```

The actual implementation depends on your editor library, but the model should be:

```dart
class CoverageRange {
  final int startLine;
  final int endLine;
  final int hits;

  const CoverageRange({
    required this.startLine,
    required this.endLine,
    required this.hits,
  });
}
```

---

# 19. Diff mode

Reuse the ChangeSet from earlier.

```dart
class DiffEditor extends StatelessWidget {
  final ChangeSet changeSet;

  const DiffEditor({
    super.key,
    required this.changeSet,
  });

  @override
  Widget build(BuildContext context) {
    return ...
  }
}
```

Modes:

```text
[Code] [Diff] [Review]
```

---

# 20. Diff toolbar

```text
AuthService.java

[Unified] [Split]

AI changes: 4
You: 1

← Previous
Next →
```

And:

```text
[Accept Hunk]
[Reject Hunk]
```

---

# 21. Review mode

This should be different from ordinary diff.

```text
┌───────────────────────────────────────────────┐
│ AI CHANGE                                    │
├───────────────────────────────────────────────┤
│ + final token = session.refreshToken;        │
│                                              │
│ Why                                          │
│ Refresh the session using the stored token.  │
│                                              │
│ ✓ Related test found                         │
│                                              │
│ [Accept] [Reject] [Ask Why]                  │
└───────────────────────────────────────────────┘
```

The explanation is optional.

Don't force AI commentary into every diff.

---

# 22. Inline code actions

When cursor is on a line:

```text
⋮
```

appears in the gutter.

Click:

```text
┌─────────────────────────────────┐
│ Explain line                    │
│ Fix problem                     │
│ Refactor                        │
│ Generate test                   │
│ Add to context                  │
└─────────────────────────────────┘
```

This is more discoverable than expecting users to know keyboard shortcuts.

---

# 23. "Add to context"

This deserves special treatment.

Select:

```text
SessionService.java
```

then:

```text
Add to context
```

Agent context becomes:

```text
Context

[SessionService.java ×]
```

If the user adds selection:

```text
[SessionService.java:42-68 ×]
```

This prevents the agent from unnecessarily reading the entire repository.

---

# 24. Context object

```dart
enum ContextItemType {
  file,
  selection,
  symbol,
  diagnostic,
  gitChange,
  testFailure,
}

class AgentContextItem {
  final String id;

  final ContextItemType type;

  final String label;

  final String? path;

  final int? startLine;

  final int? endLine;

  const AgentContextItem({
    required this.id,
    required this.type,
    required this.label,
    this.path,
    this.startLine,
    this.endLine,
  });
}
```

---

# 25. Automatic context suggestions

When the user opens a failed test:

```text
Test failed:
AuthServiceTest.refreshSession
```

Agent context suggestion:

```text
Suggested context

✓ AuthService.java
✓ AuthServiceTest.java
✓ SessionService.java

[Add All]
```

This makes the agent significantly more useful.

---

# 26. Symbol navigation

Add actions:

```dart
enum ActionId {
  // ...

  goToDefinition,
  goToDeclaration,
  findReferences,
  goToImplementation,
  goToTypeDefinition,
}
```

Keyboard:

```text
Ctrl/Cmd + Click
```

or:

```text
F12
```

depending on your target conventions.

---

# 27. References panel

Click:

```text
find references
```

show:

```text
REFERENCES

AuthService.java
  refreshSession()             line 84

SessionService.java
  refresh()                    line 42

AuthServiceTest.java
  refreshSession()             line 143
```

Clicking navigates without destroying the current context.

---

# 28. Peek definition

Instead of always opening a new tab:

```text
Ctrl/Cmd + click
```

can show:

```text
┌─────────────────────────────────────┐
│ SessionService.refresh()            │
│                                     │
│ Future<Session> refresh(...) {      │
│   ...                               │
│ }                                   │
│                                     │
│ Open File                           │
└─────────────────────────────────────┘
```

This is a major productivity improvement.

---

# 29. Editor navigation history

Track:

```dart
class NavigationLocation {
  final String path;
  final int offset;

  const NavigationLocation({
    required this.path,
    required this.offset,
  });
}
```

Then:

```text
Alt/Option + Left
```

goes back.

```text
Alt/Option + Right
```

goes forward.

This is particularly useful when AI navigation jumps between files.

---

# 30. Search in editor

`Ctrl/Cmd + F`:

```text
┌──────────────────────────────┐
│ refreshSession        2 / 4  │
└──────────────────────────────┘
```

Options:

```text
Aa   Match Case
ab   Whole Word
.*   Regex
```

Keep the search bar inside the editor, not a global modal.

---

# 31. Replace

```text
Find:
refreshSession

Replace:
refreshAuthenticatedSession

[Replace]
[Replace All]
```

For `Replace All`, show:

```text
Replace 14 occurrences?

[Cancel] [Replace All]
```

---

# 32. Format on save

Make it configurable:

```dart
class EditorSettings {
  final bool formatOnSave;
  final bool autoSave;
  final bool showMinimap;
  final bool showWhitespace;
  final bool stickyScroll;

  const EditorSettings({
    this.formatOnSave = true,
    this.autoSave = false,
    this.showMinimap = true,
    this.showWhitespace = false,
    this.stickyScroll = true,
  });
}
```

---

# 33. Minimap

Keep it subtle.

```text
code code code
code code code
  ███
  ███
    ██
    ██
```

Don't let it dominate the screen.

Allow:

```text
Settings
→ Editor
→ Minimap
```

---

# 34. Code folding

Add:

```text
80 │ ▾ refreshSession()
81 │   ...
90 │ ▸ logout()
```

And commands:

```dart
foldCurrentBlock
unfoldCurrentBlock
foldAll
unfoldAll
```

---

# 35. Command integration

The editor now consumes our action system:

```text
Editor
 │
 ├── Explain Selection
 ├── Fix Selection
 ├── Refactor
 ├── Generate Test
 ├── Find References
 ├── Run Test
 ├── Add Context
 ├── Format
 ├── Fold
 └── Split Editor
```

No editor-specific command architecture.

---

# 36. Editor → Agent integration

Here's the important UX loop:

```text
User selects code
       ↓
Fix
       ↓
Agent receives:
  file
  selection
  diagnostics
  related tests
       ↓
Agent creates ChangeSet
       ↓
Inline diff
       ↓
Accept / Reject
       ↓
Verification
```

The user never has to manually copy code into a chat.

---

# 37. Editor → Verification

If cursor is inside a test:

```text
Run Test
```

runs:

```text
AuthServiceTest.refreshSession
```

rather than the entire suite.

If cursor is inside production code:

```text
Run Related Tests
```

uses the test-impact system we designed earlier.

---

# 38. Editor → Git

Right-click:

```text
AuthService.java
```

shows:

```text
Git

Compare with HEAD
Compare with Previous Commit
View File History
Stage File
Discard Changes
Copy Relative Path
```

And:

```text
AI Changes
```

if attribution exists.

---

# 39. "What changed here?"

A very good Aljabr-specific action:

```text
What changed here?
```

Click a line:

```text
┌─────────────────────────────────────────┐
│ Line 84                                 │
├─────────────────────────────────────────┤
│ AI changed this line                    │
│                                         │
│ Agent Run #18                           │
│ 3 files modified                        │
│                                         │
│ Reason                                  │
│ Added refresh-token handling.            │
│                                         │
│ [View Change] [View Agent Run]          │
└─────────────────────────────────────────┘
```

This connects code provenance directly to AI activity.

---

# 40. Line provenance model

```dart
class LineProvenance {
  final String filePath;

  final int line;

  final ChangeOrigin origin;

  final String? agentRunId;

  final String? changeSetId;

  const LineProvenance({
    required this.filePath,
    required this.line,
    required this.origin,
    this.agentRunId,
    this.changeSetId,
  });
}
```

This becomes a very distinctive Aljabr feature.

---

# 41. Code lens

Above methods:

```text
refreshSession()

2 references   •   4 tests   •   AI changed
```

But don't show too much.

Potential code lens:

```text
2 references
3 tests
```

Clicking opens the corresponding panel.

---

# 42. AI code lens

Potentially:

```text
AI changed this method
```

Click:

```text
Agent Run #24
```

This provides transparency without putting AI UI everywhere.

---

# 43. Editor footer

For the current file:

```text
Java 21     UTF-8     LF     84:12
```

And perhaps:

```text
✓ verified
```

But don't duplicate the global health indicator excessively.

---

# 44. Editor component architecture

```text
EditorWorkspace
│
├── EditorTabBar
│
├── EditorBreadcrumbs
│
├── EditorToolbar
│
├── CodeEditor
│   ├── Gutter
│   ├── Diagnostics
│   ├── CodeLens
│   ├── SelectionActions
│   ├── StickySymbols
│   └── Minimap
│
├── InlineAssistant
│
└── EditorStatusBar
```

---

# 45. The key separation

Keep the editor itself dumb.

```text
Editor
   ↓
EditorController
   ↓
WorkspaceState
   ↓
ActionRegistry
   ↓
Agent / Git / Verification services
```

Don't put:

```text
Git logic
Agent logic
Verification logic
```

inside the editor widget.

---

# 46. Result

The editor now becomes:

```text
                 CODE
                  │
       ┌──────────┼──────────┐
       ↓          ↓          ↓
      AI         GIT       TESTS
       │          │          │
       └──────────┼──────────┘
                  ↓
             VERIFICATION
                  │
                  ↓
                COMMIT
```

That's the UX loop we want.

---

## Next: **Visual Design System + Micro-interactions**

Now that the shell and editor behavior are defined, the next step should be to make the entire product **visually coherent and polished** rather than styling each widget independently.

We'll implement actual code for:

* design tokens
* spacing scale
* typography hierarchy
* surfaces/elevation
* borders
* icon sizing
* semantic colors
* dark/light themes
* buttons
* inputs
* dropdowns
* tooltips
* badges
* chips
* empty states
* loading states
* skeletons
* hover/pressed/focus states
* motion tokens
* notification/toast system
* consistent `AppButton`, `AppIconButton`, `AppChip`, `AppPanel`, `AppDialog`
* and accessibility/focus styling.

That will give the GUI the final **“this feels like a real product”** layer rather than just a technically complete interface.



Excellent. **Next: the visual design system.**

At this point, we should stop styling individual screens ad hoc. Build one reusable system so the entire Aljabr UI feels like one product.

---

# 1. Design tokens first

Create:

```text
lib/
└── design/
    ├── tokens/
    │   ├── colors.dart
    │   ├── spacing.dart
    │   ├── radii.dart
    │   ├── typography.dart
    │   ├── elevation.dart
    │   └── motion.dart
    │
    ├── theme/
    │   ├── app_theme.dart
    │   └── app_theme_extensions.dart
    │
    └── widgets/
        ├── app_button.dart
        ├── app_icon_button.dart
        ├── app_panel.dart
        ├── app_chip.dart
        ├── app_badge.dart
        ├── app_tooltip.dart
        └── app_divider.dart
```

The principle:

```text
Screen
  ↓
Reusable component
  ↓
Design token
```

Not:

```text
Screen
  ↓
random padding/color/font
```

---

# 2. Spacing system

Use a small scale.

```dart
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}
```

Then:

```dart
padding: const EdgeInsets.all(
  AppSpacing.lg,
)
```

instead of:

```dart
padding: const EdgeInsets.all(17)
```

---

# 3. Radii

```dart
abstract final class AppRadii {
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double pill = 999;
}
```

Use:

```dart
BorderRadius.circular(
  AppRadii.lg,
)
```

for most cards and controls.

---

# 4. Typography

Create semantic styles rather than arbitrary font sizes.

```dart
abstract final class AppTypography {
  static const double body = 13;
  static const double bodySmall = 12;

  static const double label = 11;

  static const double title = 15;
  static const double heading = 18;

  static const double display = 24;

  static const double code = 13;
}
```

Then:

```dart
Text(
  'Verification',
  style: AppTextStyles.sectionTitle,
)
```

rather than:

```dart
TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
)
```

everywhere.

---

# 5. Text styles

```dart
abstract final class AppTextStyles {
  static const sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 13,
    height: 1.45,
  );

  static const secondary = TextStyle(
    fontSize: 12,
  );

  static const caption = TextStyle(
    fontSize: 11,
  );

  static const code = TextStyle(
    fontSize: 13,
    fontFamily: 'JetBrains Mono',
  );
}
```

---

# 6. Semantic colors

Don't scatter colors throughout the application.

```dart
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color accent;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated:
          surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary:
          textPrimary ?? this.textPrimary,
      textSecondary:
          textSecondary ?? this.textSecondary,
      textMuted:
          textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(
    ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      background:
          Color.lerp(background, other.background, t)!,
      surface:
          Color.lerp(surface, other.surface, t)!,
      surfaceElevated:
          Color.lerp(
            surfaceElevated,
            other.surfaceElevated,
            t,
          )!,
      border:
          Color.lerp(border, other.border, t)!,
      textPrimary:
          Color.lerp(
            textPrimary,
            other.textPrimary,
            t,
          )!,
      textSecondary:
          Color.lerp(
            textSecondary,
            other.textSecondary,
            t,
          )!,
      textMuted:
          Color.lerp(
            textMuted,
            other.textMuted,
            t,
          )!,
      accent:
          Color.lerp(accent, other.accent, t)!,
      success:
          Color.lerp(success, other.success, t)!,
      warning:
          Color.lerp(warning, other.warning, t)!,
      error:
          Color.lerp(error, other.error, t)!,
      info:
          Color.lerp(info, other.info, t)!,
    );
  }
}
```

---

# 7. Dark theme

For an IDE, avoid pure black everywhere.

Use layered surfaces:

```text
background
   ↓
surface
   ↓
surfaceElevated
   ↓
overlay
```

Example:

```dart
const darkColors = AppColors(
  background: Color(0xFF0F1115),
  surface: Color(0xFF15181E),
  surfaceElevated: Color(0xFF1B1F27),
  border: Color(0xFF292E38),

  textPrimary: Color(0xFFE8EBF0),
  textSecondary: Color(0xFFA8AFBB),
  textMuted: Color(0xFF707784),

  accent: Color(0xFF7C8CFF),

  success: Color(0xFF55C98A),
  warning: Color(0xFFE4B45C),
  error: Color(0xFFE06C75),
  info: Color(0xFF67B7E8),
);
```

The important part is **contrast hierarchy**, not flashy colors.

---

# 8. Light theme

```dart
const lightColors = AppColors(
  background: Color(0xFFF7F8FA),
  surface: Color(0xFFFFFFFF),
  surfaceElevated: Color(0xFFFFFFFF),
  border: Color(0xFFE1E4E8),

  textPrimary: Color(0xFF1B1F24),
  textSecondary: Color(0xFF5E6672),
  textMuted: Color(0xFF8A929E),

  accent: Color(0xFF5865D8),

  success: Color(0xFF2F9E68),
  warning: Color(0xFFB77A17),
  error: Color(0xFFC84D58),
  info: Color(0xFF3584B5),
);
```

---

# 9. Theme helper

Make colors easy to access.

```dart
extension AppThemeContext on BuildContext {
  AppColors get colors =>
      Theme.of(context)
          .extension<AppColors>()!;
}
```

Now:

```dart
Container(
  color: context.colors.surface,
)
```

---

# 10. Application theme

```dart
class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,

      scaffoldBackgroundColor:
          darkColors.background,

      extensions: const [
        darkColors,
      ],

      useMaterial3: true,
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,

      scaffoldBackgroundColor:
          lightColors.background,

      extensions: const [
        lightColors,
      ],

      useMaterial3: true,
    );
  }
}
```

---

# 11. Panels

Now create the most frequently used component.

```dart
class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  const AppPanel({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.all(AppSpacing.lg),
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: elevated
            ? context.colors.surfaceElevated
            : context.colors.surface,

        border: Border.all(
          color: context.colors.border,
        ),

        borderRadius: BorderRadius.circular(
          AppRadii.lg,
        ),
      ),
      child: child,
    );
  }
}
```

Now:

```dart
AppPanel(
  child: AgentTaskCard(),
)
```

---

# 12. Buttons

Create one canonical button.

```dart
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}
```

```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15),
          const SizedBox(
            width: AppSpacing.sm,
          ),
        ],
        Text(label),
      ],
    );

    return switch (variant) {
      AppButtonVariant.primary =>
        FilledButton(
          onPressed: onPressed,
          child: child,
        ),

      AppButtonVariant.secondary =>
        OutlinedButton(
          onPressed: onPressed,
          child: child,
        ),

      AppButtonVariant.ghost =>
        TextButton(
          onPressed: onPressed,
          child: child,
        ),

      AppButtonVariant.danger =>
        FilledButton(
          onPressed: onPressed,
          child: child,
        ),
    };
  }
}
```

---

# 13. Icon buttons

IDE interfaces need a lot of icon buttons.

```dart
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool selected;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        isSelected: selected,
        icon: Icon(icon, size: 17),
      ),
    );
  }
}
```

Usage:

```dart
AppIconButton(
  icon: Icons.refresh,
  tooltip: 'Refresh Explorer',
  onPressed: refresh,
)
```

---

# 14. Tooltip rule

Every icon-only action should have:

```text
icon
+
tooltip
+
keyboard shortcut where applicable
```

Example:

```text
↻
Refresh Explorer
Ctrl/Cmd + R
```

Not:

```text
↻
```

with no discoverability.

---

# 15. Badges

```dart
class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const AppBadge({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (color ?? context.colors.accent)
            .withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(
          AppRadii.pill,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption,
      ),
    );
  }
}
```

Examples:

```text
M
2 problems
AI
3 changes
```

---

# 16. Chips

For Agent context:

```dart
class AppChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const AppChip({
    super.key,
    required this.label,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted:
          onRemove == null ? null : onRemove,
    );
  }
}
```

Then:

```text
[AuthService.java ×]
[SessionService.java ×]
```

---

# 17. Focus states

This is one of the most overlooked UX details.

Every interactive control should have:

```text
normal
hover
pressed
focused
disabled
```

Don't rely only on color changes.

Create:

```dart
class AppFocusBorder extends StatelessWidget {
  final bool focused;
  final Widget child;

  const AppFocusBorder({
    super.key,
    required this.focused,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: focused
              ? context.colors.accent
              : Colors.transparent,
          width: 1,
        ),
        borderRadius:
            BorderRadius.circular(
          AppRadii.md,
        ),
      ),
      child: child,
    );
  }
}
```

---

# 18. Keyboard focus

For desktop, add a visible focus ring.

```dart
FocusableActionDetector(
  onFocusChange: (focused) {
    // update visual state
  },
  child: ...
)
```

This matters especially for:

```text
Command Palette
Agent controls
Explorer
Tabs
Dialogs
```

---

# 19. Hover behavior

Don't make hover dramatically change the UI.

Good:

```text
normal:
    transparent

hover:
    subtle surface highlight

selected:
    stronger surface + accent indicator
```

Avoid:

```text
hover:
    giant color transformation
```

---

# 20. Activity rail selection

Use a small accent marker:

```text
│
│ ▌ Explorer
│
│   Agent
│
│   Git
│
```

Rather than turning the entire button into a giant colored rectangle.

---

# 21. Tabs

Polished tab states:

```text
normal
────────────────
AuthService.java

hover
────────────────
AuthService.java    ×

active
────────────────
│ AuthService.java ●
```

Implementation:

```dart
class EditorTabButton extends StatelessWidget {
  final String title;
  final bool active;
  final bool dirty;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const EditorTabButton({
    super.key,
    required this.title,
    required this.active,
    required this.dirty,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? context.colors.surface
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Row(
            children: [
              if (dirty)
                const Padding(
                  padding: EdgeInsets.only(
                    right: 6,
                  ),
                  child: Text('●'),
                ),

              Text(title),

              const SizedBox(width: 6),

              AppIconButton(
                icon: Icons.close,
                tooltip: 'Close',
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

# 22. Notifications

Don't use dialogs for everything.

Create a notification service:

```dart
enum NotificationType {
  info,
  success,
  warning,
  error,
}
```

```dart
class AppNotification {
  final String title;
  final String? message;
  final NotificationType type;

  const AppNotification({
    required this.title,
    this.message,
    this.type = NotificationType.info,
  });
}
```

---

# 23. Toasts

For example:

```text
┌─────────────────────────────────┐
│ ✓ Changes applied               │
│ 3 files updated                 │
│                                 │
│ Undo                            │
└─────────────────────────────────┘
```

Important actions should provide an undo path whenever possible.

---

# 24. Toast manager

```dart
class NotificationManager
    extends ChangeNotifier {

  final List<AppNotification> _items = [];

  List<AppNotification> get items =>
      List.unmodifiable(_items);

  void show(
    AppNotification notification,
  ) {
    _items.add(notification);
    notifyListeners();
  }

  void dismiss(
    AppNotification notification,
  ) {
    _items.remove(notification);
    notifyListeners();
  }
}
```

---

# 25. Loading states

Avoid a screen full of spinners.

Bad:

```text
Loading...
```

Better:

```text
Agent
─────────────────────────────

Planning changes...

○ Inspecting files
● Building plan
○ Preparing changes
```

For verification:

```text
Verification

✓ Compile
● Unit tests
○ Integration tests
```

This communicates progress.

---

# 26. Skeletons

For panels that load data:

```dart
class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<AppSkeleton> createState() =>
      _AppSkeletonState();
}
```

Keep skeletons simple.

Use them for:

```text
Agent history
Git history
Search results
Verification results
```

---

# 27. Empty states

Standardize them.

```dart
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: context.colors.textMuted,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              title,
              style:
                  AppTextStyles.sectionTitle,
            ),

            if (description != null) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                description!,
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.secondary,
              ),
            ],

            if (action != null) ...[
              const SizedBox(
                height: AppSpacing.lg,
              ),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

---

# 28. Dialogs

Use dialogs only for decisions that deserve interruption.

Good:

```text
Discard unsaved changes?
```

Bad:

```text
File saved.
```

That should be a toast.

---

# 29. Confirmation dialog

```dart
Future<bool?> showAppConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: 'Cancel',
            variant:
                AppButtonVariant.ghost,
            onPressed: () =>
                Navigator.pop(context, false),
          ),
          AppButton(
            label: confirmLabel,
            variant:
                AppButtonVariant.primary,
            onPressed: () =>
                Navigator.pop(context, true),
          ),
        ],
      );
    },
  );
}
```

---

# 30. Motion tokens

Centralize animation timing.

```dart
abstract final class AppMotion {
  static const Duration instant =
      Duration(milliseconds: 80);

  static const Duration fast =
      Duration(milliseconds: 140);

  static const Duration normal =
      Duration(milliseconds: 180);

  static const Duration slow =
      Duration(milliseconds: 260);

  static const Curve standard =
      Curves.easeOutCubic;
}
```

Then:

```dart
AnimatedContainer(
  duration: AppMotion.normal,
  curve: AppMotion.standard,
)
```

---

# 31. Micro-interaction rules

Use:

### 80ms

Immediate feedback.

### 140ms

Hover, button state, small UI.

### 180ms

Panel transitions.

### 260ms

Larger overlay transitions.

Never make routine interactions feel sluggish.

---

# 32. Reduced motion

Respect accessibility.

```dart
final reduceMotion =
    MediaQuery.of(context)
        .disableAnimations;
```

Then:

```dart
final duration = reduceMotion
    ? Duration.zero
    : AppMotion.normal;
```

---

# 33. Divider

Don't repeatedly create custom borders.

```dart
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.border,
    );
  }
}
```

---

# 34. Surface hierarchy

Now establish a strict rule:

```text
Level 0
background

Level 1
panel

Level 2
elevated panel

Level 3
popover

Level 4
modal
```

Example:

```text
Editor
 └── Agent panel
      └── Context popover
           └── Confirmation dialog
```

Each level should feel visually above the previous one.

---

# 35. Avoid excessive cards

This is a major polish point.

Don't do:

```text
┌──────────────┐
│ ┌──────────┐ │
│ │ ┌──────┐ │ │
│ │ │ text │ │ │
│ │ └──────┘ │ │
│ └──────────┘ │
└──────────────┘
```

Use flat surfaces and separators.

Cards should communicate actual grouping, not decorate every piece of content.

---

# 36. Density

Aljabr is an IDE.

Default density should be:

```text
compact
```

rather than consumer-app spacing.

For example:

```dart
const double rowHeight = 32;
```

for Explorer rows.

Tabs:

```dart
const double tabHeight = 36;
```

Activity rail:

```dart
const double activityItemSize = 40;
```

---

# 37. Explorer row

```dart
class ExplorerRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const ExplorerRow({
    super.key,
    required this.label,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Material(
        color: selected
            ? context.colors.surfaceElevated
            : Colors.transparent,
        child: InkWell(
          child: Row(
            children: [
              const SizedBox(width: 8),

              Icon(
                icon,
                size: 16,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

# 38. Context menus

Right click should feel native.

Create:

```dart
class AppContextMenuItem {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onPressed;
  final bool destructive;

  const AppContextMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.onPressed,
    this.destructive = false,
  });
}
```

Example:

```text
Open
Open to the Side
──────────────
Rename
Delete
──────────────
Copy Path
Copy Relative Path
──────────────
Git
  Compare with HEAD
  Stage
──────────────
AI
  Explain
  Add to Context
```

---

# 39. Command palette polish

The command palette should become the **universal interaction layer**.

```text
┌────────────────────────────────────────────┐
│ > refactor authentication                  │
├────────────────────────────────────────────┤
│ ✦ Refactor Selection                       │
│   Agent                                     │
│                                             │
│   Refactor File                             │
│   Agent                                     │
│                                             │
│   Refactor Workspace                        │
│   Agent                                     │
└────────────────────────────────────────────┘
```

Show:

```text
icon
title
category
shortcut
```

---

# 40. Command result component

```dart
class CommandResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? category;
  final String? shortcut;
  final bool selected;

  const CommandResultTile({
    super.key,
    required this.icon,
    required this.title,
    this.category,
    this.shortcut,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: selected
            ? context.colors.surfaceElevated
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          AppRadii.md,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Text(title),
          ),

          if (category != null)
            Text(
              category!,
              style:
                  AppTextStyles.caption,
            ),

          if (shortcut != null) ...[
            const SizedBox(
              width: AppSpacing.md,
            ),
            AppBadge(
              label: shortcut!,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

# 41. The design system now becomes the foundation

Your widgets should increasingly look like:

```dart
AppPanel(...)
AppButton(...)
AppIconButton(...)
AppChip(...)
AppBadge(...)
AppEmptyState(...)
AppDivider(...)
```

instead of directly using Material widgets everywhere.

That gives you one place to change the entire product.

---

# 42. Accessibility baseline

Add these rules now, not later:

```text
✓ Keyboard reachable
✓ Visible focus
✓ Tooltips for icon-only controls
✓ Minimum click target ~32–40px
✓ Don't communicate state with color alone
✓ Respect reduced motion
✓ Text remains readable at larger scale
✓ Errors have text/icons, not only red
```

---

# 43. Final visual hierarchy

The product should visually read like:

```text
                 ALJABR
                    │
       ┌────────────┼────────────┐
       │            │            │
    Navigation     Work         Status
       │            │            │
       │          Editor         │
       │            │            │
       │       ┌────┴────┐       │
       │       │         │       │
      Git      AI      Verify   Health
```

The **editor remains visually dominant**.

AI assists the workflow rather than becoming a competing interface.

---

# 44. Next actual implementation target

Now the system is ready for the next major UX layer:

```text
             USER ACTION
                  │
                  ▼
          ┌───────────────┐
          │ ActionRegistry│
          └───────┬───────┘
                  │
       ┌──────────┼───────────┐
       ▼          ▼           ▼
     Editor      Agent       Git
       │          │           │
       └──────────┼───────────┘
                  ▼
             ChangeSet
                  │
                  ▼
               Review
                  │
                  ▼
             Verification
                  │
                  ▼
              Workspace
```

**Next I would implement the actual AI interaction layer:** the Agent task composer, streaming responses, tool/activity timeline, context management, approval gates, ChangeSet review UI, inline AI operations, cancellation, retry, and recovery states.

That is where Aljabr starts feeling fundamentally different from a normal IDE with a chatbot bolted onto the side.



## Next: the Agent interaction layer

Now we turn the AI from a side panel into a **proper task system**.

The UX should be:

```text
User intent
    ↓
Compose task
    ↓
Build context
    ↓
Plan
    ↓
Execute
    ↓
Show activity
    ↓
Propose ChangeSet
    ↓
User reviews
    ↓
Apply
    ↓
Verify
```

The critical rule: **the Agent should never feel like a black box.**

---

# 1. Agent domain model

Create:

```text
lib/
└── agent/
    ├── models/
    │   ├── agent_task.dart
    │   ├── agent_step.dart
    │   ├── agent_event.dart
    │   ├── agent_context.dart
    │   └── agent_result.dart
    │
    ├── services/
    │   ├── agent_service.dart
    │   ├── agent_context_service.dart
    │   └── agent_stream_service.dart
    │
    └── presentation/
        ├── agent_panel.dart
        ├── agent_composer.dart
        ├── agent_timeline.dart
        ├── agent_step_tile.dart
        └── agent_result.dart
```

---

# 2. Agent task

```dart
enum AgentTaskStatus {
  draft,
  planning,
  running,
  waitingForApproval,
  applying,
  verifying,
  completed,
  failed,
  cancelled,
}
```

```dart
class AgentTask {
  final String id;
  final String prompt;

  final AgentTaskStatus status;

  final List<AgentContextItem> context;

  final List<AgentStep> steps;

  final String? changeSetId;

  final String? error;

  const AgentTask({
    required this.id,
    required this.prompt,
    this.status = AgentTaskStatus.draft,
    this.context = const [],
    this.steps = const [],
    this.changeSetId,
    this.error,
  });

  AgentTask copyWith({
    AgentTaskStatus? status,
    List<AgentContextItem>? context,
    List<AgentStep>? steps,
    String? changeSetId,
    String? error,
  }) {
    return AgentTask(
      id: id,
      prompt: prompt,
      status: status ?? this.status,
      context: context ?? this.context,
      steps: steps ?? this.steps,
      changeSetId:
          changeSetId ?? this.changeSetId,
      error: error ?? this.error,
    );
  }
}
```

---

# 3. Agent steps

The user should be able to see what the Agent is doing.

```dart
enum AgentStepType {
  planning,
  search,
  readFile,
  analyze,
  edit,
  command,
  test,
  verification,
  message,
}
```

```dart
enum AgentStepStatus {
  pending,
  running,
  completed,
  failed,
  skipped,
}
```

```dart
class AgentStep {
  final String id;

  final AgentStepType type;

  final String title;

  final String? detail;

  final AgentStepStatus status;

  final DateTime createdAt;

  const AgentStep({
    required this.id,
    required this.type,
    required this.title,
    this.detail,
    this.status =
        AgentStepStatus.pending,
    required this.createdAt,
  });
}
```

---

# 4. The Agent timeline

Instead of:

```text
Thinking...
```

show useful activity:

```text
Agent
────────────────────────────

✓ Planning task

✓ Search
  8 files matched

✓ Read
  AuthService.java

● Analyze
  Finding authentication flow

○ Edit
○ Tests
○ Verification
```

This gives the user confidence without exposing internal chain-of-thought.

---

# 5. Timeline widget

```dart
class AgentTimeline extends StatelessWidget {
  final List<AgentStep> steps;

  const AgentTimeline({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final step in steps)
          AgentStepTile(step: step),
      ],
    );
  }
}
```

---

# 6. Step tile

```dart
class AgentStepTile extends StatelessWidget {
  final AgentStep step;

  const AgentStepTile({
    super.key,
    required this.step,
  });

  IconData get icon {
    switch (step.status) {
      case AgentStepStatus.completed:
        return Icons.check;

      case AgentStepStatus.running:
        return Icons.more_horiz;

      case AgentStepStatus.failed:
        return Icons.close;

      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 15,
            color: _color(context),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(step.title),

                if (step.detail != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 2,
                    ),
                    child: Text(
                      step.detail!,
                      style:
                          AppTextStyles.secondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _color(BuildContext context) {
    switch (step.status) {
      case AgentStepStatus.completed:
        return context.colors.success;

      case AgentStepStatus.failed:
        return context.colors.error;

      case AgentStepStatus.running:
        return context.colors.accent;

      default:
        return context.colors.textMuted;
    }
  }
}
```

---

# 7. Composer

The composer should be the primary interaction.

```text
┌──────────────────────────────────────────────┐
│ Ask Aljabr to change something...            │
│                                              │
│                                              │
│ [＋ Context] [Mode ▾]                 [Run →] │
└──────────────────────────────────────────────┘
```

Don't make it look like a generic chat box.

It's a **task composer**.

---

# 8. Composer model

```dart
class AgentComposerState {
  final String prompt;

  final List<AgentContextItem> context;

  final AgentMode mode;

  const AgentComposerState({
    this.prompt = '',
    this.context = const [],
    this.mode = AgentMode.ask,
  });

  bool get canSubmit =>
      prompt.trim().isNotEmpty;
}
```

---

# 9. Agent modes

Keep the number small.

```dart
enum AgentMode {
  ask,
  edit,
  review,
}
```

UX:

```text
Ask
    Understand / explain

Edit
    Modify code

Review
    Inspect changes / problems
```

Don't expose ten different agent modes.

---

# 10. Composer widget

```dart
class AgentComposer extends StatefulWidget {
  final Future<void> Function(
    String prompt,
    List<AgentContextItem> context,
  ) onSubmit;

  const AgentComposer({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AgentComposer> createState() =>
      _AgentComposerState();
}
```

Implementation:

```dart
class _AgentComposerState
    extends State<AgentComposer> {

  final controller =
      TextEditingController();

  final focusNode = FocusNode();

  final List<AgentContextItem> context = [];

  bool submitting = false;

  Future<void> submit() async {
    final prompt =
        controller.text.trim();

    if (prompt.isEmpty || submitting) {
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      await widget.onSubmit(
        prompt,
        List.unmodifiable(context),
      );

      controller.clear();
      context.clear();
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 6,
            minLines: 3,
            decoration:
                const InputDecoration(
              hintText:
                  'Ask Aljabr to change something...',
              border: InputBorder.none,
            ),
            onSubmitted: (_) => submit(),
          ),

          const AppDivider(),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Row(
            children: [
              AppButton(
                label: 'Context',
                icon: Icons.add,
                variant:
                    AppButtonVariant.ghost,
                onPressed: () {
                  // open context picker
                },
              ),

              const Spacer(),

              AppButton(
                label: submitting
                    ? 'Running...'
                    : 'Run',
                icon: Icons.arrow_forward,
                variant:
                    AppButtonVariant.primary,
                onPressed:
                    submitting ? null : submit,
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

# 11. Keyboard shortcut

The primary action should have:

```text
Cmd/Ctrl + Enter
```

Add:

```dart
Shortcuts(
  shortcuts: const {
    SingleActivator(
      LogicalKeyboardKey.enter,
      control: true,
    ): SubmitAgentIntent(),
  },
  child: Actions(
    actions: {
      SubmitAgentIntent:
          CallbackAction<SubmitAgentIntent>(
        onInvoke: (_) {
          submit();
          return null;
        },
      ),
    },
    child: ...
  ),
)
```

On macOS you can additionally map Command.

---

# 12. Context picker

Click:

```text
+ Context
```

and show:

```text
┌────────────────────────────────────┐
│ Add context                        │
├────────────────────────────────────┤
│ Search files...                    │
│                                    │
│ Current file                       │
│ ✓ AuthService.java                 │
│                                    │
│ Related                             │
│   SessionService.java              │
│   AuthServiceTest.java             │
│                                    │
│ Git                                 │
│   Current changes                  │
└────────────────────────────────────┘
```

---

# 13. Context chips

After adding:

```text
[AuthService.java ×]
[AuthServiceTest.java ×]
```

These appear directly above the composer.

---

# 14. Smart context

When the user invokes Agent from selected code:

```text
Fix this nullability issue
```

automatically include:

```text
AuthService.java:81-84
```

rather than forcing the user to manually add it.

---

# 15. Agent execution controller

Now connect the UI to the backend.

```dart
class AgentController
    extends ChangeNotifier {

  AgentTask? _task;

  AgentTask? get task => _task;

  Future<void> run({
    required String prompt,
    required List<AgentContextItem> context,
  }) async {

    final task = AgentTask(
      id: _newId(),
      prompt: prompt,
      context: context,
      status: AgentTaskStatus.planning,
    );

    _task = task;
    notifyListeners();

    try {
      await _execute(task);
    } catch (error) {
      _task = _task!.copyWith(
        status: AgentTaskStatus.failed,
        error: error.toString(),
      );

      notifyListeners();
    }
  }

  Future<void> _execute(
    AgentTask task,
  ) async {
    // next stage
  }

  String _newId() =>
      DateTime.now()
          .microsecondsSinceEpoch
          .toString();
}
```

---

# 16. Streaming events

Don't wait until the entire task finishes.

Create:

```dart
Stream<AgentEvent> execute(
  AgentTask task,
);
```

Events:

```dart
sealed class AgentEvent {}

class StepStarted extends AgentEvent {
  final AgentStep step;

  StepStarted(this.step);
}

class StepCompleted extends AgentEvent {
  final String stepId;

  StepCompleted(this.stepId);
}

class ChangeSetCreated extends AgentEvent {
  final String changeSetId;

  ChangeSetCreated(this.changeSetId);
}

class VerificationStarted
    extends AgentEvent {}

class AgentCompleted
    extends AgentEvent {}
```

---

# 17. Why streaming matters

Without streaming:

```text
User
 ↓
[loading 20 seconds]
 ↓
result
```

With streaming:

```text
User
 ↓
Planning
 ↓
Search
 ↓
Read
 ↓
Analyze
 ↓
Changes ready
```

The perceived latency is dramatically better.

---

# 18. Approval gate

This is critical.

The Agent should stop before applying meaningful changes.

State:

```text
waitingForApproval
```

UI:

```text
┌─────────────────────────────────────────┐
│ Changes ready                           │
│                                         │
│ 4 files changed                         │
│ +126 / -41 lines                        │
│                                         │
│ ✓ Tests identified                      │
│ ✓ No compile errors                     │
│                                         │
│ [Review Changes]     [Apply Changes]    │
└─────────────────────────────────────────┘
```

---

# 19. Agent result

```dart
class AgentResult {
  final String summary;

  final String? changeSetId;

  final List<String> affectedFiles;

  final bool verificationPassed;

  const AgentResult({
    required this.summary,
    this.changeSetId,
    this.affectedFiles = const [],
    this.verificationPassed = false,
  });
}
```

---

# 20. Result component

```dart
class AgentResultCard extends StatelessWidget {
  final AgentResult result;
  final VoidCallback? onReview;
  final VoidCallback? onApply;

  const AgentResultCard({
    super.key,
    required this.result,
    this.onReview,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      elevated: true,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Changes ready',
            style:
                AppTextStyles.sectionTitle,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            result.summary,
            style: AppTextStyles.body,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          AppBadge(
            label:
                '${result.affectedFiles.length} files',
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              AppButton(
                label: 'Review Changes',
                onPressed: onReview,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              AppButton(
                label: 'Apply Changes',
                variant:
                    AppButtonVariant.primary,
                onPressed: onApply,
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

# 21. Cancellation

Never force the user to wait.

While running:

```text
● Analyzing authentication flow

[Cancel]
```

Controller:

```dart
class AgentController
    extends ChangeNotifier {

  bool _cancelRequested = false;

  void cancel() {
    _cancelRequested = true;
  }

  bool get isCancelled =>
      _cancelRequested;
}
```

The actual service should propagate cancellation through the execution pipeline.

---

# 22. Retry

If something fails:

```text
┌─────────────────────────────────────┐
│ Agent couldn't complete the task.   │
│                                     │
│ Verification failed after changes.  │
│                                     │
│ [Retry] [Review Changes] [Dismiss]  │
└─────────────────────────────────────┘
```

Don't simply show:

```text
Error: 500
```

---

# 23. Recovery states

Model them explicitly:

```dart
enum AgentRecoveryAction {
  retry,
  revisePrompt,
  reviewPartialChanges,
  discard,
}
```

This gives the user a way forward.

---

# 24. Partial completion

Suppose:

```text
4 files requested
3 successfully modified
1 failed
```

Do **not** pretend the task failed entirely.

Show:

```text
Partially completed

✓ AuthService.java
✓ SessionService.java
✓ AuthServiceTest.java
✕ OAuthConfig.java

[Review Changes]
[Retry Failed Step]
```

This is a much more honest UX.

---

# 25. Agent panel layout

Final structure:

```text
┌─────────────────────────────────────────┐
│ Agent                              ⋯    │
├─────────────────────────────────────────┤
│                                         │
│ User                                    │
│ Fix the refresh token handling.         │
│                                         │
│ Context                                 │
│ [AuthService.java ×]                    │
│ [AuthServiceTest.java ×]                │
│                                         │
│ ✓ Planning                              │
│ ✓ Search 8 files                        │
│ ✓ Analyze authentication flow           │
│ ✓ Generate changes                      │
│                                         │
│ Changes ready                           │
│ 3 files · +42 / -17                     │
│                                         │
│ [Review Changes] [Apply Changes]        │
│                                         │
├─────────────────────────────────────────┤
│ Ask Aljabr...                           │
│                              [Run →]     │
└─────────────────────────────────────────┘
```

---

# 26. Agent history

Don't make the panel only represent the current task.

Add:

```text
Agent
───────────────
Current Task

History
  Fix authentication
  Add tests
  Refactor session
  Review OAuth flow
```

Each task should be recoverable.

---

# 27. Task history model

```dart
class AgentTaskSummary {
  final String id;
  final String title;
  final AgentTaskStatus status;
  final DateTime createdAt;

  const AgentTaskSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });
}
```

---

# 28. Rename tasks automatically

Instead of:

```text
Task #1293
```

derive a short title:

```text
Fix authentication refresh
```

or:

```text
Add refresh-session tests
```

The title should be editable.

---

# 29. Agent task lifecycle

The final state machine:

```text
                  ┌────────────┐
                  │    DRAFT   │
                  └─────┬──────┘
                        ↓
                  ┌────────────┐
                  │  PLANNING  │
                  └─────┬──────┘
                        ↓
                  ┌────────────┐
                  │  RUNNING   │
                  └─────┬──────┘
                        ↓
             ┌──────────────────────┐
             │ WAITING FOR APPROVAL │
             └──────────┬───────────┘
                        ↓
                  ┌────────────┐
                  │  APPLYING   │
                  └─────┬──────┘
                        ↓
                  ┌────────────┐
                  │ VERIFYING  │
                  └─────┬──────┘
                        ↓
                  ┌────────────┐
                  │ COMPLETED  │
                  └────────────┘

Any stage:
    ↓
CANCELLED / FAILED
```

---

# 30. The most important UX principle

The Agent should never make the user wonder:

> "What is it doing?"

Instead:

```text
What I asked
      ↓
What it is doing
      ↓
What it changed
      ↓
What it wants me to approve
      ↓
Whether it actually works
```

That becomes the core Aljabr experience.

---

## Next

The next implementation should connect this Agent layer to the **ChangeSet / Diff / Review system** we already designed.

That means building the actual flow:

```text
Agent
  ↓
ChangeSet
  ↓
Diff engine
  ↓
Inline + side-by-side diff
  ↓
Per-file review
  ↓
Per-hunk accept/reject
  ↓
Apply transaction
  ↓
Undo
  ↓
Verification
  ↓
Agent reports result
```

That is the next major piece because it turns the Agent from **"AI that talks"** into **"AI that safely changes the project."**


## Next: ChangeSet → Diff → Review → Apply

This is the **safety-critical UX layer**. The Agent can propose changes, but the user should remain completely in control of what enters the working tree.

The flow becomes:

```text
Agent
  │
  ▼
ChangeSet
  │
  ├── File A
  ├── File B
  └── File C
       │
       ▼
     Diff
       │
       ▼
   User Review
       │
   ┌───┴────┐
   ▼        ▼
Accept    Reject
   │
   ▼
Transaction
   │
   ▼
Verification
   │
   ▼
Success / Recovery
```

---

# 1. ChangeSet model

Create:

```text id="8z3v1f"
lib/
└── changes/
    ├── models/
    │   ├── change_set.dart
    │   ├── file_change.dart
    │   ├── diff_hunk.dart
    │   └── change_operation.dart
    │
    ├── services/
    │   ├── change_set_service.dart
    │   ├── diff_service.dart
    │   └── apply_service.dart
    │
    └── presentation/
        ├── change_set_view.dart
        ├── file_change_tile.dart
        ├── diff_view.dart
        ├── diff_hunk.dart
        └── review_toolbar.dart
```

---

# 2. Change origin

We need attribution.

```dart id="x8g5hm"
enum ChangeOrigin {
  user,
  agent,
  formatter,
  refactor,
  generated,
  unknown,
}
```

---

# 3. File change

```dart id="8qrxuy"
enum FileChangeType {
  modified,
  added,
  deleted,
  renamed,
}
```

```dart id="a2d4g6"
class FileChange {
  final String path;

  final String? oldPath;

  final FileChangeType type;

  final String before;

  final String after;

  final ChangeOrigin origin;

  const FileChange({
    required this.path,
    this.oldPath,
    required this.type,
    required this.before,
    required this.after,
    this.origin = ChangeOrigin.agent,
  });

  int get additions {
    // Replace with actual diff calculation.
    return 0;
  }

  int get deletions {
    return 0;
  }
}
```

---

# 4. ChangeSet

```dart id="i4t9se"
enum ChangeSetStatus {
  proposed,
  reviewing,
  partiallyAccepted,
  accepted,
  rejected,
  applied,
  failed,
}
```

```dart id="3y2e3u"
class ChangeSet {
  final String id;

  final String title;

  final String? description;

  final List<FileChange> files;

  final ChangeSetStatus status;

  final String? agentTaskId;

  const ChangeSet({
    required this.id,
    required this.title,
    this.description,
    this.files = const [],
    this.status =
        ChangeSetStatus.proposed,
    this.agentTaskId,
  });

  int get fileCount => files.length;
}
```

---

# 5. Hunk model

A file can have multiple independent changes.

```dart id="gr8rr4"
enum HunkStatus {
  unchanged,
  pending,
  accepted,
  rejected,
}
```

```dart id="shyxx3"
class DiffHunk {
  final String id;

  final int oldStart;
  final int oldCount;

  final int newStart;
  final int newCount;

  final List<DiffLine> lines;

  final HunkStatus status;

  const DiffHunk({
    required this.id,
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.lines,
    this.status = HunkStatus.pending,
  });
}
```

---

# 6. Diff line

```dart id="w3ah69"
enum DiffLineType {
  context,
  addition,
  deletion,
}
```

```dart id="d4yn7w"
class DiffLine {
  final DiffLineType type;

  final String content;

  final int? oldLine;

  final int? newLine;

  const DiffLine({
    required this.type,
    required this.content,
    this.oldLine,
    this.newLine,
  });
}
```

---

# 7. Don't calculate diffs inside widgets

Create a service:

```dart id="2v2c2e"
abstract interface class DiffService {
  List<DiffHunk> diff({
    required String before,
    required String after,
  });
}
```

Implementation can later use a proper diff library.

The UI should only receive:

```text id="sy2fiy"
DiffHunk[]
```

---

# 8. ChangeSet controller

```dart id="e6y8ny"
class ChangeSetController
    extends ChangeNotifier {

  ChangeSet _changeSet;

  ChangeSetController({
    required ChangeSet changeSet,
  }) : _changeSet = changeSet;

  ChangeSet get changeSet => _changeSet;

  void acceptFile(String path) {
    // update selected file
    notifyListeners();
  }

  void rejectFile(String path) {
    // update selected file
    notifyListeners();
  }

  void acceptHunk(String hunkId) {
    // update hunk
    notifyListeners();
  }

  void rejectHunk(String hunkId) {
    // update hunk
    notifyListeners();
  }
}
```

---

# 9. Review screen

The overall UI:

```text id="0tx8mx"
┌────────────────────────────────────────────────────────────┐
│ Review Changes                                             │
│                                                            │
│ 4 files changed                 +126  -41                   │
├──────────────────┬─────────────────────────────────────────┤
│ FILES            │ AuthService.java                        │
│                  │                                         │
│ ● AuthService    │ @@ -78,8 +78,11 @@                      │
│ ● SessionService │                                         │
│ ● AuthTest       │ - final token = ...                     │
│ ○ OAuthConfig    │ + final token = ...                     │
│                  │ + if (token == null) {                  │
│                  │ +   ...                                  │
│                  │                                         │
│                  │        [Accept] [Reject]                 │
├──────────────────┴─────────────────────────────────────────┤
│ [Reject All]                         [Accept All]           │
└────────────────────────────────────────────────────────────┘
```

---

# 10. File list

```dart id="2nljxk"
class ChangeFileList extends StatelessWidget {
  final List<FileChange> files;
  final String? selectedPath;
  final ValueChanged<String> onSelected;

  const ChangeFileList({
    super.key,
    required this.files,
    required this.selectedPath,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];

        return FileChangeTile(
          file: file,
          selected:
              file.path == selectedPath,
          onTap: () =>
              onSelected(file.path),
        );
      },
    );
  }
}
```

---

# 11. File change tile

```dart id="xk3t9r"
class FileChangeTile extends StatelessWidget {
  final FileChange file;
  final bool selected;
  final VoidCallback onTap;

  const FileChangeTile({
    super.key,
    required this.file,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.colors.surfaceElevated
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                _icon,
                size: 15,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Text(
                  file.path,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),

              AppBadge(
                label:
                    '+${file.additions}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (file.type) {
      case FileChangeType.added:
        return Icons.add;

      case FileChangeType.deleted:
        return Icons.remove;

      case FileChangeType.renamed:
        return Icons.drive_file_rename_outline;

      case FileChangeType.modified:
        return Icons.edit_outlined;
    }
  }
}
```

---

# 12. Diff view

The actual diff should be extremely readable.

```dart id="i6q8os"
class DiffView extends StatelessWidget {
  final List<DiffHunk> hunks;

  const DiffView({
    super.key,
    required this.hunks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final hunk in hunks)
          DiffHunkView(hunk: hunk),
      ],
    );
  }
}
```

---

# 13. Diff line rendering

```dart id="5l3g7q"
class DiffLineView extends StatelessWidget {
  final DiffLine line;

  const DiffLineView({
    super.key,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '${line.oldLine ?? ''}',
              textAlign: TextAlign.right,
              style: AppTextStyles.code,
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 44,
            child: Text(
              '${line.newLine ?? ''}',
              textAlign: TextAlign.right,
              style: AppTextStyles.code,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              line.content,
              style: AppTextStyles.code,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

# 14. Diff hunk toolbar

Every meaningful hunk should have contextual actions:

```text id="m9q1r4"
@@ refreshSession()

[Accept Hunk] [Reject Hunk] [Explain]
```

Don't make the user navigate to a global toolbar to accept one small change.

---

# 15. Hunk controller

```dart id="zzj25d"
void acceptHunk(String filePath, String hunkId) {
  final file = _findFile(filePath);

  final hunk = _findHunk(
    file,
    hunkId,
  );

  // mark accepted

  notifyListeners();
}
```

Eventually this should produce a new projected file state rather than directly writing to disk.

---

# 16. Projected state

This is important.

Before applying:

```text id="7p1td7"
Disk
  │
  ▼
Original file
  │
  ▼
ChangeSet
  │
  ▼
Projected file
```

The editor can show:

```text id="m95f4s"
working tree
+
pending AI changes
```

without actually modifying the filesystem yet.

---

# 17. Apply transaction

When the user clicks:

```text id="7f8n1g"
Apply Changes
```

create a transaction:

```dart id="qx5u2k"
class ChangeTransaction {
  final String id;

  final ChangeSet changeSet;

  final DateTime startedAt;

  const ChangeTransaction({
    required this.id,
    required this.changeSet,
    required this.startedAt,
  });
}
```

---

# 18. Apply service

```dart id="gqf0d2"
abstract interface class ChangeApplyService {
  Future<ApplyResult> apply(
    ChangeSet changeSet,
  );
}
```

```dart id="s8j49u"
class ApplyResult {
  final bool success;

  final List<String> appliedFiles;

  final List<String> failedFiles;

  final String? error;

  const ApplyResult({
    required this.success,
    this.appliedFiles = const [],
    this.failedFiles = const [],
    this.error,
  });
}
```

---

# 19. Never partially write silently

Suppose:

```text id="s8py4h"
AuthService.java      ✓
SessionService.java   ✓
OAuthConfig.java      ✕
```

The user must see:

```text id="l44k5k"
Changes partially applied

2 files updated.
1 file could not be updated.

[Review Failure]
[Undo Applied Changes]
```

Never hide this.

---

# 20. Undo transaction

Every Agent application should produce an undo record.

```dart id="q6w2in"
class AppliedChange {
  final String path;

  final String before;

  final String after;

  const AppliedChange({
    required this.path,
    required this.before,
    required this.after,
  });
}
```

Then:

```dart id="2bhj6t"
class UndoTransaction {
  final String id;

  final List<AppliedChange> changes;

  const UndoTransaction({
    required this.id,
    required this.changes,
  });
}
```

---

# 21. Toast after applying

```text id="t5d2gx"
✓ Changes applied

4 files updated
3 tests available

[Undo]
```

The Undo button should remain available for a meaningful period.

---

# 22. Apply → verify automatically

Don't end the Agent task at:

```text id="q4v6xm"
Changes applied.
```

Continue:

```text id="tqf0lv"
Applying
   ↓
Compiling
   ↓
Running related tests
   ↓
Analyzing results
```

---

# 23. Verification panel

```text id="k1q8sa"
Verification
──────────────────────────

✓ Formatting
✓ Compile
✓ AuthServiceTest
✓ SessionServiceTest

──────────────────────────

All checks passed.

[Done]
```

If something fails:

```text id="v4l4bw"
Verification failed

✓ Compile
✕ AuthServiceTest.refreshSession

Expected:
authenticated session

Received:
null

[Ask Agent to Fix]
[Open Failure]
```

---

# 24. Automatic repair loop

This is where Aljabr gets powerful.

If the user allows it:

```text id="gqpy9w"
Apply
 ↓
Verify
 ↓
Failure
 ↓
Agent analyzes failure
 ↓
New ChangeSet
 ↓
Review
 ↓
Apply
 ↓
Verify
```

But **never silently loop forever**.

Use a bounded policy:

```dart id="9z0e9d"
class RepairPolicy {
  final int maxAttempts;

  const RepairPolicy({
    this.maxAttempts = 2,
  });
}
```

---

# 25. Repair UX

```text id="4xk2w8"
Verification failed.

AuthServiceTest.refreshSession

Aljabr found a likely cause.

[View Explanation]

Suggested fix:
Update refresh-token handling.

[Review Fix]
```

The user remains in control.

---

# 26. Review modes

Support two modes:

```text id="6p2i5m"
Unified
```

and:

```text id="4f0q8j"
Split
```

Unified:

```text id="1m35xq"
- old
+ new
```

Split:

```text id="t8j1nc"
BEFORE                  AFTER

old code                new code
old code                new code
```

---

# 27. Keyboard shortcuts

Review should be fast.

```text id="9w9b8x"
Accept hunk       A
Reject hunk       R
Next hunk         J
Previous hunk     K
Next file         ]
Previous file     [
```

And:

```text id="y0j7qj"
Accept all
Reject all
```

through the command system.

---

# 28. Review controller

Don't build separate shortcut logic.

```dart id="r0f1tc"
actions.register(
  AppAction(
    id: ActionId.acceptCurrentHunk,
    title: 'Accept Current Hunk',
    shortcut: 'A',
    execute: (_) {
      reviewController
          .acceptCurrentHunk();
    },
  ),
);
```

Everything remains unified.

---

# 29. Review summary

At the top:

```text id="1v9d0x"
Review Changes

4 files
+126
-41

2 accepted
1 pending
1 rejected
```

Update this live as the user reviews.

---

# 30. File-level state

```dart id="q1x1v6"
enum ReviewStatus {
  pending,
  partiallyAccepted,
  accepted,
  rejected,
}
```

Visual:

```text id="9icq8u"
● pending
◐ partially reviewed
✓ accepted
× rejected
```

---

# 31. AI explanation

If a user asks:

```text id="0g3kj5"
Explain
```

don't open a new chat.

Show an inline explanation:

```text id="s2w0zi"
Why this change?

The previous implementation used the
session refresh token without checking
whether the session existed.

This change adds the null check before
calling the refresh service.

[Got it]
```

The explanation belongs to the change.

---

# 32. Change provenance

Every hunk can carry:

```dart id="xkgxvv"
class ChangeMetadata {
  final ChangeOrigin origin;

  final String? agentTaskId;

  final String? agentStepId;

  final String? reason;

  const ChangeMetadata({
    required this.origin,
    this.agentTaskId,
    this.agentStepId,
    this.reason,
  });
}
```

Then:

```text id="8ew1zn"
AI change
Agent task: Fix authentication
Reason: Handle expired refresh token
```

---

# 33. User changes versus AI changes

If the user edits the same file while reviewing:

```text id="2n1hif"
AI
────────────────
+ generated code

USER
────────────────
+ manual adjustment
```

The system should detect that.

Never blindly overwrite user modifications.

---

# 34. Conflict detection

Before applying:

```dart id="5m7gve"
class ChangeConflict {
  final String path;

  final String expectedBase;

  final String actualBase;

  const ChangeConflict({
    required this.path,
    required this.expectedBase,
    required this.actualBase,
  });
}
```

If conflict:

```text id="1fr5bd"
This file changed since Aljabr
created the proposal.

AuthService.java

[Review Conflict]
[Regenerate Change]
[Cancel]
```

---

# 35. This gives us the complete safe AI loop

```text id="v6z5aj"
             ┌─────────────┐
             │    Agent    │
             └──────┬──────┘
                    ↓
              ChangeSet
                    ↓
             ┌─────────────┐
             │    Diff     │
             └──────┬──────┘
                    ↓
               Review UI
                    ↓
           ┌────────┴────────┐
           ↓                 ↓
        Accept             Reject
           │
           ↓
       Transaction
           │
           ↓
      Conflict check
           │
           ↓
       Apply changes
           │
           ↓
       Verification
           │
       ┌───┴────┐
       ↓        ↓
      Pass    Failure
       │        │
       ↓        ↓
    Complete   Repair
```

This is the core workflow I would make exceptionally polished.

---

## Next: Workspace intelligence

With the Agent → ChangeSet → Review pipeline in place, the next layer should be **workspace intelligence**:

```text
Repository
    ↓
Indexer
    ↓
Symbols
    ↓
References
    ↓
Dependencies
    ↓
Tests
    ↓
Git history
    ↓
Agent context
```

That gives us the foundation for **semantic search, "find related code", automatic context selection, impact analysis, test selection, code navigation, and much smarter Agent behavior**—rather than relying on the Agent to blindly search files every time.
