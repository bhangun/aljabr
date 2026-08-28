import 'settings_contribution.dart';

class SettingsRegistry {
  final Map<String, SettingsContribution> _settings = {};
  final Map<String, String> _owners = {};

  void register(SettingsContribution contribution, {required String ownerId}) {
    if (_settings.containsKey(contribution.id)) {
      throw StateError('Settings contribution already registered: ${contribution.id}');
    }
    _settings[contribution.id] = contribution;
    _owners[contribution.id] = ownerId;
  }

  void unregisterAllForOwner(String ownerId) {
    final ids = _owners.entries
        .where((entry) => entry.value == ownerId)
        .map((entry) => entry.key)
        .toList();

    for (final id in ids) {
      _settings.remove(id);
      _owners.remove(id);
    }
  }

  List<SettingsContribution> get all {
    final list = _settings.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  SettingsContribution? get(String id) => _settings[id];
}
