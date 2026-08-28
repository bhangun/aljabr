import 'context_key.dart';

abstract interface class ContributionContext {
  String get targetId;
  Map<String, Object?> get data;

  T? get<T>(ContextKey<T> key);
  T? getRaw<T>(String key);
}

class BaseContributionContext implements ContributionContext {
  @override
  final String targetId;

  @override
  final Map<String, Object?> data;

  const BaseContributionContext({
    required this.targetId,
    this.data = const {},
  });

  @override
  T? get<T>(ContextKey<T> key) {
    final val = data[key.id];
    if (val is T) return val;
    return null;
  }

  @override
  T? getRaw<T>(String key) {
    final val = data[key];
    if (val is T) return val;
    return null;
  }
}
