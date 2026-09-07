import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'package:aljabr_plugin_diff/aljabr_plugin_diff.dart';
import 'package:aljabr_plugin_terminal/aljabr_plugin_terminal.dart';
import '../models/problem_item.dart';
import '../providers/editor_panel_provider.dart';
import '../providers/explorer_visible_providers.dart';
import '../providers/problem_provider.dart';
import 'code_editor_panel.dart';
import 'file_explorer_panel.dart';
import 'problems_panel.dart';

/// Wraps the right-hand column with a top tab strip (Code / Diff / Terminal / Problems)
/// combining Codex, Antigravity, and Claude Code strengths:
/// - Code editing & Diff inspection
/// - Interactive Terminal & process output
/// - Deterministic Sonar / Compiler Diagnostics & Verification Quality Gate
class EditorPanelShell extends ConsumerWidget {
  const EditorPanelShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(editorPanelTabProvider);
    final sessionId = ref.watch(activeSessionIdProvider);
    final diffCount = ref.watch(fileDiffsProvider(sessionId)).length;
    final problems = ref.watch(problemsProvider);
    final problemCount = problems.length;
    final explorerVisible = ref.watch(explorerVisibleProvider);

    return Container(
      color: AppTheme.panel,
      child: Column(
        children: [
          // Top View Switcher & Toolchain Status Bar
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6),
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
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
                const SizedBox(width: 2),
                Container(width: 1, height: 16, color: AppTheme.border),
                const SizedBox(width: 4),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        _PanelTabButton(
                          label: 'Problems',
                          icon: Icons.bug_report_outlined,
                          selected: activeTab == EditorPanelTab.problems,
                          badgeCount: problemCount > 0 ? problemCount : null,
                          badgeColor: problems.any(
                                  (p) => p.severity == ProblemSeverity.error)
                              ? const Color(0xFFFF453A)
                              : const Color(0xFFFF9F0A),
                          onTap: () => ref
                              .read(editorPanelTabProvider.notifier)
                              .select(EditorPanelTab.problems),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Workspace Toolchain & Status Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppTheme.panelAlt,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 11, color: Color(0xFF34C759)),
                      SizedBox(width: 4),
                      Text(
                        'Sonar / Verified',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
                      ProblemsPanel(),
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
  final Color? badgeColor;
  final VoidCallback onTap;

  const _PanelTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.badgeColor,
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
            Icon(icon,
                size: 15,
                color:
                    selected ? AppTheme.textPrimary : AppTheme.textSecondary),
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
                  color: badgeColor ?? AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
