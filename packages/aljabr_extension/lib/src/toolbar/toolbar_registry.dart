import 'toolbar_contribution.dart';

class ToolbarRegistry {
  final Map<String, ToolbarContribution> _items = {};
  final Map<String, String> _owners = {};

  void register(ToolbarContribution item, {required String ownerId}) {
    if (_items.containsKey(item.id)) {
      throw StateError('Toolbar contribution already registered: ${item.id}');
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

  List<ToolbarContribution> get all {
    final list = _items.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  ToolbarContribution? get(String id) => _items[id];
}
