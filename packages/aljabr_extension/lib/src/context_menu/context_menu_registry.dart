import 'context_menu_contribution.dart';

class ContextMenuRegistry {
  final Map<String, ContextMenuContribution> _items = {};
  final Map<String, String> _owners = {};

  void register(ContextMenuContribution item, {required String ownerId}) {
    if (_items.containsKey(item.id)) {
      throw StateError('Context menu contribution already registered: ${item.id}');
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

  List<ContextMenuContribution> itemsForLocation(String location) {
    final list = _items.values.where((item) => item.location == location).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  ContextMenuContribution? get(String id) => _items[id];
}
