import 'status_bar_contribution.dart';

class StatusBarRegistry {
  final Map<String, StatusBarContribution> _items = {};
  final Map<String, String> _owners = {};

  void register(StatusBarContribution item, {required String ownerId}) {
    if (_items.containsKey(item.id)) {
      throw StateError('StatusBar contribution already registered: ${item.id}');
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

  List<StatusBarContribution> get leftItems {
    final list = _items.values
        .where((item) => item.alignment == StatusBarAlignment.left)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<StatusBarContribution> get rightItems {
    final list = _items.values
        .where((item) => item.alignment == StatusBarAlignment.right)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  StatusBarContribution? get(String id) => _items[id];
}
