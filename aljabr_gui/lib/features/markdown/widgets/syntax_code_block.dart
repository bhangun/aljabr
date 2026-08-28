import 'package:aljabr/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/syntax_highlighter.dart';
import '../../composer/widgets/code_block_actions.dart';
import '../../editor/providers/active_file_provider.dart';

/// Standard syntax-highlighted fenced block.
class SyntaxCodeBlock extends ConsumerStatefulWidget {
  final String language;
  final String code;
  const SyntaxCodeBlock(
      {required this.language, required this.code, super.key});

  @override
  ConsumerState<SyntaxCodeBlock> createState() => SyntaxCodeBlockState();
}

class SyntaxCodeBlockState extends ConsumerState<SyntaxCodeBlock> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(activeFileProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Text(
                  widget.language.isEmpty ? 'text' : widget.language,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontFamily: 'monospace'),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Actions',
                      icon: const Icon(Icons.more_horiz, size: 16),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => CodeBlockActions(
                              code: widget.code,
                              targetPath: activeFile,
                              startLine: null,
                              endLine: null),
                        );
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.code));
                        setState(() => _copied = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _copied = false);
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copied ? Icons.check : Icons.copy_outlined,
                            size: 13,
                            color: _copied
                                ? AppTheme.accentGreen
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _copied ? 'Copied' : 'Copy',
                            style: TextStyle(
                                color: _copied
                                    ? AppTheme.accentGreen
                                    : AppTheme.textMuted,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: SelectableText.rich(
              TextSpan(
                children: SyntaxHighlighter.highlightBlock(
                  widget.code,
                  widget.language,
                  const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
