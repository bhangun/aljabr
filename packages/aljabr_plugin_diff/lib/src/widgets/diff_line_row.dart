import 'package:flutter/material.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// One unified-view row: gutter with old/new line numbers, a +/-/space
/// marker, and the syntax-highlighted line content.
class DiffLineRow extends StatelessWidget {
  final DiffLine line;
  final String language;
  const DiffLineRow({super.key, required this.line, this.language = 'text'});

  @override
  Widget build(BuildContext context) {
    final bg = switch (line.type) {
      DiffLineType.addition => AppTheme.accentGreen.withValues(alpha: 0.10),
      DiffLineType.deletion => const Color(0xFFE0554C).withValues(alpha: 0.10),
      _ => Colors.transparent,
    };
    final marker = switch (line.type) {
      DiffLineType.addition => '+',
      DiffLineType.deletion => '-',
      _ => ' ',
    };
    final markerColor = switch (line.type) {
      DiffLineType.addition => AppTheme.accentGreen,
      DiffLineType.deletion => const Color(0xFFE0554C),
      _ => AppTheme.textMuted,
    };
    final baseStyle = TextStyle(
      color: line.type == DiffLineType.deletion
          ? AppTheme.textPrimary.withValues(alpha: 0.75)
          : AppTheme.textPrimary,
      fontFamily: 'monospace',
      fontSize: 12.5,
    );

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              line.oldLineNo?.toString() ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppTheme.lineNumber,
                  fontSize: 11.5,
                  fontFamily: 'monospace'),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              line.newLineNo?.toString() ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppTheme.lineNumber,
                  fontSize: 11.5,
                  fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 12,
            child: Text(marker,
                style: TextStyle(
                    color: markerColor,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: line.content.isEmpty
                ? Text(' ', style: baseStyle)
                : Text.rich(TextSpan(
                    children: SyntaxHighlighter.highlightLine(
                        line.content, language, baseStyle))),
          ),
        ],
      ),
    );
  }
}
