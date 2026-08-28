import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/language.dart';
import 'code_line.dart';
import 'file_tabs_bar.dart';

/// Source view: file tabs bar + a scrollable, line-numbered, syntax
/// highlighted view of whichever file is active.
class CodeEditorPanel extends ConsumerWidget {
  const CodeEditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePath = ref.watch(activeFileProvider);
    final lines = sampleFileContents[activePath] ?? const [];
    final language = languageForPath(activePath);
    final changedLines = highlightedLineIndexes[activePath] ?? const <int>{};

    return Container(
      color: AppTheme.panel,
      child: Column(
        children: [
          const FileTabsBar(),
          const Divider(height: 1),
          Expanded(
            child: lines.isEmpty
                ? const Center(
                    child: Text(
                      'No preview available',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: lines.length,
                    itemBuilder: (context, i) => CodeLine(
                      lineNumber: i + 1,
                      content: lines[i],
                      language: language,
                      highlighted: changedLines.contains(i),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
