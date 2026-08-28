import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../extensions/contribution_registry.dart';

class NavigationRegistry extends ContributionRegistry<NavigationContribution> {
  final Map<String, NavigationGroup> _groups = {};

  void registerGroup(NavigationGroup group) {
    _groups[group.id] = group;
  }

  NavigationGroup? getGroup(String groupId) => _groups[groupId];

  List<NavigationGroup> get groups {
    final list = _groups.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<NavigationContribution> itemsForGroup(String groupId) {
    final items = getAll().where((item) => item.groupId == groupId).toList();
    items.sort(ContributionOrdering.compare);
    return items;
  }
}
