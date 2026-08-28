import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../../../providers/module_manager_provider.dart';
import '../workbench_area.dart';
import 'workbench_splitter.dart';

class SecondaryPaneSlot extends ConsumerWidget {
  const SecondaryPaneSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(workbenchLayoutProvider);
    final controller = ref.watch(workbenchControllerProvider);
    final dims = layout.dimensions;

    if (!dims.isSecondaryVisible) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorkbenchSplitter(
          axis: SplitterAxis.horizontal,
          onDrag: (delta) {
            controller.resizeSecondary(dims.secondaryWidth - delta);
          },
          onDoubleClick: () {
            controller.toggleSecondary();
          },
        ),
        SizedBox(
          width: dims.secondaryWidth,
          child: const WorkbenchArea(
            area: ViewArea.secondaryPanel,
          ),
        ),
      ],
    );
  }
}
