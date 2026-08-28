import '../extensions/contribution_registry.dart';
import 'navigation_contribution.dart';
import 'navigation_group.dart';

class NavigationRegistry extends ContributionRegistry<NavigationContribution> {
  final Map<String, NavigationGroup> _groups = {};

  void registerGroup(NavigationGroup group) {
    _groups.putIfAbsent(group.id, () => group);
  }

  NavigationGroup? getGroup(String groupId) => _groups[groupId];

  List<NavigationGroup> get groups {
    final result = _groups.values.toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  @override
  void register(NavigationContribution item) {
    if (!_groups.containsKey(item.groupId)) {
      registerGroup(NavigationGroup(id: item.groupId, title: item.groupId.toUpperCase()));
    }
    super.register(item);
  }

  List<NavigationContribution> itemsForGroup(String groupId) {
    final items = getAll().where((item) => item.groupId == groupId).toList();
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }
}
