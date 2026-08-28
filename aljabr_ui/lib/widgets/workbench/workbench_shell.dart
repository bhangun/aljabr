import 'package:flutter/material.dart';
import 'slots/activity_bar_slot.dart';
import 'slots/side_pane_slot.dart';
import 'slots/main_pane_slot.dart';
import 'slots/bottom_pane_slot.dart';
import 'slots/secondary_pane_slot.dart';

class WorkbenchShell extends StatelessWidget {
  const WorkbenchShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ActivityBarSlot(),
        SidePaneSlot(),
        Expanded(
          child: Column(
            children: [
              MainPaneSlot(),
              BottomPaneSlot(),
            ],
          ),
        ),
        SecondaryPaneSlot(),
      ],
    );
  }
}
