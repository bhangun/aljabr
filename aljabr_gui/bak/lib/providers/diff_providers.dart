import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_diff.dart';

/// File diffs produced by the agent, scoped per session (like
/// [chatTranscriptProvider]) so a forked session gets its own independent
/// copy instead of sharing the parent's.
class FileDiffsNotifier extends StateNotifier<List<FileDiff>> {
  FileDiffsNotifier(List<FileDiff> seed) : super(seed);

  /// Sets a single hunk's status within one file, immutably.
  void setHunkStatus(String path, String hunkId, HunkStatus status) {
    state = [
      for (final file in state)
        if (file.path == path)
          file.copyWith(
            hunks: [
              for (final hunk in file.hunks)
                if (hunk.id == hunkId) hunk.copyWith(status: status) else hunk,
            ],
          )
        else
          file,
    ];
  }

  /// Accepts (or rejects) every hunk in a file at once — the "Accept all" /
  /// "Reject all" affordance on the file card header.
  void setAllHunksInFile(String path, HunkStatus status) {
    state = [
      for (final file in state)
        if (file.path == path)
          file.copyWith(hunks: [for (final h in file.hunks) h.copyWith(status: status)])
        else
          file,
    ];
  }

  /// Rejects every hunk in every file — the "Revert all changes" action in
  /// the diff panel header. Works regardless of prior accept/reject state,
  /// so a user can change their mind after already reviewing everything.
  void revertAll() {
    state = [
      for (final file in state)
        file.copyWith(hunks: [for (final h in file.hunks) h.copyWith(status: HunkStatus.rejected)]),
    ];
  }
}

final Map<String, List<FileDiff>> _seedDiffs = {
  'wayang-code': [
    FileDiff(
      path: 'src/main/resources/application.properties',
      changeType: DiffChangeType.modified,
      hunks: [
        DiffHunk(
          id: 'h1',
          header: '@@ -18,6 +18,7 @@ quarkus.datasource config',
          lines: const [
            DiffLine(
              type: DiffLineType.context,
              content: 'quarkus.hibernate-orm.database.generation=none',
              oldLineNo: 21,
              newLineNo: 21,
            ),
            DiffLine(
              type: DiffLineType.addition,
              content: 'quarkus.hibernate-orm.mapping.format.global=ignore',
              newLineNo: 22,
            ),
            DiffLine(type: DiffLineType.context, content: '', oldLineNo: 22, newLineNo: 23),
            DiffLine(
              type: DiffLineType.context,
              content: '# --- Flyway ---',
              oldLineNo: 23,
              newLineNo: 24,
            ),
          ],
        ),
      ],
    ),
    FileDiff(
      path: 'docker-compose.yml',
      changeType: DiffChangeType.modified,
      hunks: [
        DiffHunk(
          id: 'h2',
          header: '@@ -10,7 +10,7 @@ services.postgres',
          lines: const [
            DiffLine(
              type: DiffLineType.context,
              content: '    image: postgres:16-alpine',
              oldLineNo: 10,
              newLineNo: 10,
            ),
            DiffLine(type: DiffLineType.deletion, content: '    ports: ["5432:5432"]', oldLineNo: 11),
            DiffLine(type: DiffLineType.addition, content: '    ports: ["5433:5432"]', newLineNo: 11),
            DiffLine(
              type: DiffLineType.context,
              content: '    environment:',
              oldLineNo: 12,
              newLineNo: 12,
            ),
          ],
        ),
        DiffHunk(
          id: 'h3',
          header: '@@ -22,3 +22,6 @@ services.redis',
          lines: const [
            DiffLine(type: DiffLineType.context, content: '  redis:', oldLineNo: 22, newLineNo: 22),
            DiffLine(type: DiffLineType.addition, content: '    healthcheck:', newLineNo: 23),
            DiffLine(
              type: DiffLineType.addition,
              content: '      test: ["CMD", "redis-cli", "ping"]',
              newLineNo: 24,
            ),
          ],
        ),
      ],
    ),
    FileDiff(
      path: 'src/main/resources/db/migration/V2__add_index.sql',
      changeType: DiffChangeType.added,
      hunks: [
        DiffHunk(
          id: 'h4',
          header: '@@ -0,0 +1,3 @@',
          lines: const [
            DiffLine(
              type: DiffLineType.addition,
              content: 'CREATE INDEX idx_sessions_project_id',
              newLineNo: 1,
            ),
            DiffLine(type: DiffLineType.addition, content: '  ON sessions (project_id);', newLineNo: 2),
          ],
        ),
      ],
    ),
  ],
};

/// Registers a seed diff set for a session id — used when forking so the
/// new session starts from a snapshot of its parent's pending changes.
void registerForkedDiffs(String sessionId, List<FileDiff> diffs) {
  _seedDiffs[sessionId] = diffs;
}

List<FileDiff> _diffSeedFor(String sessionId) => _seedDiffs[sessionId] ?? const [];

final fileDiffsProvider =
    StateNotifierProvider.family<FileDiffsNotifier, List<FileDiff>, String>(
  (ref, sessionId) => FileDiffsNotifier(_diffSeedFor(sessionId)),
);

/// Which file-diff cards are expanded. Kept as a single global set (not
/// per-session) — expand/collapse is just a display preference, so sharing
/// it across sessions is an acceptable simplification.
class ExpandedDiffFilesNotifier extends StateNotifier<Set<String>> {
  ExpandedDiffFilesNotifier()
      : super({'src/main/resources/application.properties'});

  void toggle(String path) {
    final next = {...state};
    if (!next.add(path)) next.remove(path);
    state = next;
  }
}

final expandedDiffFilesProvider =
    StateNotifierProvider<ExpandedDiffFilesNotifier, Set<String>>(
  (ref) => ExpandedDiffFilesNotifier(),
);

/// Aggregate +/- counts across all files in a session's diff.
final diffSummaryProvider = Provider.family<(int additions, int deletions), String>(
  (ref, sessionId) {
    final diffs = ref.watch(fileDiffsProvider(sessionId));
    final additions = diffs.fold<int>(0, (sum, d) => sum + d.additions);
    final deletions = diffs.fold<int>(0, (sum, d) => sum + d.deletions);
    return (additions, deletions);
  },
);

/// How many hunks in a session's diff are still awaiting a decision.
final pendingHunkCountProvider = Provider.family<int, String>((ref, sessionId) {
  final diffs = ref.watch(fileDiffsProvider(sessionId));
  return diffs.fold<int>(0, (sum, d) => sum + d.pendingCount);
});

/// Unified vs. side-by-side rendering — a user preference, shared globally
/// across sessions like [expandedDiffFilesProvider].
enum DiffViewMode { unified, split }

class DiffViewModeNotifier extends StateNotifier<DiffViewMode> {
  DiffViewModeNotifier() : super(DiffViewMode.unified);
  void select(DiffViewMode mode) => state = mode;
}

final diffViewModeProvider =
    StateNotifierProvider<DiffViewModeNotifier, DiffViewMode>(
  (ref) => DiffViewModeNotifier(),
);
