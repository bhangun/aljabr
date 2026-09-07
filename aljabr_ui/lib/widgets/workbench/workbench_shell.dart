import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'docking/dock_overlay.dart';
import 'slots/activity_bar_slot.dart';
import 'slots/bottom_pane_slot.dart';
import 'slots/main_pane_slot.dart';
import 'slots/secondary_pane_slot.dart';
import 'slots/side_pane_slot.dart';

/// Composable Workbench Shell layout composed of stateful slots:
/// [ ActivityBarSlot ] | [ SidePaneSlot ] | [ MainPaneSlot / BottomPaneSlot ] | [ SecondaryPaneSlot ]
class WorkbenchShell extends ConsumerWidget {
  const WorkbenchShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DockOverlay(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActivityBarSlot(),
          SidePaneSlot(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MainPaneSlot(),
                BottomPaneSlot(),
              ],
            ),
          ),
          SecondaryPaneSlot(),
        ],
      ),
    );
  }
}
