import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/syntax_highlighter.dart';

/// One gutter-numbered, syntax-highlighted line in the code editor. Pure
/// presentational widget — highlighting is derived from [language] via
/// [SyntaxHighlighter], so it works for any file type in the explorer.
class CodeLine extends StatelessWidget {
  final int lineNumber;
  final String content;
  final String language;
  final bool highlighted;

  const CodeLine({
    super.key,
    required this.lineNumber,
    required this.content,
    required this.language,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    const monoStyle = TextStyle(
      color: AppTheme.textSecondary,
      fontFamily: 'monospace',
      fontSize: 12.8,
      height: 1.5,
    );

    return Container(
      color: highlighted ? AppTheme.accentBlue.withValues(alpha: 0.12) : null,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '$lineNumber',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.lineNumber,
                fontSize: 12.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: content.isEmpty
                ? const Text(' ', style: monoStyle)
                : Text.rich(
                    TextSpan(
                        children: SyntaxHighlighter.highlightLine(
                            content, language, monoStyle)),
                  ),
          ),
        ],
      ),
    );
  }
}
