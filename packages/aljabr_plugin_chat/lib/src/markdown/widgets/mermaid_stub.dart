import 'package:flutter/material.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// Mermaid: shows the raw source with a note (rendering requires a WebView).
class MermaidStub extends StatelessWidget {
  final String code;
  const MermaidStub({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_tree_outlined,
                  size: 14, color: AppTheme.textMuted),
              SizedBox(width: 6),
              Text('Mermaid diagram',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
