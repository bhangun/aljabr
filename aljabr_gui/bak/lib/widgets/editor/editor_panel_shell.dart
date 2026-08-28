import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diff_providers.dart';
import '../../providers/editor_providers.dart';
import '../../providers/explorer_providers.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_colors.dart';
import 'code_editor_panel.dart';
import 'diff/diff_panel.dart';
import 'explorer/file_explorer_panel.dart';
import 'terminal_panel.dart';

/// Wraps the right-hand column with a top tab strip (Code / Diff / Terminal)
/// — the same three views Codex/Antigravity-style tools surface for a
/// session — plus a togglable file explorer down the left of that content.
class EditorPanelShell extends ConsumerWidget {
  const EditorPanelShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(editorPanelTabProvider);
    final sessionId = ref.watch(activeSessionIdProvider);
    final diffCount = ref.watch(fileDiffsProvider(sessionId)).length;
    final explorerVisible = ref.watch(explorerVisibleProvider);

    return Container(
      color: AppTheme.panel,
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(explorerVisibleProvider.notifier).toggle(),
                  icon: Icon(
                    Icons.view_sidebar_outlined,
                    size: 17,
                    color: explorerVisible
                        ? AppTheme.accentBlue
                        : AppTheme.textSecondary,
                  ),
                  tooltip: explorerVisible ? 'Hide explorer' : 'Show explorer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 4),
                Container(width: 1, height: 18, color: AppTheme.border),
                const SizedBox(width: 6),
                _PanelTabButton(
                  label: 'Code',
                  icon: Icons.code,
                  selected: activeTab == EditorPanelTab.code,
                  onTap: () => ref
                      .read(editorPanelTabProvider.notifier)
                      .select(EditorPanelTab.code),
                ),
                _PanelTabButton(
                  label: 'Diff',
                  icon: Icons.difference_outlined,
                  selected: activeTab == EditorPanelTab.diff,
                  badgeCount: diffCount,
                  onTap: () => ref
                      .read(editorPanelTabProvider.notifier)
                      .select(EditorPanelTab.diff),
                ),
                _PanelTabButton(
                  label: 'Terminal',
                  icon: Icons.terminal,
                  selected: activeTab == EditorPanelTab.terminal,
                  onTap: () => ref
                      .read(editorPanelTabProvider.notifier)
                      .select(EditorPanelTab.terminal),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (explorerVisible) ...[
                  const FileExplorerPanel(),
                  const VerticalDivider(width: 1),
                ],
                Expanded(
                  child: IndexedStack(
                    index: activeTab.index,
                    children: const [
                      CodeEditorPanel(),
                      DiffPanel(),
                      TerminalPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _PanelTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.sidebarSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: AppTheme.accentBlue,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
