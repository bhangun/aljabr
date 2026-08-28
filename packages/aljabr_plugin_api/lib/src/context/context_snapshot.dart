import 'context_key.dart';
import 'contribution_context.dart';

/// A snapshot of the context.
class ContextSnapshot implements ContributionContext {
  /// The ID of the target.
  @override
  final String targetId;
  /// The values of the context.
  final Map<ContextKey<Object?>, Object?> _values;

  /// Creates a new [ContextSnapshot] instance.
  ContextSnapshot(
    Map<ContextKey<Object?>, Object?> values, {
    this.targetId = '',
  }) : _values = Map.unmodifiable(values);

  /// Creates a new [ContextSnapshot] instance from the given values.
  const ContextSnapshot.empty({this.targetId = ''}) : _values = const {};

  /// Returns the data of the context.
  @override
  Map<String, Object?> get data {
    return {
      for (final entry in _values.entries) entry.key.id: entry.value,
    };
  }

  /// Returns the value for the given context key.
  @override
  T? get<T>(ContextKey<T> key) {
    final value = _values[key as ContextKey<Object?>];
    return value is T ? value : null;
  }

  /// Returns the value for the given context key.
  @override
  T? getRaw<T>(String key) {
    for (final entry in _values.entries) {
      if (entry.key.id == key && entry.value is T) {
        return entry.value as T;
      }
    }
    return null;
  }

  /// Checks if the context contains the given context key.
  bool contains<T>(ContextKey<T> key) {
    return _values.containsKey(key as ContextKey<Object?>);
  }

  /// Returns the values of the context.
  Map<ContextKey<Object?>, Object?> get values => _values;

  /// Merges this context snapshot with another context snapshot.
  ContextSnapshot merge(ContextSnapshot other) {
    return ContextSnapshot(
      {
        ..._values,
        ...other._values,
      },
      targetId: targetId.isNotEmpty ? targetId : other.targetId,
    );
  }
}
