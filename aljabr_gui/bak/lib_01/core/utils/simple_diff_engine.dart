// lib/core/utils/simple_diff_engine.dart

import '../../features/chat/models/file_diff.dart';

/// Simple line-by-line diff engine using the Myers algorithm
class SimpleDiffEngine {
  /// Compute line-level diff between two strings
  static List<DiffLine> computeLineDiff(String original, String modified) {
    final oldLines = original.split('\n');
    final newLines = modified.split('\n');

    // If both are empty
    if (oldLines.isEmpty && newLines.isEmpty) return [];

    // If one is empty
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

    // Compute LCS (Longest Common Subsequence)
    final lcs = _computeLCS(oldLines, newLines);

    // Generate diff from LCS
    return _generateDiff(oldLines, newLines, lcs);
  }

  /// Compute Longest Common Subsequence
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

    // Backtrack to get LCS
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

  /// Generate diff from LCS
  static List<DiffLine> _generateDiff(
    List<String> oldLines,
    List<String> newLines,
    List<String> lcs,
  ) {
    final result = <DiffLine>[];
    var i = 0, j = 0, k = 0;
    var oldLineNum = 1, newLineNum = 1;

    while (i < oldLines.length || j < newLines.length) {
      if (k < lcs.length) {
        // Find next common line
        var nextOldIndex = -1;
        var nextNewIndex = -1;

        for (var p = i; p < oldLines.length; p++) {
          if (oldLines[p] == lcs[k]) {
            nextOldIndex = p;
            break;
          }
        }
        for (var p = j; p < newLines.length; p++) {
          if (newLines[p] == lcs[k]) {
            nextNewIndex = p;
            break;
          }
        }

        // Lines before the common line
        while (i < nextOldIndex) {
          result.add(
            DiffLine(
              type: DiffLineType.removed,
              content: oldLines[i],
              oldLineNumber: oldLineNum++,
            ),
          );
          i++;
        }
        while (j < nextNewIndex) {
          result.add(
            DiffLine(
              type: DiffLineType.added,
              content: newLines[j],
              newLineNumber: newLineNum++,
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
              oldLineNumber: oldLineNum++,
              newLineNumber: newLineNum++,
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
              oldLineNumber: oldLineNum++,
            ),
          );
          i++;
        }
        while (j < newLines.length) {
          result.add(
            DiffLine(
              type: DiffLineType.added,
              content: newLines[j],
              newLineNumber: newLineNum++,
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
