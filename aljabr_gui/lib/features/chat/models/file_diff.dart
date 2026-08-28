import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

enum DiffChangeType { added, modified, deleted, renamed }

extension DiffChangeTypeX on DiffChangeType {
  String get badge {
    switch (this) {
      case DiffChangeType.added:
        return 'A';
      case DiffChangeType.modified:
        return 'M';
      case DiffChangeType.deleted:
        return 'D';
      case DiffChangeType.renamed:
        return 'R';
    }
  }

  Color get color {
    switch (this) {
      case DiffChangeType.added:
        return AppTheme.accentGreen;
      case DiffChangeType.modified:
        return AppTheme.accentAmber;
      case DiffChangeType.deleted:
        return const Color(0xFFE0554C);
      case DiffChangeType.renamed:
        return AppTheme.accentBlue;
    }
  }
}

enum DiffLineType { context, addition, deletion }

/// One rendered row inside a hunk.
class DiffLine {
  final DiffLineType type;
  final String content;
  final int? oldLineNo;
  final int? newLineNo;

  const DiffLine({
    required this.type,
    required this.content,
    this.oldLineNo,
    this.newLineNo,
  });
}

/// Whether a hunk's proposed change has been kept or discarded. Mirrors the
/// per-hunk accept/reject affordance in Codex/Antigravity's diff review.
enum HunkStatus { pending, accepted, rejected }

extension HunkStatusX on HunkStatus {
  Color get color {
    switch (this) {
      case HunkStatus.pending:
        return AppTheme.textMuted;
      case HunkStatus.accepted:
        return AppTheme.accentGreen;
      case HunkStatus.rejected:
        return const Color(0xFFE0554C);
    }
  }

  String get label {
    switch (this) {
      case HunkStatus.pending:
        return 'Pending review';
      case HunkStatus.accepted:
        return 'Accepted';
      case HunkStatus.rejected:
        return 'Rejected';
    }
  }
}

/// A single contiguous block of changed lines (`@@ -a,b +c,d @@`), reviewed
/// and accepted/rejected independently of other hunks in the same file.
class DiffHunk {
  final String id;
  final String header;
  final List<DiffLine> lines;
  final HunkStatus status;

  const DiffHunk({
    required this.id,
    required this.header,
    required this.lines,
    this.status = HunkStatus.pending,
  });

  DiffHunk copyWith({HunkStatus? status}) {
    return DiffHunk(
        id: id, header: header, lines: lines, status: status ?? this.status);
  }

  int get additions =>
      lines.where((l) => l.type == DiffLineType.addition).length;
  int get deletions =>
      lines.where((l) => l.type == DiffLineType.deletion).length;
}

/// A single file's diff: a change type plus one or more independently
/// reviewable [DiffHunk]s.
class FileDiff {
  final String path;
  final DiffChangeType changeType;
  final List<DiffHunk> hunks;

  const FileDiff({
    required this.path,
    required this.changeType,
    required this.hunks,
  });

  FileDiff copyWith({List<DiffHunk>? hunks}) {
    return FileDiff(
        path: path, changeType: changeType, hunks: hunks ?? this.hunks);
  }

  int get additions => hunks.fold<int>(0, (sum, h) => sum + h.additions);
  int get deletions => hunks.fold<int>(0, (sum, h) => sum + h.deletions);

  bool get allResolved => hunks.every((h) => h.status != HunkStatus.pending);
  int get pendingCount =>
      hunks.where((h) => h.status == HunkStatus.pending).length;
}
