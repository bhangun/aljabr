## Next: Workspace Intelligence

Now we make Aljabr understand the project instead of treating it as a folder full of unrelated files.

The goal:

```text
User asks
   ↓
Agent understands intent
   ↓
Workspace index
   ↓
Find relevant symbols/files/tests
   ↓
Build minimal useful context
   ↓
Agent acts
```

The major UX improvement is that the user should **not have to manually tell the Agent which files matter**.

---

# 1. Workspace architecture

Add:

```text
lib/
└── workspace/
    ├── models/
    │   ├── workspace.dart
    │   ├── workspace_file.dart
    │   ├── workspace_symbol.dart
    │   ├── workspace_reference.dart
    │   ├── dependency.dart
    │   └── test_target.dart
    │
    ├── indexing/
    │   ├── workspace_index.dart
    │   ├── indexer.dart
    │   ├── symbol_index.dart
    │   ├── reference_index.dart
    │   └── dependency_index.dart
    │
    ├── search/
    │   ├── semantic_search.dart
    │   ├── symbol_search.dart
    │   └── impact_analysis.dart
    │
    └── presentation/
        ├── workspace_status.dart
        ├── search_panel.dart
        ├── symbol_results.dart
        └── impact_view.dart
```

---

# 2. Workspace model

```dart
class Workspace {
  final String id;
  final String rootPath;
  final String name;

  final WorkspaceIndexStatus indexStatus;

  const Workspace({
    required this.id,
    required this.rootPath,
    required this.name,
    this.indexStatus =
        WorkspaceIndexStatus.notIndexed,
  });
}
```

Status:

```dart
enum WorkspaceIndexStatus {
  notIndexed,
  indexing,
  ready,
  stale,
  error,
}
```

---

# 3. File model

```dart
class WorkspaceFile {
  final String path;
  final String relativePath;

  final String language;

  final int size;

  final DateTime modifiedAt;

  const WorkspaceFile({
    required this.path,
    required this.relativePath,
    required this.language,
    required this.size,
    required this.modifiedAt,
  });
}
```

---

# 4. Symbol model

This is the foundation of semantic navigation.

```dart
enum SymbolKind {
  class_,
  method,
  function,
  variable,
  field,
  constructor,
  interface_,
  enum_,
  parameter,
  property,
}
```

```dart
class WorkspaceSymbol {
  final String id;

  final String name;

  final SymbolKind kind;

  final String filePath;

  final int startLine;

  final int endLine;

  final String? parentId;

  const WorkspaceSymbol({
    required this.id,
    required this.name,
    required this.kind,
    required this.filePath,
    required this.startLine,
    required this.endLine,
    this.parentId,
  });
}
```

---

# 5. Why symbols matter

Instead of the Agent doing:

```text
grep "refreshToken"
```

it can reason:

```text
refreshToken()
    ↓
SessionService.refreshToken()
    ↓
called by
    ↓
AuthController
    ↓
tested by
    ↓
SessionServiceTest
```

That is a much stronger context graph.

---

# 6. Reference model

```dart
enum ReferenceKind {
  definition,
  call,
  import,
  inheritance,
  implementation,
  read,
  write,
}
```

```dart
class WorkspaceReference {
  final String sourceSymbolId;
  final String targetSymbolId;

  final ReferenceKind kind;

  const WorkspaceReference({
    required this.sourceSymbolId,
    required this.targetSymbolId,
    required this.kind,
  });
}
```

---

# 7. Dependency graph

```dart
class DependencyEdge {
  final String source;
  final String target;

  const DependencyEdge({
    required this.source,
    required this.target,
  });
}
```

Then:

```text
AuthController
      │
      ▼
AuthService
      │
      ├─────────────┐
      ▼             ▼
SessionService   TokenStore
      │
      ▼
RefreshClient
```

The Agent can now determine impact before editing.

---

# 8. Index interface

```dart
abstract interface class WorkspaceIndexer {
  Stream<IndexProgress> index(
    Workspace workspace,
  );
}
```

Progress:

```dart
class IndexProgress {
  final int completed;
  final int total;

  final String? currentFile;

  const IndexProgress({
    required this.completed,
    required this.total,
    this.currentFile,
  });

  double get fraction =>
      total == 0 ? 0 : completed / total;
}
```

---

# 9. Never block the UI

When indexing:

```text
Indexing workspace

██████████████░░░░░░ 72%

1,284 / 1,782 files

Current:
lib/auth/session_service.dart
```

But the rest of the application remains usable.

---

# 10. Workspace status indicator

Put a subtle indicator in the top bar:

```text
┌───────────────────────────────────────────────┐
│ Aljabr   project-name                ● Ready │
└───────────────────────────────────────────────┘
```

States:

```text
● Ready
◐ Indexing
! Needs update
× Error
```

Don't make indexing a giant modal.

---

# 11. File watcher

After initial indexing, watch filesystem changes.

```dart
abstract interface class WorkspaceWatcher {
  Stream<WorkspaceChange> watch(
    String rootPath,
  );
}
```

```dart
enum WorkspaceChangeType {
  created,
  modified,
  deleted,
  renamed,
}
```

```dart
class WorkspaceChange {
  final String path;
  final WorkspaceChangeType type;

  const WorkspaceChange({
    required this.path,
    required this.type,
  });
}
```

Then re-index only affected files.

---

# 12. Incremental indexing

Avoid:

```text
File changed
↓
Re-index entire repository
```

Instead:

```text
AuthService.java changed
        ↓
Parse AuthService.java
        ↓
Update symbols
        ↓
Update references
        ↓
Invalidate affected dependencies
```

This keeps large repositories responsive.

---

# 13. Search abstraction

Now create one unified search interface.

```dart
abstract interface class WorkspaceSearch {
  Future<List<SearchResult>> search(
    String query,
  );
}
```

Result:

```dart
class SearchResult {
  final String path;

  final String title;

  final String? subtitle;

  final SearchResultKind kind;

  final int? line;

  const SearchResult({
    required this.path,
    required this.title,
    this.subtitle,
    required this.kind,
    this.line,
  });
}
```

---

# 14. Search result kinds

```dart
enum SearchResultKind {
  file,
  symbol,
  reference,
  text,
  test,
  dependency,
}
```

This lets one search UI handle everything.

---

# 15. Command palette

Now connect it to the command palette.

User presses:

```text
Cmd/Ctrl + P
```

and types:

```text
refreshSession
```

Results:

```text
Search

Symbols
  refreshSession()
  SessionService.refreshSession()

Files
  session_service.dart

Tests
  refresh_session_test.dart

References
  AuthController
```

This is much better than a simple filename search.

---

# 16. Search ranking

Don't return results arbitrarily.

```dart
class SearchScore {
  static double calculate({
    required String query,
    required String candidate,
  }) {
    final q = query.toLowerCase();
    final c = candidate.toLowerCase();

    if (c == q) return 1.0;
    if (c.startsWith(q)) return 0.9;
    if (c.contains(q)) return 0.7;

    return 0.0;
  }
}
```

Later replace this with a more sophisticated ranking system.

---

# 17. Semantic search

Add:

```dart
abstract interface class SemanticSearch {
  Future<List<SemanticResult>> search(
    String query,
  );
}
```

Example:

```text
"where do we refresh expired sessions?"
```

Results:

```text
SessionService.refreshSession()
AuthService.refreshToken()
RefreshTokenMiddleware
session_refresh_test.dart
```

This is where embeddings/vector search can eventually enter.

But don't make the whole architecture dependent on embeddings.

Keep the interface abstract.

---

# 18. Context builder

This is one of the highest-value pieces.

```dart
abstract interface class AgentContextBuilder {
  Future<AgentContext> build({
    required String prompt,
    required Workspace workspace,
  });
}
```

The Agent gets:

```text
Prompt
+
Current file
+
Selection
+
Related symbols
+
References
+
Tests
+
Git context
```

instead of:

```text
entire repository
```

---

# 19. Context item

```dart
enum AgentContextType {
  file,
  symbol,
  selection,
  test,
  reference,
  dependency,
  gitChange,
}
```

```dart
class AgentContextItem {
  final AgentContextType type;

  final String label;

  final String path;

  final int? startLine;

  final int? endLine;

  final double relevance;

  const AgentContextItem({
    required this.type,
    required this.label,
    required this.path,
    this.startLine,
    this.endLine,
    this.relevance = 0,
  });
}
```

---

# 20. Automatic context selection

Example:

User:

```text
Fix the authentication timeout.
```

Current file:

```text
AuthController.java
```

Context builder discovers:

```text
AuthController.java
        ↓
AuthService.java
        ↓
SessionService.java
        ↓
TokenStore.java
        ↓
AuthenticationTest.java
```

Then ranks them:

```text
AuthController.java        0.98
AuthService.java           0.95
SessionService.java        0.91
AuthenticationTest.java    0.88
TokenStore.java            0.72
```

Only the useful context is sent.

---

# 21. Show automatic context to the user

Don't hide this completely.

Show a collapsible section:

```text
Context used · 5 items

▾ AuthController.java
▾ AuthService.java
▾ SessionService.java
▾ AuthenticationTest.java
▾ TokenStore.java
```

This creates trust.

---

# 22. "Why this file?"

Every context item should optionally expose:

```text
Why included?

Referenced by AuthController
and contains refresh-session logic.
```

This is a small UX feature with huge value.

---

# 23. Impact analysis

Before changing a symbol:

```dart
abstract interface class ImpactAnalyzer {
  Future<ImpactReport> analyze(
    WorkspaceSymbol symbol,
  );
}
```

```dart
class ImpactReport {
  final WorkspaceSymbol target;

  final List<WorkspaceSymbol> callers;

  final List<WorkspaceSymbol> tests;

  final List<WorkspaceSymbol> implementations;

  final List<WorkspaceFile> affectedFiles;

  const ImpactReport({
    required this.target,
    this.callers = const [],
    this.tests = const [],
    this.implementations = const [],
    this.affectedFiles = const [],
  });
}
```

---

# 24. Impact UI

When reviewing a change:

```text
Impact

AuthService.refreshToken()

Callers
  4

Tests
  3

Implementations
  1

Potentially affected
  7 files
```

Expandable:

```text
Callers
────────────────────
AuthController
SessionMiddleware
LoginManager
TokenRefreshJob
```

---

# 25. Test selection

Don't run every test after every tiny edit.

Determine relevant tests:

```dart
abstract interface class TestSelector {
  Future<List<TestTarget>> select({
    required ChangeSet changeSet,
    required ImpactReport impact,
  });
}
```

Example:

```text
Changed:
AuthService.java

Selected tests:

✓ AuthServiceTest
✓ SessionServiceTest
✓ AuthenticationFlowTest
```

---

# 26. Test model

```dart
class TestTarget {
  final String id;

  final String name;

  final String path;

  final TestType type;

  const TestTarget({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
  });
}
```

```dart
enum TestType {
  unit,
  integration,
  widget,
  e2e,
  unknown,
}
```

---

# 27. Git intelligence

Add a Git context provider.

```dart
abstract interface class GitContextService {
  Future<GitContext> getContext();
}
```

```dart
class GitContext {
  final String branch;

  final List<String> changedFiles;

  final bool hasUncommittedChanges;

  const GitContext({
    required this.branch,
    required this.changedFiles,
    required this.hasUncommittedChanges,
  });
}
```

Now the Agent knows:

```text
Current branch:
feature/auth-refresh

Existing user changes:
3 files
```

---

# 28. Protect existing work

This becomes a hard rule:

```dart
if (gitContext.hasUncommittedChanges) {
  // Preserve user changes.
}
```

The Agent should understand:

```text
User changes ≠ Agent changes
```

and never casually overwrite them.

---

# 29. Git-aware Agent context

Show:

```text
Existing changes

M AuthController.java
M LoginScreen.java
?? notes.md
```

Then:

```text
Agent will avoid modifying these
unless explicitly requested.
```

This is a major trust feature.

---

# 30. Workspace intelligence panel

Add a small diagnostic view:

```text
Workspace
──────────────────────────

Index
✓ Ready

Files
1,782

Symbols
24,901

References
61,204

Tests
3,421

Last updated
12 seconds ago
```

Don't put this front-and-center for normal users.

Make it available under:

```text
Workspace → Intelligence
```

---

# 31. Reindex action

Command:

```text
Reindex Workspace
```

Keyboard-accessible through the command system.

But only show:

```text
Reindex
```

when there is a genuine indexing problem.

---

# 32. Architecture now

At this point the application becomes:

```text
                 ┌──────────────┐
                 │     UI       │
                 └──────┬───────┘
                        │
                 ┌──────▼───────┐
                 │   Commands   │
                 └──────┬───────┘
                        │
          ┌─────────────▼─────────────┐
          │       Agent Layer         │
          └─────────────┬─────────────┘
                        │
          ┌─────────────▼─────────────┐
          │   Context Intelligence    │
          └─────────────┬─────────────┘
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
   Symbols          References        Tests
       │                │                │
       └────────────────┼────────────────┘
                        ▼
                  Workspace Index
                        │
                        ▼
                    Repository
```

---

# 33. The important optimization

The Agent should **not** think:

```text
"What files should I read?"
```

from scratch every time.

The application should provide:

```text
Likely relevant files:
1. AuthService.java
2. SessionService.java
3. TokenStore.java
4. AuthServiceTest.java
```

Then the Agent spends its reasoning budget on the actual task.

---

# 34. Context budget

Create a budget:

```dart
class ContextBudget {
  final int maxFiles;
  final int maxTokens;

  const ContextBudget({
    this.maxFiles = 12,
    this.maxTokens = 30000,
  });
}
```

Then rank context:

```dart
List<AgentContextItem> selectContext(
  List<AgentContextItem> candidates,
  ContextBudget budget,
) {
  final sorted = [
    ...candidates,
  ]..sort(
      (a, b) =>
          b.relevance.compareTo(a.relevance),
    );

  return sorted.take(
    budget.maxFiles,
  ).toList();
}
```

This prevents context explosion.

---

# 35. Context transparency

Before running:

```text
Agent context · 7 files

Current selection       1
Related symbols         3
Tests                   2
Git changes             1

[View context]
```

This should be one click away.

---

# 36. The complete intelligent workflow

Now our Agent becomes:

```text
User:
"Fix the authentication timeout."

             ↓

Current editor
             ↓
Workspace index
             ↓
Symbol resolution
             ↓
Reference graph
             ↓
Impact analysis
             ↓
Relevant tests
             ↓
Git state
             ↓
Context ranking
             ↓
Agent
             ↓
ChangeSet
             ↓
Diff
             ↓
Review
             ↓
Apply
             ↓
Targeted verification
             ↓
Result
```

That is substantially more sophisticated than a chat wrapper around an LLM.

---

## Next: the editor itself

Now that the intelligence layer is in place, the next major improvement should be the **actual code editor UX**:

```text
Editor
├── Tabs
├── Breadcrumbs
├── Minimap
├── Sticky headers
├── Symbol navigation
├── Go to definition
├── Find references
├── Inline diagnostics
├── Code actions
├── Inline Agent actions
├── Diff decorations
├── Review markers
└── Command palette integration
```

Most importantly, we should make **Agent + editor feel like one product**, rather than an editor with a chatbot bolted onto the side.


# Next: Editor UX

Now we make the **editor itself** feel premium.

The key principle is:

> **The Agent should operate inside the editor, not beside it.**

So instead of:

```text
┌─────────────────────┬─────────────────┐
│                     │                 │
│      Code           │      Agent      │
│                     │                 │
└─────────────────────┴─────────────────┘
```

we move toward:

```text
┌─────────────────────────────────────────────┐
│ Tabs                                        │
├─────────────────────────────────────────────┤
│ Breadcrumbs                                 │
├──────┬──────────────────────────────────────┤
│      │                                      │
│ line │             Code                     │
│ nums │                                      │
│      │        ✦ Agent actions               │
│      │                                      │
├──────┴──────────────────────────────────────┤
│ Problems / Output / Terminal                │
└─────────────────────────────────────────────┘
```

---

## 1. Editor architecture

Add:

```text
lib/
└── editor/
    ├── models/
    │   ├── editor_document.dart
    │   ├── editor_tab.dart
    │   ├── editor_selection.dart
    │   ├── editor_position.dart
    │   └── editor_diagnostic.dart
    │
    ├── controller/
    │   ├── editor_controller.dart
    │   ├── selection_controller.dart
    │   └── navigation_controller.dart
    │
    ├── services/
    │   ├── editor_service.dart
    │   ├── language_service.dart
    │   ├── diagnostic_service.dart
    │   └── code_action_service.dart
    │
    └── presentation/
        ├── editor_shell.dart
        ├── editor_tabs.dart
        ├── breadcrumbs.dart
        ├── code_editor.dart
        ├── minimap.dart
        ├── diagnostics.dart
        ├── inline_action.dart
        └── editor_status_bar.dart
```

---

# 2. Editor document

```dart
class EditorDocument {
  final String id;
  final String path;
  final String language;

  final String content;

  final bool dirty;

  const EditorDocument({
    required this.id,
    required this.path,
    required this.language,
    required this.content,
    this.dirty = false,
  });

  EditorDocument copyWith({
    String? content,
    bool? dirty,
  }) {
    return EditorDocument(
      id: id,
      path: path,
      language: language,
      content: content ?? this.content,
      dirty: dirty ?? this.dirty,
    );
  }
}
```

---

# 3. Editor tabs

```dart
class EditorTab {
  final String id;
  final String documentId;

  final bool pinned;
  final bool preview;

  const EditorTab({
    required this.id,
    required this.documentId,
    this.pinned = false,
    this.preview = false,
  });
}
```

The important UX distinction:

```text
Preview tab
    ↓
temporary

Double click / edit
    ↓
permanent tab
```

This prevents the editor from filling with dozens of tabs.

---

# 4. Tab bar

Target:

```text
┌─────────────────────────────────────────────────────────┐
│ AuthService.java × │ SessionService.java × │ +          │
└─────────────────────────────────────────────────────────┘
```

Dirty state:

```text
AuthService.java ●
```

instead of immediately changing the filename.

---

# 5. Tab widget

```dart
class EditorTabs extends StatelessWidget {
  final List<EditorTab> tabs;
  final String activeTabId;

  final ValueChanged<String> onSelect;
  final ValueChanged<String> onClose;

  const EditorTabs({
    super.key,
    required this.tabs,
    required this.activeTabId,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          for (final tab in tabs)
            EditorTabItem(
              tab: tab,
              selected:
                  tab.id == activeTabId,
              onTap: () => onSelect(tab.id),
              onClose: () => onClose(tab.id),
            ),

          const Spacer(),

          IconButton(
            tooltip: 'New tab',
            onPressed: () {
              // create tab
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

---

# 6. Breadcrumbs

Under the tabs:

```text
AuthService.java
  › Session
    › refreshToken()
```

This should be generated from the symbol index.

```dart
class Breadcrumb {
  final String label;
  final SymbolKind? kind;
  final String? symbolId;

  const Breadcrumb({
    required this.label,
    this.kind,
    this.symbolId,
  });
}
```

---

# 7. Breadcrumb navigation

Click:

```text
refreshToken()
```

and jump directly to its declaration.

```dart
void navigateToSymbol(
  String symbolId,
) {
  final symbol =
      symbolIndex.find(symbolId);

  if (symbol == null) return;

  openFile(symbol.filePath);

  moveCursor(
    line: symbol.startLine,
  );
}
```

---

# 8. Selection model

This becomes extremely important for Agent interactions.

```dart
class EditorSelection {
  final int startLine;
  final int startColumn;

  final int endLine;
  final int endColumn;

  const EditorSelection({
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  bool get isEmpty =>
      startLine == endLine &&
      startColumn == endColumn;
}
```

---

# 9. "Ask Agent about selection"

When the user highlights code:

```text
┌──────────────────────────────────┐
│ final token = session.refresh(); │
│                                  │
│      [ Ask Agent ]               │
└──────────────────────────────────┘
```

Clicking it opens:

```text
Explain this code
```

with the selection automatically attached as context.

---

# 10. Inline Agent action

Create:

```dart
class InlineAgentAction extends StatelessWidget {
  final EditorSelection selection;

  const InlineAgentAction({
    super.key,
    required this.selection,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () {
        // open agent with selection
      },
      child: const Icon(
        Icons.auto_awesome,
      ),
    );
  }
}
```

Don't show it permanently.

Only reveal it when relevant.

---

# 11. Context menu

Right click selected code:

```text
┌──────────────────────────────┐
│ Copy                         │
│ Cut                          │
│ ───────────────────────────  │
│ Go to Definition             │
│ Find References              │
│ ───────────────────────────  │
│ Explain with Agent           │
│ Fix with Agent               │
│ Refactor with Agent       ›  │
└──────────────────────────────┘
```

This is much more powerful than putting everything in a toolbar.

---

# 12. Code actions

Model them:

```dart
enum CodeActionKind {
  quickFix,
  refactor,
  source,
  agent,
}
```

```dart
class CodeAction {
  final String title;
  final CodeActionKind kind;

  final Future<void> Function() execute;

  const CodeAction({
    required this.title,
    required this.kind,
    required this.execute,
  });
}
```

---

# 13. Diagnostic model

```dart
enum DiagnosticSeverity {
  error,
  warning,
  info,
  hint,
}
```

```dart
class EditorDiagnostic {
  final String message;

  final DiagnosticSeverity severity;

  final int startLine;
  final int startColumn;

  final int endLine;
  final int endColumn;

  const EditorDiagnostic({
    required this.message,
    required this.severity,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });
}
```

---

# 14. Inline diagnostics

Instead of only:

```text
Problems: 3
```

show directly beside the code:

```text
  81 │ final token = session.token;
     │             ^^^^^^^^^^^^^
     │ Token may be null
```

The user immediately understands where the problem is.

---

# 15. Diagnostic hover

Hover:

```text
Token may be null
```

show:

```text
┌─────────────────────────────────────┐
│ Token may be null                   │
│                                     │
│ session.token can return null when  │
│ the session has expired.            │
│                                     │
│ [Quick Fix] [Ask Agent]             │
└─────────────────────────────────────┘
```

---

# 16. Problems panel

Bottom panel:

```text
Problems · 3
────────────────────────────────────────

× AuthService.java:81
  Token may be null

⚠ SessionService.java:42
  Unused variable

ⓘ TokenStore.java:18
  Deprecated API
```

Clicking one jumps to the exact location.

---

# 17. Problems filter

Add:

```text
All · Errors · Warnings · Info
```

and:

```text
Current File
Workspace
```

This makes large projects manageable.

---

# 18. Minimap

Add a lightweight minimap:

```text
┌─────────────────────────────────────────────┐
│ code                             ▌▌         │
│ code                             ▌          │
│ code                                         │
│ code                          ▌              │
│                                              │
└─────────────────────────────────────────────┘
```

But don't overdo it.

The minimap should be:

* low visual weight
* narrow
* clickable
* diagnostics-aware

---

# 19. Minimap markers

Use markers for:

```text
errors
warnings
changes
current location
```

So a user can see:

```text
       ▌
       ▌
       █  ← error
       ▌
       ▓  ← changed section
       ▌
```

---

# 20. Sticky headers

For long classes:

```text
class AuthService
──────────────────────────────

  ...

  refreshToken()
  ────────────────────────────

  ...
```

Keep the current parent symbol visible at the top.

This dramatically improves navigation in large files.

---

# 21. Editor controller

```dart
class EditorController
    extends ChangeNotifier {

  final List<EditorTab> _tabs = [];

  String? _activeTabId;

  EditorSelection? _selection;

  List<EditorTab> get tabs =>
      List.unmodifiable(_tabs);

  String? get activeTabId =>
      _activeTabId;

  EditorSelection? get selection =>
      _selection;

  void selectTab(String id) {
    _activeTabId = id;
    notifyListeners();
  }

  void setSelection(
    EditorSelection selection,
  ) {
    _selection = selection;
    notifyListeners();
  }
}
```

---

# 22. Navigation controller

Don't let every widget manipulate the editor directly.

```dart
class EditorNavigationController {
  final EditorController editor;

  EditorNavigationController({
    required this.editor,
  });

  Future<void> openLocation({
    required String path,
    int? line,
    int? column,
  }) async {
    // Open document.

    // Select tab.

    // Move cursor.

    // Reveal location.
  }
}
```

Now:

```text
Search
Agent
Problems
Git
References
Tests
```

can all navigate using the same mechanism.

---

# 23. Go to Definition

```dart
Future<void> goToDefinition(
  WorkspaceSymbol symbol,
) {
  return navigation.openLocation(
    path: symbol.filePath,
    line: symbol.startLine,
  );
}
```

---

# 24. Find References

When cursor is on:

```text
refreshToken()
```

press:

```text
Shift + F12
```

Show:

```text
References · 7

AuthController.java:42
SessionService.java:81
TokenRefreshJob.java:19
...
```

Click any result to navigate.

---

# 25. Reference peek

Even better:

```text
Shift + F12
```

can first show a peek panel:

```text
┌─────────────────────────────────────────────┐
│ References                                  │
├─────────────────────────────────────────────┤
│ AuthController.java                         │
│                                             │
│ 42 │ session.refreshToken();                │
│                                             │
│ SessionService.java                         │
│                                             │
│ 81 │ refreshToken();                        │
└─────────────────────────────────────────────┘
```

Then:

```text
Open
```

takes you to the full file.

---

# 26. Agent actions inside diagnostics

This is where the previous systems connect.

Diagnostic:

```text
Token may be null
```

Action:

```text
✨ Fix with Agent
```

Agent receives:

```text
Current file
Selected diagnostic
Relevant symbol
Related references
Relevant tests
Git state
```

Then creates a ChangeSet.

So the entire flow becomes:

```text
Diagnostic
   ↓
Agent
   ↓
ChangeSet
   ↓
Diff
   ↓
Review
```

No disconnected experiences.

---

# 27. Inline edit mode

For small changes, don't always open the full Agent panel.

User highlights:

```dart
return session.token;
```

Then chooses:

```text
Fix with Agent
```

Show:

```text
┌─────────────────────────────────────────────┐
│ How should this be fixed?                   │
│                                             │
│ [ Make null-safe                         ] │
│                                             │
│                              [Generate]     │
└─────────────────────────────────────────────┘
```

Then the editor previews:

```text
- return session.token;
+ return session?.token;
```

with:

```text
[Accept] [Reject]
```

This is a **micro-Agent interaction**.

---

# 28. Don't interrupt the user

The Agent should not automatically steal focus.

Bad:

```text
Agent starts
↓
full-screen modal
```

Better:

```text
Agent starts
↓
subtle activity indicator
↓
result appears when ready
```

Only open a larger UI when the task requires review.

---

# 29. Editor status bar

Bottom:

```text
Ln 81, Col 14
Spaces: 2
UTF-8
Java
Git: feature/auth-refresh
```

And optionally:

```text
✓ No problems
```

---

# 30. Agent activity indicator

When Agent is working:

```text
● Agent working
```

in the status bar.

Clicking it opens the Agent task.

This prevents unnecessary visual noise.

---

# 31. Unsaved changes

When closing a dirty tab:

```text
Save changes to AuthService.java?

[Cancel]
[Don't Save]
[Save]
```

Never silently discard.

---

# 32. Better save state

Use:

```dart
enum DocumentState {
  clean,
  dirty,
  saving,
  saveError,
}
```

UI:

```text
clean       nothing
dirty       ●
saving      ◌
saveError   !
```

---

# 33. Editor performance

Do not rebuild the whole editor whenever:

```text
cursor moves
selection changes
diagnostic changes
Agent streams an event
```

Separate state:

```text
EditorDocumentState
EditorSelectionState
EditorDiagnosticState
EditorAgentState
EditorNavigationState
```

This matters enormously for large files.

---

# 34. Virtualized rendering

For very large files:

```text
10 lines visible
```

should not require building:

```text
20,000 widgets
```

Use the underlying editor engine's virtualized text rendering where possible.

The Flutter UI should remain responsible for:

```text
tabs
panels
toolbars
overlays
navigation
Agent UI
```

while the actual text editor should use a proper code-editing engine.

---

# 35. Editor + Agent visual language

Use one consistent vocabulary.

```text
Agent
    ✦

Change
    ±

Diagnostic
    !

Navigation
    →

Verification
    ✓
```

Avoid filling the interface with unrelated icons.

---

# 36. The final editor experience

The ideal interaction is:

```text
User opens AuthService.java
              ↓
Reads code
              ↓
Sees warning
              ↓
Hover warning
              ↓
"Fix with Agent"
              ↓
Agent automatically gathers:
    • current symbol
    • references
    • related files
    • tests
    • git state
              ↓
ChangeSet generated
              ↓
Inline diff
              ↓
Accept / Reject
              ↓
Apply
              ↓
Tests
              ↓
✓ Fixed
```

The user never has to think about the underlying machinery.

---

# 37. Next layer: command system

At this point we have:

```text
Workspace Intelligence
        ↓
Editor
        ↓
Agent
        ↓
ChangeSet
        ↓
Verification
```

The next thing I'd implement is the **unified Command System**.

Everything should become an action:

```text
Cmd/Ctrl + P
Cmd/Ctrl + Shift + P
Cmd/Ctrl + P → "Go to Symbol"

Actions:
──────────────────────────────
Go to File
Go to Symbol
Find References
Rename Symbol
Format Document
Run Tests
Review Changes
Accept Hunk
Reject Hunk
Ask Agent
Fix with Agent
Explain Selection
Open Problems
Toggle Terminal
```

Then the GUI, keyboard shortcuts, context menus, Agent actions, and buttons all call the **same command layer**.

That is what will make the whole application feel cohesive rather than like a collection of separate features.


# Next: Unified Command System

This is the layer that ties the entire UX together.

Right now we have buttons, keyboard shortcuts, context menus, Agent actions, editor actions, and panels. The next improvement is to make **all of them invoke the same command infrastructure**.

```text
                    Command System
                         │
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
   Keyboard          Command          Context Menu
   Shortcut           Palette
        │                │                │
        └────────────────┼────────────────┘
                         ↓
                    Command Bus
                         │
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
      Editor            Agent           Git
        │                │                │
        └────────────────┼────────────────┘
                         ↓
                    Application
```

This is one of the biggest architectural polish steps because it eliminates duplicated behavior.

---

## 1. Command architecture

Add:

```text
lib/
└── commands/
    ├── models/
    │   ├── app_command.dart
    │   ├── command_id.dart
    │   ├── command_context.dart
    │   └── command_result.dart
    │
    ├── registry/
    │   └── command_registry.dart
    │
    ├── execution/
    │   └── command_bus.dart
    │
    └── presentation/
        ├── command_palette.dart
        ├── command_item.dart
        ├── shortcut_hint.dart
        └── command_search.dart
```

---

# 2. Command IDs

Don't use strings everywhere.

```dart
enum CommandId {
  newFile,
  openFile,
  closeTab,
  saveFile,

  goToFile,
  goToSymbol,
  goToDefinition,
  findReferences,

  formatDocument,

  runTests,
  openProblems,

  askAgent,
  explainSelection,
  fixWithAgent,

  reviewChanges,
  acceptHunk,
  rejectHunk,

  undo,
  redo,

  toggleTerminal,
  toggleSidebar,
}
```

This gives you one canonical identity for every action.

---

# 3. Command model

```dart
class AppCommand {
  final CommandId id;

  final String title;

  final String? description;

  final String? category;

  final String? shortcut;

  final bool Function(
    CommandContext context,
  ) isEnabled;

  final Future<CommandResult> Function(
    CommandContext context,
  ) execute;

  const AppCommand({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.shortcut,
    required this.isEnabled,
    required this.execute,
  });
}
```

---

# 4. Command context

This is important.

A command needs to know what the user is currently doing.

```dart
class CommandContext {
  final String? activeFile;

  final EditorSelection? selection;

  final bool hasActiveEditor;

  final bool hasUnsavedChanges;

  final bool hasSelectedSymbol;

  final bool hasPendingChanges;

  const CommandContext({
    this.activeFile,
    this.selection,
    this.hasActiveEditor = false,
    this.hasUnsavedChanges = false,
    this.hasSelectedSymbol = false,
    this.hasPendingChanges = false,
  });
}
```

Now commands can dynamically enable/disable themselves.

---

# 5. Command result

```dart
enum CommandResultStatus {
  success,
  cancelled,
  unavailable,
  failed,
}
```

```dart
class CommandResult {
  final CommandResultStatus status;

  final String? message;

  const CommandResult({
    required this.status,
    this.message,
  });

  const CommandResult.success()
      : status = CommandResultStatus.success,
        message = null;
}
```

---

# 6. Registry

```dart
class CommandRegistry {
  final Map<CommandId, AppCommand> _commands = {};

  void register(AppCommand command) {
    _commands[command.id] = command;
  }

  AppCommand? find(CommandId id) {
    return _commands[id];
  }

  List<AppCommand> get all =>
      _commands.values.toList();
}
```

---

# 7. Command bus

Now every UI element talks to the same execution layer.

```dart
class CommandBus {
  final CommandRegistry registry;

  CommandBus({
    required this.registry,
  });

  Future<CommandResult> execute(
    CommandId id,
    CommandContext context,
  ) async {
    final command = registry.find(id);

    if (command == null) {
      return const CommandResult(
        status: CommandResultStatus.unavailable,
      );
    }

    if (!command.isEnabled(context)) {
      return const CommandResult(
        status: CommandResultStatus.unavailable,
      );
    }

    try {
      return await command.execute(context);
    } catch (error) {
      return CommandResult(
        status: CommandResultStatus.failed,
        message: error.toString(),
      );
    }
  }
}
```

---

# 8. Register save

```dart
registry.register(
  AppCommand(
    id: CommandId.saveFile,
    title: 'Save File',
    category: 'File',
    shortcut: 'Ctrl+S',

    isEnabled: (context) =>
        context.hasActiveEditor &&
        context.hasUnsavedChanges,

    execute: (context) async {
      await editorService.saveActiveFile();

      return const CommandResult.success();
    },
  ),
);
```

Now the save button and keyboard shortcut both use this.

---

# 9. Register Agent action

```dart
registry.register(
  AppCommand(
    id: CommandId.explainSelection,
    title: 'Explain Selection',
    description:
        'Explain the selected code with Agent',
    category: 'Agent',
    shortcut: 'Ctrl+Shift+E',

    isEnabled: (context) =>
        context.selection != null &&
        !context.selection!.isEmpty,

    execute: (context) async {
      await agentService.explainSelection(
        context.selection!,
      );

      return const CommandResult.success();
    },
  ),
);
```

---

# 10. Context menu now becomes trivial

Instead of implementing:

```text
context menu → special logic
```

do:

```dart
CommandMenuItem(
  commandId: CommandId.explainSelection,
)
```

The command registry determines:

* title
* shortcut
* enabled state
* execution

---

# 11. Toolbar button

Same command:

```dart
IconButton(
  tooltip: 'Save',
  onPressed: () {
    commandBus.execute(
      CommandId.saveFile,
      context,
    );
  },
  icon: const Icon(Icons.save),
)
```

---

# 12. Keyboard shortcut

Same command again:

```dart
Shortcuts(
  shortcuts: {
    const SingleActivator(
      LogicalKeyboardKey.keyS,
      control: true,
    ): const CommandIntent(
      CommandId.saveFile,
    ),
  },
  child: Actions(
    actions: {
      CommandIntent:
          CallbackAction<CommandIntent>(
        onInvoke: (intent) {
          commandBus.execute(
            intent.commandId,
            context,
          );

          return null;
        },
      ),
    },
    child: child,
  ),
);
```

Now:

```text
Toolbar
Context menu
Keyboard
Command palette
Agent
```

all share one action.

---

# 13. Command palette

Now build the UI.

```text
┌──────────────────────────────────────────────────┐
│ > Search commands...                             │
├──────────────────────────────────────────────────┤
│ Editor                                           │
│   Go to File                           Ctrl+P    │
│   Go to Symbol                         Ctrl+Shift+O
│   Find References                      Shift+F12 │
│                                                  │
│ Agent                                            │
│   Explain Selection                   Ctrl+Shift+E
│   Fix with Agent                                │
│   Review Changes                                │
│                                                  │
│ Workspace                                        │
│   Reindex Workspace                             │
└──────────────────────────────────────────────────┘
```

---

# 14. Palette search

```dart
List<AppCommand> searchCommands(
  String query,
  List<AppCommand> commands,
) {
  final normalized =
      query.trim().toLowerCase();

  if (normalized.isEmpty) {
    return commands;
  }

  return commands.where((command) {
    return command.title
            .toLowerCase()
            .contains(normalized) ||
        (command.description
                ?.toLowerCase()
                .contains(normalized) ??
            false);
  }).toList();
}
```

Later, improve this with fuzzy matching.

---

# 15. Fuzzy search

The user should be able to type:

```text
gts
```

and find:

```text
Go to Symbol
```

Or:

```text
refs
```

and find:

```text
Find References
```

This makes the palette feel much faster.

---

# 16. Command palette controller

```dart
class CommandPaletteController
    extends ChangeNotifier {

  bool _open = false;

  String _query = '';

  bool get isOpen => _open;

  String get query => _query;

  void open() {
    _open = true;
    _query = '';
    notifyListeners();
  }

  void close() {
    _open = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
```

---

# 17. Palette keyboard behavior

This should feel extremely polished.

```text
↑ / ↓
```

navigate.

```text
Enter
```

execute.

```text
Esc
```

close.

```text
Ctrl/Cmd + P
```

open.

And:

```text
Ctrl/Cmd + Shift + P
```

can open the **full command palette** if `Ctrl/Cmd + P` is reserved for files.

---

# 18. Recent commands

Remember recently used commands.

```dart
class RecentCommands {
  final List<CommandId> _items = [];

  void record(CommandId id) {
    _items.remove(id);
    _items.insert(0, id);

    if (_items.length > 10) {
      _items.removeLast();
    }
  }
}
```

Then an empty palette shows:

```text
Recent

Save File
Run Tests
Find References
Review Changes
Explain Selection
```

---

# 19. Favorites

Allow users to pin commands.

```text
Favorites

★ Run Tests
★ Review Changes
★ Toggle Terminal
★ Reindex Workspace
```

This is particularly useful for power users.

---

# 20. Command categories

Keep categories consistent:

```dart
enum CommandCategory {
  file,
  editor,
  navigation,
  search,
  agent,
  git,
  testing,
  workspace,
  view,
  terminal,
}
```

This also lets you build a clean command palette hierarchy.

---

# 21. Command discovery

A polished product should teach itself.

When hovering:

```text
Go to Definition
```

show:

```text
Go to Definition

Jump to the declaration
of the current symbol.

F12
```

When a feature has a shortcut, always show it.

---

# 22. Action availability

This is a subtle but important UX detail.

If no file is open:

```text
Save File
```

should not appear as an active action.

If no selection exists:

```text
Explain Selection
```

should be disabled or hidden.

If there are no pending changes:

```text
Review Changes
```

should be unavailable.

This makes the UI feel intelligent.

---

# 23. Command state

Add:

```dart
enum CommandVisibility {
  visible,
  hidden,
}
```

Then:

```dart
class CommandState {
  final bool enabled;
  final CommandVisibility visibility;

  const CommandState({
    this.enabled = true,
    this.visibility =
        CommandVisibility.visible,
  });
}
```

Eventually commands can determine:

```text
enabled
disabled
hidden
```

depending on application state.

---

# 24. Global command search

The command palette should search more than commands.

Use tabs:

```text
┌────────────────────────────────────────────┐
│ > refreshToken                             │
├────────────────────────────────────────────┤
│ Commands                                   │
│   Find References                          │
│                                            │
│ Symbols                                    │
│   refreshToken()                           │
│                                            │
│ Files                                      │
│   session_service.dart                     │
│                                            │
│ Tests                                      │
│   refresh_token_test.dart                  │
└────────────────────────────────────────────┘
```

This becomes the application's **universal search**.

---

# 25. Unified search architecture

```dart
abstract interface class GlobalSearch {
  Future<List<SearchResult>> search(
    String query,
  );
}
```

Behind it:

```text
GlobalSearch
   │
   ├── Commands
   ├── Files
   ├── Symbols
   ├── References
   ├── Tests
   └── Git
```

This makes `Ctrl/Cmd + P` incredibly powerful.

---

# 26. Quick-open

If the query looks like a filename:

```text
authserv
```

prioritize:

```text
AuthService.java
AuthServiceTest.java
AuthServiceFactory.java
```

If it looks like a symbol:

```text
refreshToken
```

prioritize symbols.

The search system should infer intent from the query.

---

# 27. Command execution feedback

Don't leave users wondering whether something happened.

For short commands:

```text
✓ Formatted document
```

For longer commands:

```text
Running tests…

AuthServiceTest
SessionServiceTest
```

For Agent tasks:

```text
Agent working…
```

All through a unified notification system.

---

# 28. Notification system

Add:

```text
lib/
└── notifications/
    ├── notification.dart
    ├── notification_service.dart
    └── notification_center.dart
```

Model:

```dart
enum NotificationLevel {
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
  final NotificationLevel level;

  const AppNotification({
    required this.title,
    this.message,
    required this.level,
  });
}
```

---

# 29. Notification UX

Success:

```text
┌──────────────────────────────────────┐
│ ✓ Changes applied                    │
│ 4 files updated                  Undo│
└──────────────────────────────────────┘
```

Error:

```text
┌──────────────────────────────────────┐
│ ! Test failed                        │
│ AuthServiceTest                      │
│                              Details │
└──────────────────────────────────────┘
```

Don't use modal dialogs for routine status.

---

# 30. Notification center

A small bell:

```text
🔔 2
```

opens:

```text
Notifications

✓ Changes applied
✓ Tests passed
! 1 warning detected

Clear all
```

This gives users a history without cluttering the workspace.

---

# 31. Command telemetry

Internally, track:

```text
command
duration
success/failure
source
```

For example:

```dart
class CommandExecution {
  final CommandId command;
  final Duration duration;
  final CommandResultStatus result;
  final String source;

  const CommandExecution({
    required this.command,
    required this.duration,
    required this.result,
    required this.source,
  });
}
```

`source` might be:

```text
keyboard
toolbar
context-menu
command-palette
agent
```

This lets you later identify UX friction.

---

# 32. Don't over-instrument user content

Telemetry should focus on product behavior, not collecting source code unnecessarily.

For example:

```text
✓ "Go to Definition" used 82 times
```

is useful.

Whereas:

```text
✕ uploading source code to analyze usage
```

is unnecessary for basic UX telemetry.

---

# 33. Command system now connects everything

We now have:

```text
                    COMMAND BUS
                         │
       ┌─────────────────┼──────────────────┐
       │                 │                  │
       ▼                 ▼                  ▼
    Keyboard          Palette          Context Menu
       │                 │                  │
       └─────────────────┼──────────────────┘
                         ▼
                  Application State
                         │
       ┌─────────────────┼──────────────────┐
       ▼                 ▼                  ▼
    Editor             Agent               Git
       │                 │                  │
       ▼                 ▼                  ▼
    Changes          ChangeSet           Changes
       │                 │                  │
       └─────────────────┼──────────────────┘
                         ▼
                     Verify
                         │
                         ▼
                     Notify
```

This is the point where the product starts feeling **coherent**.

---

# 34. One more important UX improvement: command history

The Agent should also expose what it is doing through the same command model.

For example:

```text
Agent
────────────────────────────

✓ Search workspace
✓ Inspect AuthService
✓ Find references
✓ Inspect tests
✓ Generate ChangeSet
● Running verification
```

Each step is a command-like operation.

Clicking one can reveal:

```text
Search workspace

Query:
"refresh session timeout"

Results:
7 symbols
4 files
2 tests
```

This gives you **Agent observability without exposing chain-of-thought**.

The user sees *what operation happened and its result*, not private internal reasoning.

---

# 35. Next architectural step

Now the application has:

```text
01 Workspace Intelligence
02 Editor
03 Agent
04 ChangeSet / Diff
05 Verification
06 Command System
07 Notifications
```

The next major improvement is the **Workspace Shell / Layout System**.

That should turn the whole thing into a genuinely polished IDE:

```text
┌────────────────────────────────────────────────────────────┐
│ App Menu       Project             Search       Agent ●    │
├────────┬───────────────────────────────────────┬───────────┤
│        │ Tabs                                  │           │
│ ACTIVITY├───────────────────────────────────────┤  AGENT    │
│ BAR    │ Breadcrumbs                           │           │
│        ├───────────────────────────────────────┤           │
│ Files  │                                       │           │
│ Search │               Editor                  │           │
│ Git    │                                       │           │
│ Agent  │                                       │           │
│        ├───────────────────────────────────────┤           │
│        │ Problems · Terminal · Output          │           │
├────────┴───────────────────────────────────────┴───────────┤
│ Ln 81 Col 14    UTF-8    Java     ✓ Ready                  │
└────────────────────────────────────────────────────────────┘
```

The key next implementation will be **resizable panels, persisted layout state, responsive behavior, focus management, and workspace modes** so the UI stays elegant rather than becoming increasingly crowded as we add these capabilities.


# Next: Workspace Shell & Layout System

Now we make all the pieces we built feel like **one coherent IDE** rather than a collection of panels.

The important principle:

> **The user controls the workspace; the application remembers it.**

---

## 1. Shell architecture

Add:

```text
lib/
└── shell/
    ├── models/
    │   ├── workspace_layout.dart
    │   ├── panel_state.dart
    │   ├── panel_id.dart
    │   └── workspace_mode.dart
    │
    ├── controller/
    │   ├── shell_controller.dart
    │   ├── layout_controller.dart
    │   └── focus_controller.dart
    │
    ├── persistence/
    │   └── layout_storage.dart
    │
    └── presentation/
        ├── app_shell.dart
        ├── activity_bar.dart
        ├── sidebar.dart
        ├── main_editor_area.dart
        ├── auxiliary_panel.dart
        ├── bottom_panel.dart
        └── status_bar.dart
```

---

# 2. Panel IDs

```dart
enum PanelId {
  explorer,
  search,
  sourceControl,
  agent,
  problems,
  output,
  terminal,
  tests,
}
```

This gives every panel a stable identity.

---

# 3. Panel state

```dart
class PanelState {
  final PanelId id;

  final bool visible;

  final double size;

  final bool pinned;

  const PanelState({
    required this.id,
    this.visible = true,
    this.size = 280,
    this.pinned = false,
  });

  PanelState copyWith({
    bool? visible,
    double? size,
    bool? pinned,
  }) {
    return PanelState(
      id: id,
      visible: visible ?? this.visible,
      size: size ?? this.size,
      pinned: pinned ?? this.pinned,
    );
  }
}
```

---

# 4. Workspace layout

```dart
class WorkspaceLayout {
  final double sidebarWidth;

  final double auxiliaryWidth;

  final double bottomPanelHeight;

  final bool sidebarVisible;

  final bool auxiliaryVisible;

  final bool bottomPanelVisible;

  const WorkspaceLayout({
    this.sidebarWidth = 280,
    this.auxiliaryWidth = 360,
    this.bottomPanelHeight = 240,
    this.sidebarVisible = true,
    this.auxiliaryVisible = false,
    this.bottomPanelVisible = false,
  });
}
```

---

# 5. Workspace modes

This is where the UX gets interesting.

```dart
enum WorkspaceMode {
  coding,
  reviewing,
  debugging,
  agent,
  searching,
}
```

Each mode can slightly optimize the layout.

### Coding

```text
Explorer + Editor
```

### Reviewing

```text
Files + Diff + Review
```

### Debugging

```text
Editor + Problems + Terminal
```

### Agent

```text
Editor + Agent
```

### Searching

```text
Search + Editor
```

Don't radically change the UI between modes. Just emphasize the relevant surfaces.

---

# 6. Main shell

```dart
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppTitleBar(),

          Expanded(
            child: Row(
              children: [
                const ActivityBar(),

                const Sidebar(),

                const VerticalResizeHandle(),

                const Expanded(
                  child: MainEditorArea(),
                ),

                const AuxiliaryPanel(),

              ],
            ),
          ),

          const BottomPanel(),

          const StatusBar(),
        ],
      ),
    );
  }
}
```

---

# 7. Activity bar

Keep it narrow.

```text
┌───┐
│ 📁│
│ 🔎│
│ ◇ │
│ ✦ │
│ ⚙ │
│   │
│   │
│   │
└───┘
```

Each icon switches the primary sidebar.

```dart
enum Activity {
  explorer,
  search,
  sourceControl,
  agent,
  extensions,
}
```

---

# 8. Activity button

```dart
class ActivityButton extends StatelessWidget {
  final Activity activity;
  final bool selected;
  final VoidCallback onPressed;

  const ActivityButton({
    super.key,
    required this.activity,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: activity.label,
      onPressed: onPressed,
      icon: Icon(
        activity.icon,
      ),
    );
  }
}
```

---

# 9. Don't make the sidebar destructive

When switching:

```text
Explorer
   ↓
Search
```

don't destroy Explorer state.

Keep:

```text
expanded folders
selected file
scroll position
search query
```

alive.

---

# 10. Sidebar controller

```dart
class SidebarController extends ChangeNotifier {
  Activity _active = Activity.explorer;

  Activity get active => _active;

  void activate(Activity activity) {
    _active = activity;
    notifyListeners();
  }

  void toggle(Activity activity) {
    if (_active == activity) {
      // collapse sidebar
    } else {
      _active = activity;
    }

    notifyListeners();
  }
}
```

This creates a nice interaction:

```text
click Explorer
→ opens Explorer

click Explorer again
→ collapses sidebar
```

---

# 11. Resizable sidebar

Don't hardcode:

```dart
width: 280
```

Use state:

```dart
SizedBox(
  width: layout.sidebarWidth,
  child: const Sidebar(),
)
```

and:

```dart
GestureDetector(
  onHorizontalDragUpdate: (details) {
    layoutController.resizeSidebar(
      details.delta.dx,
    );
  },
)
```

---

# 12. Resize constraints

```dart
void resizeSidebar(double delta) {
  final next =
      _layout.sidebarWidth + delta;

  final width = next.clamp(
    220.0,
    520.0,
  );

  _layout = _layout.copyWith(
    sidebarWidth: width,
  );

  notifyListeners();
}
```

Don't allow the user to accidentally collapse the sidebar to 12px.

---

# 13. Resize handle UX

The resize handle should be invisible until approached.

```text
normal:
│

hover:
┃

drag:
┃
```

This keeps the interface clean.

---

# 14. Bottom panel

The bottom panel should behave like a drawer:

```text
Editor
──────────────────────────────
Problems · Terminal · Output
──────────────────────────────
```

When closed:

```text
Editor
──────────────────────────────
Status bar
```

Not a permanently occupied chunk of screen.

---

# 15. Bottom panel tabs

```dart
enum BottomPanel {
  problems,
  terminal,
  output,
  tests,
}
```

Switching should preserve each panel's state.

---

# 16. Panel height

```dart
void resizeBottomPanel(
  double delta,
) {
  final height =
      _layout.bottomPanelHeight - delta;

  _layout = _layout.copyWith(
    bottomPanelHeight: height.clamp(
      120.0,
      600.0,
    ),
  );

  notifyListeners();
}
```

---

# 17. Auxiliary Agent panel

The Agent should not always consume 400px.

When closed:

```text
┌──────────────────────────────────────┐
│                Editor                │
└──────────────────────────────────────┘
```

When opened:

```text
┌───────────────────────┬──────────────┐
│                       │              │
│        Editor         │    Agent     │
│                       │              │
└───────────────────────┴──────────────┘
```

And resizable:

```text
┌──────────────────────────┬───────────┐
│                          │           │
│          Editor          │   Agent   │
│                          │           │
└──────────────────────────┴───────────┘
```

---

# 18. Agent panel states

Don't treat the Agent as just a chat window.

```dart
enum AgentPanelState {
  idle,
  composing,
  working,
  reviewing,
  completed,
  failed,
}
```

---

# 19. Agent idle

```text
Agent

What would you like to change?

[ Ask about this project... ]
```

And contextual suggestions:

```text
Explain this file
Find potential bugs
Run relevant tests
Review current changes
```

---

# 20. Agent working

```text
Agent
────────────────────────────

● Understanding request

✓ Search workspace
✓ Inspect AuthService
● Inspect related tests
○ Generate solution
```

This ties directly into our previous command/activity model.

---

# 21. Agent completed

```text
Agent
────────────────────────────

✓ Proposed a solution

3 files changed
+42
-11

[Review Changes]
```

The Agent panel shouldn't immediately dump a giant response.

Lead with the actionable result.

---

# 22. Focus management

This is one of the most important pieces.

Create:

```dart
enum FocusTarget {
  activityBar,
  sidebar,
  editor,
  agent,
  bottomPanel,
  commandPalette,
}
```

```dart
class FocusController {
  FocusTarget _target = FocusTarget.editor;

  FocusTarget get target => _target;

  void focus(FocusTarget target) {
    _target = target;
  }
}
```

---

# 23. Keyboard focus rules

For example:

```text
Ctrl/Cmd + P
        ↓
Command palette
        ↓
typing
        ↓
Enter
        ↓
editor receives focus
```

Or:

```text
Ask Agent
   ↓
Agent input focused
```

Never leave focus floating somewhere unexpected.

---

# 24. Escape hierarchy

`Esc` should behave predictably.

```text
Agent input focused
      ↓ Esc
clear Agent input state

Command palette open
      ↓ Esc
close palette

Peek view open
      ↓ Esc
close peek

Selection active
      ↓ Esc
clear selection

Nothing modal
      ↓ Esc
no-op
```

Don't close the entire Agent panel because the user pressed Escape once.

---

# 25. Responsive layout

For a smaller window:

```text
Desktop
──────────────────────────────
Activity | Sidebar | Editor | Agent
```

At medium width:

```text
Activity | Sidebar | Editor
```

Agent becomes an overlay.

At very small width:

```text
Activity | Editor
```

Everything else becomes a drawer.

---

# 26. Responsive breakpoint

```dart
enum WorkspaceSize {
  compact,
  medium,
  large,
}
```

```dart
WorkspaceSize classifyWidth(
  double width,
) {
  if (width < 900) {
    return WorkspaceSize.compact;
  }

  if (width < 1200) {
    return WorkspaceSize.medium;
  }

  return WorkspaceSize.large;
}
```

---

# 27. Compact mode

Instead of squeezing:

```text
[Explorer][Search][Agent][Git]
```

into a tiny sidebar, switch to:

```text
┌───┐
│ 📁│
│ 🔎│
│ ✦ │
│ ◇ │
└───┘
```

and open the selected panel as a drawer.

---

# 28. Layout persistence

This is essential.

If the user does:

```text
Sidebar = 340
Agent = open
Bottom panel = 280
```

close and reopen Aljabr, it should remain.

```dart
abstract interface class LayoutStorage {
  Future<WorkspaceLayout?> load(
    String workspaceId,
  );

  Future<void> save(
    String workspaceId,
    WorkspaceLayout layout,
  );
}
```

---

# 29. Save changes intelligently

Don't write to disk every pixel dragged.

Bad:

```text
drag
drag
drag
drag
drag
→ 50 writes
```

Instead debounce:

```dart
Timer? _saveTimer;

void scheduleSave() {
  _saveTimer?.cancel();

  _saveTimer = Timer(
    const Duration(milliseconds: 400),
    persist,
  );
}
```

---

# 30. Workspace-specific layouts

Different projects can have different layouts.

```text
workspace-A
  sidebar: 280
  agent: closed

workspace-B
  sidebar: 340
  agent: open
  terminal: open
```

Store by workspace ID.

---

# 31. Workspace layout model

Expand:

```dart
class WorkspaceLayout {
  final Map<PanelId, PanelState> panels;

  final WorkspaceMode mode;

  final String? activeActivity;

  const WorkspaceLayout({
    required this.panels,
    this.mode = WorkspaceMode.coding,
    this.activeActivity,
  });
}
```

---

# 32. Split editor groups

This is the next important editor feature.

Support:

```text
┌───────────────────┬───────────────────┐
│ AuthService.java  │ SessionService.java│
│                   │                   │
│                   │                   │
└───────────────────┴───────────────────┘
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

---

# 33. Editor layout

```dart
class EditorLayout {
  final List<EditorGroup> groups;

  const EditorLayout({
    this.groups = const [],
  });
}
```

Later:

```text
Group A
   ├── Tab
   ├── Tab

Group B
   ├── Tab
   └── Tab
```

---

# 34. Split actions

Commands:

```dart
CommandId.splitEditorHorizontal
CommandId.splitEditorVertical
CommandId.closeEditorGroup
CommandId.moveTabToNextGroup
CommandId.openInSide
```

Then all are available through the command palette.

---

# 35. Drag tab between groups

User drags:

```text
AuthService.java
```

toward the right:

```text
┌───────────────┬───────────────┐
│               │               │
│               │   ← drop      │
│               │               │
└───────────────┴───────────────┘
```

Show a clear drop preview before moving it.

---

# 36. Preserve editor state

Each tab should remember:

```dart
class EditorViewState {
  final int cursorLine;
  final int cursorColumn;

  final int scrollTop;

  final List<String> expandedSymbols;

  const EditorViewState({
    this.cursorLine = 0,
    this.cursorColumn = 0,
    this.scrollTop = 0,
    this.expandedSymbols = const [],
  });
}
```

Reopening the file should return the user to where they were.

---

# 37. Workspace restore

On startup:

```text
Loading workspace...
```

then restore:

```text
✓ Open tabs
✓ Editor groups
✓ Sidebar state
✓ Agent state
✓ Bottom panel
✓ Cursor positions
✓ Scroll positions
```

Don't restore transient things like:

```text
temporary toast
old notification
completed progress indicator
```

---

# 38. Workspace shell should have one source of truth

Avoid:

```text
SidebarController
EditorController
AgentController
LayoutController
```

all independently deciding whether panels are visible.

Instead:

```text
WorkspaceController
        │
        ├── Layout
        ├── Focus
        ├── Active mode
        ├── Panels
        └── Editor groups
```

Specialized controllers can manage their internal state, but shell state should have one owner.

---

# 39. Workspace controller

```dart
class WorkspaceController extends ChangeNotifier {
  WorkspaceLayout _layout;

  WorkspaceController({
    required WorkspaceLayout initialLayout,
  }) : _layout = initialLayout;

  WorkspaceLayout get layout => _layout;

  void togglePanel(PanelId id) {
    final panel = _layout.panels[id];

    if (panel == null) return;

    _layout = _layout.copyWith(
      panels: {
        ..._layout.panels,
        id: panel.copyWith(
          visible: !panel.visible,
        ),
      },
    );

    notifyListeners();
  }

  void setMode(WorkspaceMode mode) {
    _layout = _layout.copyWith(
      mode: mode,
    );

    notifyListeners();
  }
}
```

---

# 40. Mode presets

Create presets rather than hardcoding UI logic everywhere.

```dart
class WorkspacePresets {
  static WorkspaceLayout coding() {
    return WorkspaceLayout(
      mode: WorkspaceMode.coding,
    );
  }

  static WorkspaceLayout reviewing() {
    return WorkspaceLayout(
      mode: WorkspaceMode.reviewing,
    );
  }

  static WorkspaceLayout debugging() {
    return WorkspaceLayout(
      mode: WorkspaceMode.debugging,
    );
  }

  static WorkspaceLayout agent() {
    return WorkspaceLayout(
      mode: WorkspaceMode.agent,
    );
  }
}
```

---

# 41. Review mode

When the user clicks:

```text
Review Changes
```

the shell can automatically arrange:

```text
┌──────────────┬───────────────────────────────┐
│ Changed Files│ Diff                          │
│              │                               │
│ Auth.java    │ - old                         │
│ Session.java │ + new                         │
│ Test.java    │                               │
│              │                               │
└──────────────┴───────────────────────────────┘
```

But don't permanently alter their normal coding layout.

When review ends:

```text
Return to previous layout
```

---

# 42. Layout snapshots

Before switching modes:

```dart
class LayoutSnapshot {
  final WorkspaceLayout layout;

  const LayoutSnapshot({
    required this.layout,
  });
}
```

Then:

```text
Coding layout
      ↓
save snapshot
      ↓
Review mode
      ↓
finish
      ↓
restore snapshot
```

This is a subtle but excellent UX feature.

---

# 43. The shell now becomes adaptive

Instead of:

```text
static IDE
```

we have:

```text
Workspace
    ↓
understands current task
    ↓
adjusts presentation
    ↓
preserves user's preferred layout
```

---

# 44. Final shell architecture

```text
                         APP SHELL
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
       ▼                    ▼                    ▼
 Activity Bar          Workspace State       Status Bar
       │                    │
       │             ┌──────┼──────┐
       │             ▼      ▼      ▼
       │           Layout  Focus  Mode
       │
       ▼
 Primary Sidebar
       │
       ├── Explorer
       ├── Search
       ├── Git
       ├── Agent
       └── Tests
                            │
                            ▼
                      Editor Groups
                            │
                  ┌─────────┴─────────┐
                  ▼                   ▼
               Editor A            Editor B
                  │                   │
                  └─────────┬─────────┘
                            ▼
                       Bottom Panel
                            │
                ┌───────────┼───────────┐
                ▼           ▼           ▼
             Problems    Terminal     Output
```

---

# 45. One UX rule to enforce everywhere

Whenever we add a new feature, ask:

```text
Can the user:

1. discover it?
2. invoke it quickly?
3. understand what happened?
4. undo/recover?
5. return to their previous context?
```

If any answer is "no", the feature is not finished.

That rule will keep the UI from becoming progressively more complicated as functionality grows.

---

## Next: Design System + Visual Polish

With the shell architecture done, the next pass should stop adding major functionality and establish the **visual design system in actual code**:

```text
Design tokens
    ↓
Typography
    ↓
Spacing
    ↓
Colors
    ↓
Surfaces
    ↓
Borders
    ↓
Elevation
    ↓
Icons
    ↓
Motion
    ↓
Hover / focus / pressed states
    ↓
Empty / loading / error states
```

Then we can apply those tokens consistently across **Editor, Agent, Diff, Explorer, Command Palette, Problems, Terminal, and every other surface**, which is where the product starts getting the final polished feel rather than just accumulating features.


# Next: Design System + Visual Polish

Now we move from **architecture** to the layer users actually feel: visual consistency.

The goal is not "make everything prettier." It is:

> **Every interaction should look like it belongs to the same product.**

---

# 1. Create design tokens

Add:

```text id="1p7n8e"
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
    │   ├── dark_theme.dart
    │   └── light_theme.dart
    │
    └── components/
        ├── app_button.dart
        ├── app_icon_button.dart
        ├── app_input.dart
        ├── app_tooltip.dart
        ├── app_badge.dart
        ├── app_divider.dart
        └── app_surface.dart
```

Do **not** scatter values like:

```dart
padding: EdgeInsets.all(13)
```

through hundreds of widgets.

Use tokens.

---

# 2. Spacing system

Start with a small scale.

```dart id="v41c9j"
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}
```

Then:

```dart id="xv19fm"
Padding(
  padding: const EdgeInsets.all(
    AppSpacing.lg,
  ),
)
```

This makes global adjustment easy.

---

# 3. Radius system

Don't randomly use:

```text
3px
5px
7px
11px
14px
```

Use a controlled scale.

```dart id="g6t7je"
abstract final class AppRadii {
  static const sm = 4.0;
  static const md = 6.0;
  static const lg = 8.0;
  static const xl = 12.0;
}
```

For an IDE, keep radii relatively restrained.

You don't want every panel looking like a floating mobile card.

---

# 4. Typography

```dart id="8c0v6b"
abstract final class AppTypography {
  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 13,
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

The important distinction:

```text
UI text → UI font
Code    → monospace
```

Never use the code font for ordinary interface labels.

---

# 5. Color architecture

Don't make components choose colors independently.

Create semantic colors.

```dart id="o1k6qf"
class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceElevated;

  final Color border;

  final Color text;
  final Color textMuted;
  final Color textSubtle;

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
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });
}
```

---

# 6. Why semantic colors matter

Bad:

```dart
color: Color(0xff292929)
```

Better:

```dart
color: theme.colors.surface
```

Now if we later decide the entire interface should be slightly lighter, we change one token.

---

# 7. Dark theme

For an IDE, avoid pure black.

Use layered surfaces.

```text id="dsh5ae"
Background
   ↓
Surface
   ↓
Elevated surface
   ↓
Active surface
```

Example:

```dart id="m3r7e8"
const darkColors = AppColors(
  background: Color(0xFF101114),
  surface: Color(0xFF17181C),
  surfaceElevated: Color(0xFF1D1F24),
  border: Color(0xFF292C33),

  text: Color(0xFFE7E9ED),
  textMuted: Color(0xFF9CA1AA),
  textSubtle: Color(0xFF70757F),

  accent: Color(0xFF7C9CFF),

  success: Color(0xFF55C58A),
  warning: Color(0xFFE4B65A),
  error: Color(0xFFE06C75),
  info: Color(0xFF69A8E8),
);
```

---

# 8. Don't overuse accent color

Accent should communicate:

```text
selected
focused
interactive
important
```

It should **not** color every button.

For example:

```text id="7k6njr"
Explorer       neutral
Search         neutral
Agent          accent when selected
Editor         neutral
Primary action accent
```

This creates hierarchy.

---

# 9. Surfaces

Create one reusable surface.

```dart id="e8qv7u"
class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border.all(
          color: theme.colors.border,
        ),
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(
              AppSpacing.md,
            ),
        child: child,
      ),
    );
  }
}
```

---

# 10. Avoid excessive borders

A common IDE mistake:

```text
┌────────┬────────┬────────┐
│        │        │        │
├────────┼────────┼────────┤
│        │        │        │
├────────┼────────┼────────┤
│        │        │        │
└────────┴────────┴────────┘
```

Every surface gets a border.

It becomes visually noisy.

Instead use:

```text
surface difference
+
one-pixel separators
+
subtle hover states
```

Only emphasize boundaries that matter.

---

# 11. Panel separator

```dart id="j3j9p0"
class PanelDivider extends StatelessWidget {
  const PanelDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.of(context)
          .colors
          .border,
      child: const SizedBox(
        width: 1,
      ),
    );
  }
}
```

---

# 12. Buttons

Create variants.

```dart id="f1r1z8"
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}
```

Then:

```dart id="6j0kge"
AppButton(
  label: 'Review Changes',
  variant: AppButtonVariant.primary,
  onPressed: review,
)
```

---

# 13. Button hierarchy

Primary:

```text
[ Review Changes ]
```

Secondary:

```text
[ Cancel ]
```

Ghost:

```text
  Cancel
```

Danger:

```text
[ Delete ]
```

Don't make every action look equally important.

---

# 14. App button implementation

```dart id="r0s7ti"
class AppButton extends StatefulWidget {
  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.secondary,
    this.onPressed,
  });

  @override
  State<AppButton> createState() =>
      _AppButtonState();
}
```

Then map the variant to the theme.

The key is that **components never know raw colors**.

---

# 15. Icon buttons

IDE interfaces use many icon buttons, so this component deserves special attention.

```dart id="i2s3q5"
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
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
        icon: Icon(icon),
      ),
    );
  }
}
```

---

# 16. Icon button states

Every icon button needs:

```text id="3h98ft"
normal
hover
pressed
focused
selected
disabled
```

Don't rely on the default widget state everywhere.

Create a consistent state layer.

---

# 17. Hover behavior

For desktop software, hover is a major communication channel.

Example:

```text id="u9t0ec"
normal:
   Explorer

hover:
   ▌ Explorer

selected:
   █ Explorer
```

Keep hover subtle.

The goal is **discoverability**, not visual animation.

---

# 18. Mouse cursor

Interactive regions should communicate interaction.

```dart id="3x7v7m"
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: child,
)
```

For resize handles:

```dart id="0n31ec"
SystemMouseCursors.resizeLeftRight
```

For draggable tabs:

```dart id="n1t7ik"
SystemMouseCursors.grab
```

---

# 19. Focus rings

Keyboard users need visible focus.

Create:

```dart id="5z8t8j"
class AppFocusRing extends StatelessWidget {
  final Widget child;
  final bool focused;

  const AppFocusRing({
    super.key,
    required this.child,
    required this.focused,
  });

  @override
  Widget build(BuildContext context) {
    if (!focused) {
      return child;
    }

    final theme = AppTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colors.accent,
        ),
      ),
      child: child,
    );
  }
}
```

Don't rely exclusively on color.

---

# 20. Tooltips

Tooltips should explain unfamiliar icons.

Bad:

```text
⚙
```

with no tooltip.

Good:

```text
⚙
Settings
```

For shortcuts:

```text
Save File
Ctrl+S
```

Build that into the tooltip component.

---

# 21. Tooltip model

```dart id="t4x6i1"
class AppTooltip extends StatelessWidget {
  final String label;
  final String? shortcut;
  final Widget child;

  const AppTooltip({
    super.key,
    required this.label,
    this.shortcut,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final text = shortcut == null
        ? label
        : '$label    $shortcut';

    return Tooltip(
      message: text,
      child: child,
    );
  }
}
```

---

# 22. Badges

For:

```text id="c5w44e"
Problems 3
Agent 2
Git 5
```

create one component.

```dart id="b2sp7w"
class AppBadge extends StatelessWidget {
  final String label;

  const AppBadge({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(
          AppRadii.sm,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption,
      ),
    );
  }
}
```

---

# 23. Motion tokens

Don't sprinkle:

```dart
Duration(milliseconds: 127)
```

everywhere.

```dart
abstract final class AppMotion {
  static const fast =
      Duration(milliseconds: 100);

  static const normal =
      Duration(milliseconds: 160);

  static const slow =
      Duration(milliseconds: 240);
}
```

---

# 24. Animation principle

Use motion for:

```text
state transition
panel opening
panel closing
selection
feedback
```

Don't animate:

```text
every hover
every line
every text change
```

A developer tool needs to feel **fast**.

---

# 25. Panel animation

```dart id="wz3v2e"
AnimatedContainer(
  duration: AppMotion.normal,
  curve: Curves.easeOut,
  width: panelVisible
      ? layout.sidebarWidth
      : 0,
  child: panel,
)
```

For complex panels, use `AnimatedSwitcher`.

---

# 26. Command palette animation

Use:

```text id="0j2vsm"
opacity
+
small vertical movement
```

Not:

```text id="d6n4v0"
huge zoom
```

It should feel like an interface layer appearing, not a modal advertisement.

---

# 27. Loading states

Never show:

```text id="8l2z9s"
Loading...
```

everywhere.

Use context-specific states.

For Agent:

```text id="7z8h4r"
● Inspecting workspace
```

For search:

```text id="1p3j5c"
Searching workspace…
```

For indexing:

```text id="j4x9ez"
Indexing 1,248 files…
```

---

# 28. Skeletons

For large UI surfaces:

```text id="v1p1v3"
┌──────────────────────────┐
│ █████████████             │
│ ███████                   │
│ ███████████████           │
│                           │
│ ██████████                │
└──────────────────────────┘
```

But don't use skeletons for a 100ms operation.

Only use them when waiting is perceptible.

---

# 29. Empty states

An empty panel should explain what to do.

Bad:

```text id="m3a1m8"
No data
```

Good:

```text id="8j91b1"
No problems

Problems will appear here
when the workspace is analyzed.

[Run Analysis]
```

Agent:

```text id="f6u3e1"
No active task

Ask Agent to inspect, explain,
or modify your workspace.

[Ask Agent]
```

---

# 30. Error states

Don't show raw exceptions.

Bad:

```text id="m2p9q1"
Exception: SocketException...
```

Better:

```text id="r5y8dv"
Couldn't connect to the Agent

The request could not be completed.

[Retry]    [Details]
```

`Details` can expose technical information for advanced users.

---

# 31. Diff colors

Diff UI deserves semantic treatment.

```dart id="7e2lba"
class DiffColors {
  final Color addedBackground;
  final Color removedBackground;

  final Color addedText;
  final Color removedText;

  const DiffColors({
    required this.addedBackground,
    required this.removedBackground,
    required this.addedText,
    required this.removedText,
  });
}
```

Don't make additions/removals so saturated that reading code becomes difficult.

---

# 32. Diff hunk controls

Each hunk should expose:

```text id="jq9hpa"
┌───────────────────────────────────────────┐
│ +12 -4                    ⋯               │
│                                           │
│ - old code                                │
│ + new code                                │
│                                           │
│ [Accept] [Reject]                         │
└───────────────────────────────────────────┘
```

The controls should appear primarily on hover.

This keeps the diff clean.

---

# 33. Agent visual hierarchy

Don't make the Agent panel look like a generic chat application.

Avoid:

```text id="y48my7"
User bubble
Agent bubble
User bubble
Agent bubble
```

Instead:

```text id="k2v4by"
TASK
────────────────────────

Fix token refresh handling

CONTEXT
────────────────────────

AuthService.java
SessionService.java
3 tests

PROPOSED CHANGES
────────────────────────

3 files
+42 −11

[Review Changes]
```

It should feel like an **engineering workspace**, not a chatbot.

---

# 34. Agent message component

```dart id="x4z5as"
enum AgentBlockType {
  text,
  file,
  command,
  changeSet,
  diagnostic,
  verification,
}
```

Then:

```dart id="x4v4kq"
class AgentBlock {
  final AgentBlockType type;
  final String title;
  final String? content;

  const AgentBlock({
    required this.type,
    required this.title,
    this.content,
  });
}
```

Now Agent output can be rendered consistently.

---

# 35. Verification block

```text id="fpp1dw"
VERIFICATION

✓ AuthServiceTest
✓ SessionServiceTest
✓ TokenRefreshTest

3 / 3 passed

[Open Test Results]
```

This is much stronger than:

```text
"Everything seems good."
```

---

# 36. Status bar polish

Use the status bar for persistent context:

```text id="nprnqv"
Ln 81, Col 14   UTF-8   Java
Git: feature/auth
                 ✓ 0 errors
```

Avoid putting transient notifications here.

---

# 37. Visual density

The IDE should have **three density levels**.

### Dense

Code editor, file tree:

```text
small padding
small text
high information density
```

### Normal

Agent, search, problems:

```text
moderate spacing
```

### Spacious

Empty states, onboarding:

```text
more breathing room
```

Don't make every surface equally dense.

---

# 38. Theme extension

Expose one theme object:

```dart id="pxqvub"
class AppThemeData {
  final AppColors colors;

  final AppTypography typography;

  final AppMotion motion;

  const AppThemeData({
    required this.colors,
    required this.typography,
    required this.motion,
  });
}
```

Then:

```dart id="k9s4vz"
class AppTheme extends InheritedWidget {
  final AppThemeData data;

  const AppTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static AppThemeData of(
    BuildContext context,
  ) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<
            AppTheme>();

    return widget!.data;
  }

  @override
  bool updateShouldNotify(
    AppTheme oldWidget,
  ) {
    return data != oldWidget.data;
  }
}
```

---

# 39. Theme provider

At the root:

```dart id="j6o2io"
AppTheme(
  data: AppThemeData(
    colors: darkColors,
    typography: AppTypographyData(),
    motion: AppMotionData(),
  ),
  child: const AppShell(),
)
```

Now the entire application gets one visual language.

---

# 40. Theme switching

Later:

```text id="9p4v7v"
Dark
Light
System
```

The components don't change.

Only the theme changes.

---

# 41. Important: don't over-customize

For an engineering product, polish comes from:

```text
consistency
+
spacing
+
hierarchy
+
responsiveness
+
feedback
```

not from:

```text
gradients everywhere
+
glowing borders
+
large animations
+
giant icons
```

The interface should feel **quiet and powerful**.

---

# 42. Visual hierarchy of the whole product

After this pass:

```text id="9f3v9k"
                APPLICATION
                     │
        ┌────────────┴────────────┐
        │                         │
      PRIMARY                   SECONDARY
     WORKSPACE                  CONTEXT
        │                         │
     Editor                    Agent
        │                       Diff
        │                     Problems
        │                       Search
        │
   Code / Files
        │
        ▼
    Primary action
```

The visual weight should follow the same hierarchy.

---

# 43. The resulting UI

Conceptually:

```text id="y2v5pi"
┌──────────────────────────────────────────────────────────────────────┐
│ Aljabr    Project       Search                         ✦ Agent   ●  │
├───┬───────────────┬──────────────────────────────────┬──────────────┤
│   │ Explorer      │ AuthService.java ×               │              │
│ 📁│               ├──────────────────────────────────┤              │
│ 🔎│ ▼ lib         │ lib › auth › AuthService         │    Agent     │
│ ◇ │   auth        │                                  │              │
│ ✦ │   session     │  1 class AuthService {           │  TASK        │
│   │               │  2                              │              │
│   │               │  3   refreshToken() {            │  Fix token   │
│   │               │  4     ...                       │  handling    │
│   │               │  5   }                           │              │
│   │               │                                  │  ✓ Context  │
│   │               │                                  │  ✓ Analysis │
│   │               │                                  │  ● Changes  │
│   │               │                                  │              │
├───┴───────────────┴──────────────────────────────────┴──────────────┤
│ Problems 1     Terminal     Output                                  │
├─────────────────────────────────────────────────────────────────────┤
│ Ln 81, Col 14       UTF-8       Java       Git: feature/auth   ✓ 0 │
└─────────────────────────────────────────────────────────────────────┘
```

That is the visual direction I'd lock in.

---

# 44. Next: Micro-interactions + UX finishing pass

At this point the architecture and visual system are strong. The next pass should focus on the details users subconsciously notice:

```text
Tab drag behavior
↓
Selection behavior
↓
Keyboard navigation
↓
Context menus
↓
Hover previews
↓
Inline actions
↓
Undo / redo feedback
↓
Command palette ranking
↓
Agent streaming behavior
↓
Diff transitions
↓
Error recovery
↓
First-run experience
↓
Accessibility
↓
Performance polish
```

The particularly important next piece is **keyboard-first UX**: make essentially the entire application operable without reaching for the mouse, while keeping mouse interactions equally discoverable.


# Next: Keyboard-First UX

Now we make the entire shell **fast without a mouse**.

The principle is simple:

> Every important action should have a predictable keyboard path, and focus should never feel lost.

---

## 1. Keyboard architecture

Add:

```text id="x0r1fa"
lib/
└── keyboard/
    ├── keyboard_manager.dart
    ├── keymap.dart
    ├── keybinding.dart
    ├── key_context.dart
    └── key_hint.dart
```

We already have the `CommandBus`, so keyboard handling should **only resolve keys → commands**.

Never put business logic directly inside keyboard handlers.

---

# 2. Keybinding model

```dart
class KeyBinding {
  final String id;
  final CommandId command;

  final LogicalKeyboardKey key;

  final bool control;
  final bool meta;
  final bool shift;
  final bool alt;

  final KeyContext context;

  const KeyBinding({
    required this.id,
    required this.command,
    required this.key,
    this.control = false,
    this.meta = false,
    this.shift = false,
    this.alt = false,
    this.context = KeyContext.global,
  });
}
```

---

# 3. Contexts

Not every shortcut should work everywhere.

```dart
enum KeyContext {
  global,
  editor,
  terminal,
  agent,
  commandPalette,
  input,
  diff,
}
```

Example:

```text
Ctrl+F
```

could mean:

```text
Editor      → Find
Command     → search commands
Agent       → search conversation
Terminal    → terminal search
```

Same key, different context.

---

# 4. Default keymap

```dart
final defaultKeymap = <KeyBinding>[
  KeyBinding(
    id: 'save',
    command: CommandId.saveFile,
    key: LogicalKeyboardKey.keyS,
    control: true,
  ),

  KeyBinding(
    id: 'command-palette',
    command: CommandId.openCommandPalette,
    key: LogicalKeyboardKey.keyP,
    control: true,
  ),

  KeyBinding(
    id: 'quick-open',
    command: CommandId.goToFile,
    key: LogicalKeyboardKey.keyP,
    control: true,
    shift: true,
  ),

  KeyBinding(
    id: 'toggle-terminal',
    command: CommandId.toggleTerminal,
    key: LogicalKeyboardKey.backquote,
    control: true,
  ),
];
```

For macOS, normalize `Control` / `Meta` behind the keybinding layer rather than duplicating bindings.

---

# 5. Shortcut normalization

```dart
bool matchesBinding(
  KeyEvent event,
  KeyBinding binding,
) {
  final pressed = HardwareKeyboard.instance;

  return event.logicalKey == binding.key &&
      pressed.isControlPressed == binding.control &&
      pressed.isMetaPressed == binding.meta &&
      pressed.isShiftPressed == binding.shift &&
      pressed.isAltPressed == binding.alt;
}
```

Then map platform-specific modifier behavior centrally.

---

# 6. Keyboard manager

```dart
class KeyboardManager {
  final CommandBus commandBus;

  KeyboardManager({
    required this.commandBus,
  });

  Future<void> handle(
    KeyEvent event,
    CommandContext context,
    KeyContext keyContext,
  ) async {
    if (event is! KeyDownEvent) {
      return;
    }

    final binding = resolveBinding(
      event,
      keyContext,
    );

    if (binding == null) {
      return;
    }

    await commandBus.execute(
      binding.command,
      context,
    );
  }
}
```

---

# 7. Focus stack

This is more important than it looks.

Track:

```text
current focus
previous focus
modal focus
```

```dart
class FocusStack {
  final List<FocusNode> _stack = [];

  void push(FocusNode node) {
    _stack.add(node);
  }

  void pop() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  void restore() {
    if (_stack.isNotEmpty) {
      _stack.last.requestFocus();
    }
  }
}
```

---

# 8. Command palette behavior

When opened:

```text
Editor focused
     ↓
Ctrl+P
     ↓
remember editor focus
     ↓
palette gets focus
```

When closed:

```text
Esc
 ↓
palette closes
 ↓
editor focus restored
```

That tiny detail makes the application feel dramatically more polished.

---

# 9. Focus trap for overlays

For modal surfaces:

```dart
FocusTraversalGroup(
  policy: WidgetOrderTraversalPolicy(),
  child: dialog,
)
```

The user should not accidentally tab into UI behind the modal.

---

# 10. Tab navigation

Within a panel:

```text
Tab
 ↓
next interactive element
```

```text
Shift + Tab
 ↓
previous
```

Don't make every decorative element focusable.

Only:

```text
buttons
inputs
tabs
links
interactive rows
```

---

# 11. Activity bar shortcuts

Give the major surfaces direct access.

For example:

```text
Ctrl+1 → Explorer
Ctrl+2 → Search
Ctrl+3 → Source Control
Ctrl+4 → Agent
```

Implementation:

```dart
KeyBinding(
  id: 'open-explorer',
  command: CommandId.openExplorer,
  key: LogicalKeyboardKey.digit1,
  control: true,
)
```

---

# 12. Sidebar navigation

Once Explorer is focused:

```text
↑ ↓
```

navigate files.

```text
→
```

expand folder.

```text
←
```

collapse folder.

```text
Enter
```

open file.

```text
Space
```

preview.

```text
Delete
```

should require the appropriate confirmation flow.

---

# 13. Tree navigation model

```dart
class TreeNavigationController {
  int _index = 0;

  void moveNext() {
    _index++;
  }

  void movePrevious() {
    if (_index > 0) {
      _index--;
    }
  }

  void expand() {}

  void collapse() {}

  void activate() {}
}
```

Keep navigation state separate from rendering.

---

# 14. Editor shortcuts

Core set:

```text
Ctrl/Cmd + P
Go to file

Ctrl/Cmd + Shift + O
Go to symbol

Ctrl/Cmd + G
Go to line

Ctrl/Cmd + F
Find

Ctrl/Cmd + H
Replace

F12
Go to definition

Shift + F12
Find references

Ctrl/Cmd + .
Quick fix

Ctrl/Cmd + Shift + P
Command palette
```

These should all become `CommandId`s.

---

# 15. Go-to-line overlay

Don't open a full modal.

Use a small overlay:

```text
┌─────────────────────────┐
│ Go to line              │
│ > 284                   │
└─────────────────────────┘
```

Enter:

```text
line 284
```

and focus returns to the editor.

---

# 16. Inline find

When the user presses:

```text
Ctrl+F
```

show:

```text
┌────────────────────────────┐
│ Search: token_refresh  2/8 │
└────────────────────────────┘
```

Keyboard:

```text
Enter       next
Shift+Enter previous
Esc         close
```

---

# 17. Search should preserve context

After:

```text
Ctrl+F
```

then:

```text
Esc
```

the selection should remain.

Don't reset the editor position.

---

# 18. Command palette ranking

Our previous simple `contains()` search should now become ranked.

```dart
class RankedCommand {
  final AppCommand command;
  final double score;

  const RankedCommand({
    required this.command,
    required this.score,
  });
}
```

Rank based on:

```text
exact title
prefix match
word match
fuzzy match
recent usage
frequency
category
```

---

# 19. Ranking example

Query:

```text
ref
```

Results:

```text
1  Find References
2  Refresh Workspace
3  Review Changes
4  Open Reference Documentation
```

If the user frequently uses:

```text
Find References
```

it should rise toward the top.

---

# 20. Recent command weighting

```dart
double recentBoost(CommandId id) {
  final index = recentCommands.indexOf(id);

  if (index == -1) {
    return 0;
  }

  return 1.0 / (index + 1);
}
```

Then:

```dart
score =
    fuzzyScore +
    recentBoost(command.id);
```

---

# 21. Command palette keyboard UX

Implement:

```dart
class CommandPaletteState {
  int selectedIndex = 0;

  void next(int count) {
    selectedIndex =
        (selectedIndex + 1) % count;
  }

  void previous(int count) {
    selectedIndex =
        (selectedIndex - 1 + count) % count;
  }
}
```

Then:

```text
↑ / ↓ → selection
Enter → execute
Esc → close
```

---

# 22. Command palette preview

For commands with consequences, show a small description.

```text
Review Changes
────────────────────────

Review pending workspace
changes and open the
ChangeSet panel.

Enter to run
```

This reduces uncertainty.

---

# 23. Dangerous commands

For:

```text
Delete file
Discard changes
Reset workspace
```

don't immediately execute from the palette.

Use:

```text
command
 ↓
confirmation
 ↓
action
```

But avoid confirmation for routine actions.

---

# 24. Confirmation model

```dart
class ConfirmationRequest {
  final String title;
  final String message;
  final String confirmLabel;
  final bool dangerous;

  const ConfirmationRequest({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.dangerous = false,
  });
}
```

---

# 25. Undo architecture

This is the next big UX layer.

Users need confidence that actions are reversible.

Add:

```text
lib/
└── undo/
    ├── undoable_action.dart
    ├── undo_manager.dart
    └── undo_stack.dart
```

---

# 26. Undoable action

```dart
abstract interface class UndoableAction {
  String get description;

  Future<void> execute();

  Future<void> undo();
}
```

Example:

```dart
class ApplyChangeSetAction
    implements UndoableAction {

  @override
  String get description =>
      'Apply ChangeSet';

  @override
  Future<void> execute() async {
    // apply
  }

  @override
  Future<void> undo() async {
    // revert
  }
}
```

---

# 27. Undo manager

```dart
class UndoManager {
  final List<UndoableAction> _undo = [];
  final List<UndoableAction> _redo = [];

  Future<void> execute(
    UndoableAction action,
  ) async {
    await action.execute();

    _undo.add(action);
    _redo.clear();
  }

  Future<void> undo() async {
    if (_undo.isEmpty) return;

    final action = _undo.removeLast();

    await action.undo();

    _redo.add(action);
  }

  Future<void> redo() async {
    if (_redo.isEmpty) return;

    final action = _redo.removeLast();

    await action.execute();

    _undo.add(action);
  }
}
```

---

# 28. Undo feedback

After an Agent operation:

```text
┌────────────────────────────────────┐
│ ✓ Changes applied                  │
│ 3 files updated                    │
│                                    │
│                         Undo       │
└────────────────────────────────────┘
```

`Undo` should execute through the same command system.

---

# 29. Global undo

```dart
registry.register(
  AppCommand(
    id: CommandId.undo,
    title: 'Undo',
    shortcut: 'Ctrl+Z',
    category: 'Edit',

    isEnabled: (_) =>
        undoManager.canUndo,

    execute: (_) async {
      await undoManager.undo();

      return const CommandResult.success();
    },
  ),
);
```

Now the user has one consistent undo experience.

---

# 30. Agent changes must be undoable

This is critical.

Agent:

```text
"Refactor authentication"
```

should produce:

```text
ChangeSet
   ↓
Apply
   ↓
UndoableAction
```

not directly mutate files with no recovery mechanism.

---

# 31. Multi-step Agent undo

If the Agent does:

```text
1. modify AuthService
2. modify SessionService
3. modify tests
```

the user should be able to:

```text
Undo
```

the entire coherent operation.

Not:

```text
Undo AuthService
Undo SessionService
Undo test
```

unless they explicitly want granular history.

---

# 32. Transaction model

Create:

```dart
class ActionTransaction {
  final String description;
  final List<UndoableAction> actions;

  const ActionTransaction({
    required this.description,
    required this.actions,
  });
}
```

Then:

```text
Agent Task
   ↓
transaction
   ├── AuthService
   ├── SessionService
   └── Tests
```

One undo.

---

# 33. UX rule for long operations

Never freeze the interface.

Bad:

```text
[everything disabled]
```

Better:

```text
Agent working…

Editor remains readable.
Cancel available.
```

---

# 34. Cancellation

Every long-running operation should support:

```dart
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() {
    _cancelled = true;
  }
}
```

Agent:

```text
● Inspecting files
● Running tests

[Cancel]
```

---

# 35. Cancellation semantics

Cancellation should mean:

```text
stop future work
+
preserve already completed safe work
+
don't leave half-applied ChangeSets
```

For mutations, prefer:

```text
prepare
 ↓
validate
 ↓
apply atomically
```

rather than partially modifying the workspace.

---

# 36. Agent streaming

Don't render every token as a new expensive widget.

Use a buffer:

```dart
class StreamBuffer {
  final StringBuffer _buffer = StringBuffer();

  void append(String chunk) {
    _buffer.write(chunk);
  }

  String get value => _buffer.toString();
}
```

Throttle UI updates.

For example:

```text
20–60 updates/sec max
```

rather than rebuilding the entire panel for every token.

---

# 37. Agent typing indicator

Instead of:

```text
Agent is typing...
```

use meaningful work:

```text
● Searching workspace
● Inspecting AuthService
● Running tests
```

This reinforces that the Agent is operating as a tool.

---

# 38. Contextual keyboard hints

When hovering an action:

```text
Review Changes

Ctrl+Shift+R
```

When a new user first encounters the action:

```text
Review Changes
               Ctrl+Shift+R
```

This gradually teaches the keymap.

---

# 39. Shortcut discovery

Add a small command:

```text
Keyboard Shortcuts
```

which opens:

```text
┌──────────────────────────────────────────────┐
│ Keyboard Shortcuts                           │
├──────────────────────────────────────────────┤
│ Search shortcuts...                          │
│                                              │
│ General                                      │
│ Save                  Ctrl+S                 │
│ Command Palette      Ctrl+Shift+P            │
│ Quick Open            Ctrl+P                 │
│                                              │
│ Editor                                       │
│ Find                  Ctrl+F                 │
│ Go to Definition      F12                    │
│                                              │
│ Agent                                        │
│ Explain Selection     Ctrl+Shift+E           │
└──────────────────────────────────────────────┘
```

---

# 40. Custom keybindings

Eventually allow:

```text
Ctrl+Shift+E
```

to be changed.

Model:

```dart
class UserKeymap {
  final Map<String, KeyBinding> bindings;

  const UserKeymap({
    required this.bindings,
  });
}
```

Persist per user.

---

# 41. Conflict detection

If the user assigns:

```text
Ctrl+S
```

to two commands:

```text
Save
Run Tests
```

show:

```text
Shortcut conflict

Ctrl+S is already assigned to:

Save File

[Replace] [Cancel]
```

Never silently create ambiguous shortcuts.

---

# 42. Accessibility

Now apply the same system to accessibility.

Every interactive widget should have:

```text
accessible name
role
state
keyboard interaction
```

For example:

```dart
Semantics(
  button: true,
  label: 'Review Changes',
  enabled: true,
  child: button,
)
```

---

# 43. Don't communicate state only through color

Bad:

```text
green = passed
red = failed
```

Better:

```text
✓ Passed
✕ Failed
```

Color reinforces the meaning.

It shouldn't be the only signal.

---

# 44. Reduced motion

Respect system settings.

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

# 45. High contrast

Your semantic color system makes this much easier.

Add a high-contrast theme:

```dart
final highContrastColors = ...
```

without rewriting components.

---

# 46. Keyboard UX architecture

At this point:

```text
                  Keyboard
                     │
                     ▼
               Key Resolver
                     │
             ┌───────┴────────┐
             ▼                ▼
          Context          Binding
             │                │
             └───────┬────────┘
                     ▼
                 Command ID
                     │
                     ▼
                 Command Bus
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
      Editor        Agent         Git
        │            │            │
        └────────────┼────────────┘
                     ▼
                 Undo/Redo
                     │
                     ▼
                 Feedback
```

That gives us a very clean interaction architecture.

---

# 47. The UX loop

Every important action now follows:

```text
DISCOVER
   ↓
INVOKE
   ↓
EXECUTE
   ↓
SHOW PROGRESS
   ↓
SHOW RESULT
   ↓
ALLOW RECOVERY
```

For example:

```text
Review Changes
      ↓
Command Palette
      ↓
Command Bus
      ↓
Agent / Diff
      ↓
Progress
      ↓
ChangeSet
      ↓
Apply
      ↓
✓ 3 files changed
      ↓
Undo
```

That is the UX loop we want throughout Aljabr.

---

# 48. Next: Interaction polish

The next pass should focus on **mouse and pointer interactions**:

```text
→ tab dragging
→ file dragging
→ drop zones
→ hover previews
→ context menus
→ right-click selection
→ inline actions
→ double-click behavior
→ middle-click tab closing
→ scroll behavior
→ sticky headers
→ breadcrumbs
→ peek definitions
→ code actions
→ multi-selection
```

The biggest one will be **drag-and-drop + contextual interaction**, because that is where a desktop IDE starts feeling genuinely native rather than like a web application placed inside a desktop shell.
