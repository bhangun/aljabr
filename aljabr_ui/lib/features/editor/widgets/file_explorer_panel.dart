import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/file_node.dart';
import '../providers/active_file_provider.dart';
import '../providers/editor_panel_provider.dart';
import '../providers/expandable_folder_provider.dart';
import '../providers/file_tree_provider.dart';
import '../providers/open_file_provider.dart';
import '../../project/providers/active_project_provider.dart';
import '../../../theme/app_colors.dart';
import '../../mutations/widgets/mutation_panel.dart';

/// Helper class to pass node + depth in a flat list.
class _TreeEntryData {
  final FileNode node;
  final int depth;
  const _TreeEntryData(this.node, this.depth);
}

/// Flattens the tree respecting expanded/collapsed state.
List<_TreeEntryData> _flattenTree(FileNode root, Set<String> expandedPaths) {
  final result = <_TreeEntryData>[];
  void traverse(FileNode node, int depth) {
    for (final child in node.children) {
      result.add(_TreeEntryData(child, depth));
      if (child.isDirectory && expandedPaths.contains(child.path)) {
        traverse(child, depth + 1);
      }
    }
  }

  traverse(root, 0);
  return result;
}

/// Real browsable file tree for the active project.
class FileExplorerPanel extends ConsumerWidget {
  const FileExplorerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProject = ref.watch(activeProjectProvider);
    final rootAsync = ref.watch(fileTreeProvider);
    final expanded = ref.watch(expandedFoldersProvider);

    return Container(
      width: 230,
      color: AppTheme.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (unchanged)
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    activeProject != null
                        ? activeProject.name.toUpperCase()
                        : 'EXPLORER',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh Workspace Files',
                  icon: const Icon(Icons.refresh_rounded,
                      size: 15, color: AppTheme.textSecondary),
                  onPressed: () => ref.invalidate(fileTreeProvider),
                ),
                IconButton(
                  tooltip: 'Show mutations',
                  icon: const Icon(Icons.bug_report_outlined,
                      size: 15, color: AppTheme.textSecondary),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => const FractionallySizedBox(
                        heightFactor: 0.8,
                        child: MutationPanel(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tree content – handles loading, error, data
          Expanded(
            child: rootAsync.when(
              data: (root) {
                final entries = _flattenTree(root, expanded);
                if (entries.isEmpty) {
                  return _buildEmptyState(activeProject);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _TreeEntry(
                      node: entry.node,
                      depth: entry.depth,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Error loading files: $err',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(activeProject) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 32, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              activeProject == null ? 'No project selected' : 'Empty workspace',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single node widget – no recursion. Relies on parent to show children.
class _TreeEntry extends ConsumerWidget {
  final FileNode node;
  final int depth;
  const _TreeEntry({required this.node, required this.depth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (node.isDirectory) {
      final expanded = ref.watch(expandedFoldersProvider).contains(node.path);
      return InkWell(
        onTap: () =>
            ref.read(expandedFoldersProvider.notifier).toggle(node.path),
        child: Padding(
          padding: EdgeInsets.only(
              left: 8.0 + depth * 14, right: 8, top: 4, bottom: 4),
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
              Expanded(
                child: Text(
                  node.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // File node
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
            left: 8.0 + depth * 14 + 20, right: 8, top: 4, bottom: 4),
        child: Row(
          children: [
            Icon(_iconFor(node.name), size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                node.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            // Dirty state – we can watch fileBufferProvider here, but for simplicity
            // we keep the hasChanges flag from the node (if set elsewhere).
            if (node.hasChanges)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 4),
                decoration: const BoxDecoration(
                    color: AppTheme.accentAmber, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    if (name.endsWith('.dart')) return Icons.flutter_dash;
    if (name.endsWith('.properties') || name.endsWith('.env')) {
      return Icons.settings_outlined;
    }
    if (name.endsWith('.yml') || name.endsWith('.yaml')) {
      return Icons.data_object;
    }
    if (name.endsWith('.json')) return Icons.data_array;
    if (name.endsWith('.sql')) return Icons.storage_outlined;
    if (name.endsWith('.java') ||
        name.endsWith('.kt') ||
        name.endsWith('.go') ||
        name.endsWith('.rs') ||
        name.endsWith('.ts') ||
        name.endsWith('.js') ||
        name.endsWith('.py')) {
      return Icons.code;
    }
    if (name.endsWith('.md')) return Icons.article_outlined;
    if (name.endsWith('.xml') || name.endsWith('.html')) {
      return Icons.integration_instructions_outlined;
    }
    return Icons.description_outlined;
  }
}
