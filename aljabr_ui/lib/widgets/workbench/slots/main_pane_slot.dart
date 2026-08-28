import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../workbench_area.dart';
import '../../extension_region_host.dart';

class MainPaneSlot extends ConsumerWidget {
  const MainPaneSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Expanded(
      child: WorkbenchArea(
        area: ViewArea.main,
        fallback: ExtensionRegionHost(
          region: UiRegion.mainWorkbench,
        ),
      ),
    );
  }
}
