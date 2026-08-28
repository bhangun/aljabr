import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../../../providers/module_manager_provider.dart';
import '../workbench_area.dart';
import '../../sidebar/sidebar_widget.dart';
import 'workbench_splitter.dart';

class SidePaneSlot extends ConsumerWidget {
  const SidePaneSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(workbenchLayoutProvider);
    final controller = ref.watch(workbenchControllerProvider);
    final dims = layout.dimensions;

    if (!dims.isSidebarVisible) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: dims.sidebarWidth,
          child: const WorkbenchArea(
            area: ViewArea.sidebar,
            fallback: SidebarWidget(),
          ),
        ),
        WorkbenchSplitter(
          axis: SplitterAxis.horizontal,
          onDrag: (delta) {
            controller.resizeSidebar(dims.sidebarWidth + delta);
          },
          onDoubleClick: () {
            controller.toggleSidebar();
          },
        ),
      ],
    );
  }
}
