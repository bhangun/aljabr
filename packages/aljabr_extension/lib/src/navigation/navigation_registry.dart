import 'navigation_contribution.dart';
import 'navigation_group.dart';

class NavigationRegistry {
  final Map<String, NavigationGroup> _groups = {};
  final Map<String, NavigationContribution> _items = {};
  final Map<String, String> _owners = {};

  void registerGroup(NavigationGroup group) {
    _groups[group.id] = group;
  }

  void register(NavigationContribution item, {required String ownerId}) {
    if (_items.containsKey(item.id)) {
      throw StateError('Navigation contribution already registered: ${item.id}');
    }
    _items[item.id] = item;
    _owners[item.id] = ownerId;
  }

  void unregisterAllForOwner(String ownerId) {
    final ids = _owners.entries
        .where((entry) => entry.value == ownerId)
        .map((entry) => entry.key)
        .toList();

    for (final id in ids) {
      _items.remove(id);
      _owners.remove(id);
    }
  }

  List<NavigationGroup> get groups {
    final list = _groups.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<NavigationContribution> itemsForGroup(String groupId) {
    final list = _items.values.where((item) => item.groupId == groupId).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
