import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr_plugin_editor/aljabr_plugin_editor.dart';
import 'package:aljabr_plugin_terminal/aljabr_plugin_terminal.dart';
import '../../../providers/module_manager_provider.dart';
import '../../../theme/app_colors.dart';

enum VsCodeBottomTab {
  terminal,
  output,
  problems,
  debugConsole,
}

class VsCodeBottomTabNotifier extends Notifier<VsCodeBottomTab> {
  @override
  VsCodeBottomTab build() => VsCodeBottomTab.terminal;

  void select(VsCodeBottomTab tab) => state = tab;
}

final vsCodeBottomTabProvider =
    NotifierProvider<VsCodeBottomTabNotifier, VsCodeBottomTab>(
  () => VsCodeBottomTabNotifier(),
);

class VsCodeBottomPanelView extends ConsumerWidget {
  const VsCodeBottomPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(vsCodeBottomTabProvider);
    final problems = ref.watch(problemsProvider);
    final errorCount = problems.where((p) => p.severity == ProblemSeverity.error).length;
    final warningCount = problems.where((p) => p.severity == ProblemSeverity.warning).length;
    final workbench = ref.watch(workbenchControllerProvider);

    return Container(
      height: 220,
      color: AppTheme.panel,
      child: Column(
        children: [
          // Bottom Panel Header Bar
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(color: AppTheme.border, width: 1),
                bottom: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                _PanelTab(
                  label: 'PROBLEMS',
                  badge: '${errorCount + warningCount}',
                  badgeColor: errorCount > 0 ? const Color(0xFFFF453A) : const Color(0xFFFF9F0A),
                  isSelected: activeTab == VsCodeBottomTab.problems,
                  onTap: () => ref.read(vsCodeBottomTabProvider.notifier).select(VsCodeBottomTab.problems),
                ),
                _PanelTab(
                  label: 'OUTPUT',
                  isSelected: activeTab == VsCodeBottomTab.output,
                  onTap: () => ref.read(vsCodeBottomTabProvider.notifier).select(VsCodeBottomTab.output),
                ),
                _PanelTab(
                  label: 'DEBUG CONSOLE',
                  isSelected: activeTab == VsCodeBottomTab.debugConsole,
                  onTap: () => ref.read(vsCodeBottomTabProvider.notifier).select(VsCodeBottomTab.debugConsole),
                ),
                _PanelTab(
                  label: 'TERMINAL',
                  isSelected: activeTab == VsCodeBottomTab.terminal,
                  onTap: () => ref.read(vsCodeBottomTabProvider.notifier).select(VsCodeBottomTab.terminal),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'New Terminal (+)',
                  icon: const Icon(Icons.add, size: 15, color: AppTheme.textSecondary),
                  splashRadius: 14,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: 'Split Terminal',
                  icon: const Icon(Icons.vertical_split_outlined, size: 14, color: AppTheme.textSecondary),
                  splashRadius: 14,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: 'Close Panel (⌘J)',
                  icon: const Icon(Icons.close, size: 15, color: AppTheme.textSecondary),
                  splashRadius: 14,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => workbench.hidePane(PaneId.bottom),
                ),
              ],
            ),
          ),

          // Bottom Panel Content
          Expanded(
            child: switch (activeTab) {
              VsCodeBottomTab.terminal => const TerminalPanel(),
              VsCodeBottomTab.problems => const ProblemsPanel(),
              VsCodeBottomTab.output => _buildOutputLogView(),
              VsCodeBottomTab.debugConsole => _buildDebugConsoleView(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutputLogView() {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.all(10),
      child: const SingleChildScrollView(
        child: Text(
          '[Extension Host] Aljabr Language Server activated.\n'
          '[Compiler] Running build runner...\n'
          '[Build] [INFO] Generating objectbox.g.dart completed successfully (324ms)\n'
          '[Quality Gate] Sonar static analysis completed: 0 bugs, 0 vulnerabilities.\n',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.4,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDebugConsoleView() {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.all(10),
      child: const Center(
        child: Text(
          'Debug session idle. Start debugging with (F5).',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

class _PanelTab extends StatelessWidget {
  final String label;
  final String? badge;
  final Color? badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PanelTab({
    required this.label,
    this.badge,
    this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.accentBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
            if (badge != null && badge != '0') ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
