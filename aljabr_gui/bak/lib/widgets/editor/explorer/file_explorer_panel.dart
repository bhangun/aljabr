import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/file_node.dart';
import '../../../providers/editor_providers.dart';
import '../../../providers/explorer_providers.dart';
import '../../../theme/app_colors.dart';

/// Narrow "Explorer" column: a real, browsable file tree (not just
/// whatever tabs happen to be open). Clicking a file opens it as a tab
/// and switches the right panel to the Code view.
class FileExplorerPanel extends ConsumerWidget {
  const FileExplorerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final root = ref.watch(fileTreeProvider);

    return Container(
      width: 220,
      color: AppTheme.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: const Text(
              'EXPLORER',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: [
                for (final child in root.children)
                  _TreeEntry(node: child, depth: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeEntry extends ConsumerWidget {
  final FileNode node;
  final int depth;
  const _TreeEntry({required this.node, required this.depth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (node.isDirectory) {
      final expanded = ref.watch(expandedFoldersProvider).contains(node.path);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                ref.read(expandedFoldersProvider.notifier).toggle(node.path),
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0 + depth * 14,
                right: 8,
                top: 4,
                bottom: 4,
              ),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    expanded ? Icons.folder_open : Icons.folder,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    node.name,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            for (final child in node.children)
              _TreeEntry(node: child, depth: depth + 1),
        ],
      );
    }

    final activePath = ref.watch(activeFileProvider);
    final isActive = activePath == node.path;

    return InkWell(
      onTap: () {
        ref.read(openFilesProvider.notifier).open(node.path);
        ref.read(activeFileProvider.notifier).select(node.path);
        ref.read(editorPanelTabProvider.notifier).select(EditorPanelTab.code);
      },
      child: Container(
        color: isActive ? AppTheme.sidebarSelected : Colors.transparent,
        padding: EdgeInsets.only(
          left: 8.0 + depth * 14 + 20,
          right: 8,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          children: [
            Icon(_iconFor(node.name), size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                node.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            if (node.hasChanges)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.accentAmber,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    if (name.endsWith('.properties')) return Icons.settings_outlined;
    if (name.endsWith('.yml') || name.endsWith('.yaml'))
      return Icons.data_object;
    if (name.endsWith('.sql')) return Icons.storage_outlined;
    if (name.endsWith('.java')) return Icons.code;
    if (name.endsWith('.md')) return Icons.article_outlined;
    if (name.endsWith('.xml')) return Icons.integration_instructions_outlined;
    return Icons.description_outlined;
  }
}
