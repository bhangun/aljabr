import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../providers/module_manager_provider.dart';
import 'contributed_view_host.dart';

class WorkbenchArea extends ConsumerWidget {
  final ViewArea area;
  final Widget? fallback;

  const WorkbenchArea({
    super.key,
    required this.area,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workbenchLayoutProvider);
    final activeViewId = state.activeViewIn(area);

    if (activeViewId == null) {
      // If not yet populated in layout state, check views registered for this area
      final views = ref.watch(viewRegistryProvider).forArea(area);
      if (views.isNotEmpty) {
        return ContributedViewHost(viewId: views.first.id);
      }
      return fallback ?? const SizedBox.shrink();
    }

    return ContributedViewHost(viewId: activeViewId);
  }
}
