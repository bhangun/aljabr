import '../extensions/contribution.dart';

class ServiceRegistry implements OwnerCleanup {
  final Map<Type, Object> _services = {};
  final Map<Type, String> _serviceOwners = {};

  void register<T>(T service, {String? ownerId}) {
    _services[T] = service as Object;
    if (ownerId != null) {
      _serviceOwners[T] = ownerId;
    }
  }

  T? get<T>() {
    final s = _services[T];
    if (s is T) return s;
    return null;
  }

  T require<T>() {
    final s = get<T>();
    if (s == null) {
      throw StateError('Required service not registered: $T');
    }
    return s;
  }

  bool has<T>() => _services.containsKey(T);

  void unregister<T>() {
    _services.remove(T);
    _serviceOwners.remove(T);
  }

  @override
  void unregisterAllForOwner(String ownerId) {
    final typesToRemove = _serviceOwners.entries
        .where((entry) => entry.value == ownerId)
        .map((entry) => entry.key)
        .toList();

    for (final type in typesToRemove) {
      _services.remove(type);
      _serviceOwners.remove(type);
    }
  }
}
