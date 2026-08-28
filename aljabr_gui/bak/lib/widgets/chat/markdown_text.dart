import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../utils/syntax_highlighter.dart';

/// Renders a constrained subset of markdown for agent chat messages:
/// **bold**, `inline code`, "- " bullet lists, and fenced ```lang blocks```
/// (with a language label + copy button). Intentionally hand-rolled rather
/// than pulling in a markdown package, since the supported syntax is small
/// and fixed.
class AgentMarkdownText extends StatelessWidget {
  final String text;
  const AgentMarkdownText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final segments = _splitCodeFences(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final seg in segments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: seg.isCode
                ? _CodeBlock(language: seg.language, code: seg.content)
                : _RichBlock(text: seg.content),
          ),
      ],
    );
  }

  static List<_Segment> _splitCodeFences(String text) {
    final pattern = RegExp(r'```(\w*)\n([\s\S]*?)```', multiLine: true);
    final segments = <_Segment>[];
    int last = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > last) {
        segments.add(_Segment.text(text.substring(last, m.start).trim()));
      }
      segments.add(
        _Segment.code(m.group(1) ?? '', m.group(2)?.trimRight() ?? ''),
      );
      last = m.end;
    }
    if (last < text.length) {
      final rest = text.substring(last).trim();
      if (rest.isNotEmpty) segments.add(_Segment.text(rest));
    }
    return segments.where((s) => s.content.isNotEmpty).toList();
  }
}

class _Segment {
  final bool isCode;
  final String language;
  final String content;
  _Segment.text(this.content) : isCode = false, language = '';
  _Segment.code(this.language, this.content) : isCode = true;
}

/// Plain-text block: paragraph lines with inline formatting, and "- "
/// lines grouped into a bullet list.
class _RichBlock extends StatelessWidget {
  final String text;
  const _RichBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 14.5,
      height: 1.55,
    );
    final lines = text.split('\n');
    final widgets = <Widget>[];
    final paragraph = <String>[];

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      widgets.add(
        Text.rich(TextSpan(children: _inlineSpans(paragraph.join(' '), base))),
      );
      paragraph.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trimLeft().startsWith('- ')) {
        flushParagraph();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: base),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _inlineSpans(
                        line.trimLeft().substring(2),
                        base,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.isEmpty) {
        flushParagraph();
      } else {
        paragraph.add(line);
      }
    }
    flushParagraph();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  static List<InlineSpan> _inlineSpans(String text, TextStyle base) {
    final pattern = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
    final spans = <InlineSpan>[];
    int last = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > last)
        spans.add(TextSpan(text: text.substring(last, m.start), style: base));
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: base.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: base.copyWith(
              fontFamily: 'monospace',
              fontSize: 13,
              color: AppTheme.codeValue,
              backgroundColor: AppTheme.chip,
            ),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length)
      spans.add(TextSpan(text: text.substring(last), style: base));
    return spans;
  }
}

/// Fenced code block with a language label and a copy-to-clipboard button.
class _CodeBlock extends StatefulWidget {
  final String language;
  final String code;
  const _CodeBlock({required this.language, required this.code});

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _copy,
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
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
