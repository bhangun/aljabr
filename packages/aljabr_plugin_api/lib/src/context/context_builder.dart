import 'context_key.dart';
import 'context_snapshot.dart';

/// Interface for writing context.
abstract interface class ContextWriter {
  /// Sets a value for a given context key.
  void set<T>(ContextKey<T> key, T value);
  /// Removes a value for a given context key.
  void remove<T>(ContextKey<T> key);
}

/// Builds a context snapshot.
class ContextBuilder implements ContextWriter {
  /// The values for the context.
  final Map<ContextKey<Object?>, Object?> _values = {};

  /// Sets a value for a given context key.
  @override
  void set<T>(ContextKey<T> key, T value) {
    _values[key as ContextKey<Object?>] = value;
  }

  /// Removes a value for a given context key.
  @override
  void remove<T>(ContextKey<T> key) {
    _values.remove(key as ContextKey<Object?>);
  }

  /// Builds a context snapshot.
  ContextSnapshot build() {
    return ContextSnapshot(_values);
  }
}
