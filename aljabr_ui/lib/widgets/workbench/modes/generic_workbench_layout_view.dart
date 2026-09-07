import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../docking/dock_overlay.dart';
import '../slots/activity_bar_slot.dart';
import '../slots/resizable_pane.dart';
import '../views/vscode_sidebar_view.dart';
import '../views/vscode_editor_view.dart';
import '../views/vscode_bottom_panel_view.dart';
import 'package:aljabr_plugin_chat/aljabr_plugin_chat.dart';
import '../../../providers/module_manager_provider.dart';
import '../../../theme/app_colors.dart';

/// Neutral, multi-pane dockable Workbench layout.
/// Features an activity bar, resizable primary sidebar, main center view area,
/// bottom panel, and secondary utility drawer.
class GenericWorkbenchLayoutView extends ConsumerWidget {
  const GenericWorkbenchLayoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workbench = ref.watch(workbenchControllerProvider);
    final layout = ref.watch(workbenchLayoutProvider);

    final sidebarPane = layout.pane(PaneId.sidebar);
    final bottomPane = layout.pane(PaneId.bottom);
    final secondaryPane = layout.pane(PaneId.secondary);

    return DockOverlay(
      child: Container(
        color: AppTheme.background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Far Left Activity Bar
            const ActivityBarSlot(),

            // 2. Primary Dockable Sidebar (Explorer, Navigation, Domain Tools)
            if (sidebarPane.visible) ...[
              const ResizablePane(
                paneId: PaneId.sidebar,
                axis: Axis.horizontal,
                child: VsCodeSidebarView(),
              ),
              const VerticalDivider(width: 1, color: AppTheme.border),
            ],

            // 3. Main Center Area: Primary Views + Bottom Utility Panel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child: VsCodeEditorView(),
                  ),
                  if (bottomPane.visible) ...[
                    const Divider(height: 1, color: AppTheme.border),
                    const ResizablePane(
                      paneId: PaneId.bottom,
                      axis: Axis.vertical,
                      child: VsCodeBottomPanelView(),
                    ),
                  ],
                ],
              ),
            ),

            // 4. Secondary Utility Drawer
            if (secondaryPane.visible) ...[
              const VerticalDivider(width: 1, color: AppTheme.border),
              ResizablePane(
                paneId: PaneId.secondary,
                axis: Axis.horizontal,
                child: Container(
                  width: secondaryPane.size,
                  color: AppTheme.panel,
                  child: Column(
                    children: [
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: AppTheme.accent),
                            const SizedBox(width: 6),
                            const Text(
                              'ASSISTANT & INSPECTOR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Close Secondary Panel',
                              icon: const Icon(Icons.close, size: 14, color: AppTheme.textMuted),
                              splashRadius: 14,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: () => workbench.hidePane(PaneId.secondary),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const Expanded(
                        child: ChatPanel(slashCommands: []),
                      ),
                    ],
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
