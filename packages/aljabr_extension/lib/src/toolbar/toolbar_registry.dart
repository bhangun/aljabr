import '../extensions/contribution_registry.dart';
import 'toolbar_alignment.dart';
import 'toolbar_context.dart';
import 'toolbar_contribution.dart';

class ToolbarRegistry extends ContributionRegistry<ToolbarContribution> {
  List<ToolbarContribution> resolve(
    ToolbarContext context,
    ToolbarAlignment alignment,
  ) {
    final items = getAll()
        .where((item) => item.targetId == context.targetId)
        .where((item) => item.alignment == alignment)
        .where((item) => item.isVisible?.call(context) ?? true)
        .toList();

    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  List<ToolbarContribution> forTargetAndAlignment({
    required String targetId,
    required ToolbarAlignment alignment,
  }) {
    return resolve(ToolbarContext(targetId: targetId), alignment);
  }
}
