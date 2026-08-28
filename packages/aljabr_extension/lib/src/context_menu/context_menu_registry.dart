import '../extensions/contribution_registry.dart';
import 'context_menu_contribution.dart';
import 'menu_context.dart';

class ContextMenuRegistry extends ContributionRegistry<MenuContribution> {
  List<MenuContribution> resolve(MenuContext context) {
    final result = getAll()
        .where((item) => item.targetId == context.targetId)
        .where((item) => item.isVisible?.call(context) ?? true)
        .toList();

    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  List<MenuContribution> itemsForLocation(String location) {
    return resolve(MenuContext(targetId: location));
  }
}
