import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart' hide SyntaxHighlighter;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../theme/app_colors.dart';
import 'code_element_builder.dart';

/// Full-featured markdown renderer for incoming agent messages.
/// Supports: tables, bullet/numbered lists, fenced code blocks with syntax
/// highlighting, diff blocks, LaTeX ($$...$$), mermaid diagram stubs, and
/// inline formatting (**bold**, `code`, _italic_).
class MarkdownText extends StatelessWidget {
  final String text;
  const MarkdownText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Pre-process text: wrap $$...$$ display math as custom fenced blocks
    final processed = _preprocessLatex(text);

    return MarkdownBody(
      data: processed,
      selectable: true,
      extensionSet: md.ExtensionSet(
        [...md.ExtensionSet.gitHubFlavored.blockSyntaxes],
        [...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
      ),
      styleSheet: _buildStyleSheet(),
      builders: {
        'code': CodeElementBuilder(),
        'math-display': _DisplayMathBuilder(),
        'math-inline': _InlineMathBuilder(),
      },
      inlineSyntaxes: [_InlineMathSyntax()],
      blockSyntaxes: [_DisplayMathSyntax()],
      onTapLink: (text, href, title) {
        // URL opening handled externally if needed
      },
    );
  }

  /// Wraps $$...$$ blocks into a custom ```math-display fence so the
  /// markdown parser can delegate it to [_DisplayMathBuilder].
  String _preprocessLatex(String input) {
    return input.replaceAllMapped(
      RegExp(r'\$\$(.+?)\$\$', dotAll: true),
      (m) => '\n```math-display\n${m.group(1)!.trim()}\n```\n',
    );
  }

  MarkdownStyleSheet _buildStyleSheet() {
    const base = TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 14.5,
      height: 1.6,
    );
    const mono = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      color: AppTheme.codeValue,
      backgroundColor: AppTheme.chip,
    );

    return MarkdownStyleSheet(
      p: base,
      strong: base.copyWith(fontWeight: FontWeight.w700),
      em: base.copyWith(fontStyle: FontStyle.italic),
      code: mono,
      h1: base.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      h2: base.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      h3: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      h4: base.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      blockquotePadding: const EdgeInsets.only(left: 12),
      blockquoteDecoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppTheme.border, width: 3),
        ),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      tableBorder: TableBorder.all(color: AppTheme.border),
      tableHead: base.copyWith(fontWeight: FontWeight.w600),
      tableBody: base,
      codeblockDecoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      codeblockPadding: const EdgeInsets.all(12),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Inline Math: $...$
// ──────────────────────────────────────────────────────────────────────────────
class _InlineMathSyntax extends md.InlineSyntax {
  _InlineMathSyntax() : super(r'\$([^\$\n]+?)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final el = md.Element.text('math-inline', match.group(1)!);
    parser.addNode(el);
    return true;
  }
}

class _InlineMathBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Math.tex(
      element.textContent,
      textStyle: preferredStyle ??
          const TextStyle(color: AppTheme.textPrimary, fontSize: 14.5),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Display Math: ```math-display ... ```
// ──────────────────────────────────────────────────────────────────────────────
class _DisplayMathSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^```math-display$');

  @override
  md.Node? parse(md.BlockParser parser) {
    parser.advance(); // consume opening fence
    final lines = <String>[];
    while (!parser.isDone && !parser.current.content.startsWith('```')) {
      lines.add(parser.current.content);
      parser.advance();
    }
    if (!parser.isDone) parser.advance(); // consume closing fence

    final el = md.Element('math-display', null);
    el.attributes['tex'] = lines.join('\n').trim();
    return el;
  }
}

class _DisplayMathBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final tex = element.attributes['tex'] ?? element.textContent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Math.tex(
          tex,
          mathStyle: MathStyle.display,
          textStyle: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
      ),
    );
  }
}
