import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../../../providers/module_manager_provider.dart';
import 'generic_workbench_layout_view.dart';
import 'vibe_coding_workspace_view.dart';

/// Dynamic host that renders the active workspace mode layout.
/// Checks the mode's [viewBuilder] first for custom domain layouts (workflows, mindmaps, canvases),
/// then falls back to built-in modes or the neutral multi-pane workbench layout.
class WorkspaceViewHost extends ConsumerWidget {
  const WorkspaceViewHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMode = ref.watch(activeWorkspaceModeProvider);

    // 1. Dynamic Mode View Builder (contributed by a domain plugin pack or platform config)
    if (activeMode.viewBuilder != null) {
      return activeMode.viewBuilder!(context);
    }

    // 2. Built-in legacy mode fallback
    if (activeMode.id == CoreWorkspaceModes.vibe) {
      return const VibeCodingWorkspaceView();
    }

    // 3. Neutral multi-pane dockable workbench layout
    return const GenericWorkbenchLayoutView();
  }
}
