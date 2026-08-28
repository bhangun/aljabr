import '../../features/chat/models/file_diff.dart';
import '../../features/chat/models/file_reference.dart';

/// Line-based diff engine using Myers algorithm
class LineDiffEngine {
  /// Compute line-level diff between two strings
  static List<DiffLine> computeLineDiff(String original, String modified) {
    final oldLines = original.split('\n');
    final newLines = modified.split('\n');

    if (oldLines.isEmpty && newLines.isEmpty) return [];
    if (oldLines.isEmpty) {
      return newLines
          .map(
            (line) => DiffLine(
              type: DiffLineType.added,
              content: line,
              newLineNumber: null,
            ),
          )
          .toList();
    }
    if (newLines.isEmpty) {
      return oldLines
          .map(
            (line) => DiffLine(
              type: DiffLineType.removed,
              content: line,
              oldLineNumber: null,
            ),
          )
          .toList();
    }

    // Compute LCS
    final lcs = _computeLCS(oldLines, newLines);

    // Generate diff
    return _generateDiff(oldLines, newLines, lcs);
  }

  /// Compute full FileDiff from two strings
  static FileDiff compute({
    required String fileId,
    required String fileName,
    required String original,
    required String modified,
  }) {
    final lines = computeLineDiff(original, modified);
    final added = lines.where((l) => l.type == DiffLineType.added).length;
    final removed = lines.where((l) => l.type == DiffLineType.removed).length;

    return FileDiff(
      fileId: fileId,
      fileName: fileName,
      originalContent: original,
      modifiedContent: modified,
      lines: lines,
      addedLines: added,
      removedLines: removed,
    );
  }

  /// Extract code blocks from assistant markdown and map to file diffs.
  static List<FileDiff> extractDiffsFromResponse({
    required String responseText,
    required List<FileReference> contextFiles,
  }) {
    final diffs = <FileDiff>[];
    final codeBlockRegex = RegExp(
      r'```(?:(\w+)\s+)?(?:\/\/\s*)?([^\n]*\.[a-zA-Z0-9]+)?\n([\s\S]*?)```',
      multiLine: true,
    );

    for (final match in codeBlockRegex.allMatches(responseText)) {
      final lang = match.group(1) ?? '';
      final fileHint = match.group(2)?.trim() ?? '';
      final code = match.group(3) ?? '';

      // Try to match against context files
      FileReference? matched;
      if (fileHint.isNotEmpty) {
        matched = contextFiles
            .where((f) => f.name == fileHint || f.path == fileHint)
            .firstOrNull;
      }
      if (matched == null && contextFiles.isNotEmpty) {
        // Heuristic: pick first file with matching extension
        matched = contextFiles.where((f) => f.language == lang).firstOrNull;
      }

      if (matched != null && code.trim() != matched.content.trim()) {
        diffs.add(
          compute(
            fileId: matched.id,
            fileName: matched.name,
            original: matched.content,
            modified: code.trimRight(),
          ),
        );
      }
    }

    return diffs;
  }

  static List<String> _computeLCS(List<String> a, List<String> b) {
    final n = a.length;
    final m = b.length;
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    final result = <String>[];
    var i = n, j = m;
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        result.insert(0, a[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    return result;
  }

  static List<DiffLine> _generateDiff(
    List<String> oldLines,
    List<String> newLines,
    List<String> lcs,
  ) {
    final result = <DiffLine>[];
    var i = 0, j = 0, k = 0;
    var oldNum = 1, newNum = 1;

    while (i < oldLines.length || j < newLines.length) {
      if (k < lcs.length) {
        // Find next LCS match
        var nextOld = -1, nextNew = -1;
        for (var p = i; p < oldLines.length; p++) {
          if (oldLines[p] == lcs[k]) {
            nextOld = p;
            break;
          }
        }
        for (var p = j; p < newLines.length; p++) {
          if (newLines[p] == lcs[k]) {
            nextNew = p;
            break;
          }
        }

        // Removed lines
        while (i < nextOld && i < oldLines.length) {
          result.add(
            DiffLine(
              type: DiffLineType.removed,
              content: oldLines[i],
              oldLineNumber: oldNum++,
            ),
          );
          i++;
        }

        // Added lines
        while (j < nextNew && j < newLines.length) {
          result.add(
            DiffLine(
              type: DiffLineType.added,
              content: newLines[j],
              newLineNumber: newNum++,
            ),
          );
          j++;
        }

        // Common line
        if (i < oldLines.length && j < newLines.length) {
          result.add(
            DiffLine(
              type: DiffLineType.context,
              content: oldLines[i],
              oldLineNumber: oldNum++,
              newLineNumber: newNum++,
            ),
          );
          i++;
          j++;
          k++;
        }
      } else {
        // Remaining lines
        while (i < oldLines.length) {
          result.add(
            DiffLine(
              type: DiffLineType.removed,
              content: oldLines[i],
              oldLineNumber: oldNum++,
            ),
          );
          i++;
        }
        while (j < newLines.length) {
          result.add(
            DiffLine(
              type: DiffLineType.added,
              content: newLines[j],
              newLineNumber: newNum++,
            ),
          );
          j++;
        }
      }
    }

    return _collapseContext(result);
  }

  static List<DiffLine> _collapseContext(
    List<DiffLine> lines, {
    int context = 3,
  }) {
    if (lines.isEmpty) return lines;

    final changed = <int>{};
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].type != DiffLineType.context) {
        for (var j = i - context; j <= i + context; j++) {
          if (j >= 0 && j < lines.length) changed.add(j);
        }
      }
    }

    if (changed.isEmpty) return lines;

    final result = <DiffLine>[];
    var lastSkipped = false;
    for (var i = 0; i < lines.length; i++) {
      if (changed.contains(i)) {
        lastSkipped = false;
        result.add(lines[i]);
      } else if (!lastSkipped) {
        lastSkipped = true;
        result.add(const DiffLine(type: DiffLineType.context, content: '...'));
      }
    }
    return result;
  }
}
