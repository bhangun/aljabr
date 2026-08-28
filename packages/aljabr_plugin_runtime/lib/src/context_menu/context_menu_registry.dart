import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../extensions/contribution_registry.dart';

class ContextMenuRegistry extends ContributionRegistry<MenuContribution> {
  List<MenuContribution> resolve(MenuContext context) {
    final items = getAll()
        .where((item) => item.targetId == context.targetId)
        .where((item) => item.isVisible?.call(context) ?? true)
        .toList();

    items.sort(ContributionOrdering.compare);
    return items;
  }
}
