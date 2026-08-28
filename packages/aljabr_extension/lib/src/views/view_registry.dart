import 'view_contribution.dart';

class ViewRegistry {
  final Map<String, ViewContribution> _views = {};
  final Map<String, String> _owners = {};

  void register(ViewContribution view, {required String ownerId}) {
    if (_views.containsKey(view.id)) {
      throw StateError('View already registered: ${view.id}');
    }
    _views[view.id] = view;
    _owners[view.id] = ownerId;
  }

  void unregisterAllForOwner(String ownerId) {
    final ids = _owners.entries
        .where((entry) => entry.value == ownerId)
        .map((entry) => entry.key)
        .toList();

    for (final id in ids) {
      _views.remove(id);
      _owners.remove(id);
    }
  }

  List<ViewContribution> get all => _views.values.toList();
  
  ViewContribution? get(String id) => _views[id];
}
