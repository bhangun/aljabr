// ──────────────────────────────────────────────────────────────────────────────
// Code block: syntax highlighting + diff coloring + copy button
// ──────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'diff_block.dart';
import 'mermaid_stub.dart';
import 'syntax_code_block.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Inline code — skip, handled by MarkdownStyleSheet.
    if (!element.attributes.containsKey('class') &&
        element.textContent.split('\n').length == 1) {
      return null;
    }

    final lang = (element.attributes['class'] ?? '')
        .replaceFirst('language-', '')
        .toLowerCase();
    final code = element.textContent.trimRight();
    final isDiff = lang == 'diff';
    final isMermaid = lang == 'mermaid';

    if (isMermaid) return MermaidStub(code: code);
    if (isDiff) return DiffBlock(code: code);
    return SyntaxCodeBlock(language: lang, code: code);
  }
}
