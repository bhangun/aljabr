import 'package:flutter/material.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// One side-by-side row: deletions render only on the left half, additions
/// only on the right half, context lines render identically on both —
/// a simplified GitHub-style split view, syntax-highlighted per [language].
class SplitDiffRow extends StatelessWidget {
  final DiffLine line;
  final String language;
  const SplitDiffRow({super.key, required this.line, this.language = 'text'});

  @override
  Widget build(BuildContext context) {
    final isAddition = line.type == DiffLineType.addition;
    final isDeletion = line.type == DiffLineType.deletion;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _Half(
              lineNo: line.oldLineNo,
              content: isAddition ? null : line.content,
              language: language,
              marker: isDeletion ? '-' : null,
              bg: isDeletion
                  ? const Color(0xFFE0554C).withValues(alpha: 0.10)
                  : null,
              markerColor: const Color(0xFFE0554C),
            ),
          ),
          const VerticalDivider(width: 1, color: AppTheme.border),
          Expanded(
            child: _Half(
              lineNo: line.newLineNo,
              content: isDeletion ? null : line.content,
              language: language,
              marker: isAddition ? '+' : null,
              bg: isAddition
                  ? AppTheme.accentGreen.withValues(alpha: 0.10)
                  : null,
              markerColor: AppTheme.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _Half extends StatelessWidget {
  final int? lineNo;
  final String? content;
  final String language;
  final String? marker;
  final Color? bg;
  final Color markerColor;

  const _Half({
    required this.lineNo,
    required this.content,
    required this.language,
    required this.marker,
    required this.bg,
    required this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
        color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 12.5);

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              lineNo?.toString() ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppTheme.lineNumber,
                  fontSize: 11.5,
                  fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 12,
            child: Text(marker ?? '',
                style: TextStyle(
                    color: markerColor,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: content == null
                ? const SizedBox.shrink()
                : Text.rich(
                    TextSpan(
                        children: SyntaxHighlighter.highlightLine(
                            content!, language, baseStyle)),
                  ),
          ),
        ],
      ),
    );
  }
}
