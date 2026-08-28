import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../../../providers/module_manager_provider.dart';
import '../workbench_area.dart';
import 'workbench_splitter.dart';

class BottomPaneSlot extends ConsumerWidget {
  const BottomPaneSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(workbenchLayoutProvider);
    final controller = ref.watch(workbenchControllerProvider);
    final dims = layout.dimensions;

    if (!dims.isBottomVisible) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorkbenchSplitter(
          axis: SplitterAxis.vertical,
          onDrag: (delta) {
            controller.resizeBottom(dims.bottomHeight - delta);
          },
          onDoubleClick: () {
            controller.toggleBottom();
          },
        ),
        SizedBox(
          height: dims.bottomHeight,
          width: double.infinity,
          child: const WorkbenchArea(
            area: ViewArea.bottomPanel,
          ),
        ),
      ],
    );
  }
}
