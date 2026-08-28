import 'dart:developer';

/// Performance monitoring utilities
class PerformanceMonitor {
  PerformanceMonitor._();
  static final PerformanceMonitor _instance = PerformanceMonitor._();
  static PerformanceMonitor get instance => _instance;

  final Map<String, List<Duration>> _timings = {};
  final Map<String, int> _counts = {};

  /// Measure execution time of a function
  T measure<T>(String name, T Function() fn) {
    final stopwatch = Stopwatch()..start();
    try {
      return fn();
    } finally {
      stopwatch.stop();
      _recordTiming(name, stopwatch.elapsed);
    }
  }

  /// Async version
  Future<T> measureAsync<T>(String name, Future<T> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      stopwatch.stop();
      _recordTiming(name, stopwatch.elapsed);
    }
  }

  void _recordTiming(String name, Duration duration) {
    if (!_timings.containsKey(name)) {
      _timings[name] = [];
    }
    _timings[name]!.add(duration);
    _counts[name] = (_counts[name] ?? 0) + 1;

    // Log slow operations
    if (duration.inMilliseconds > 100) {
      log('Slow operation: $name took ${duration.inMilliseconds}ms');
    }
  }

  /// Get stats for a measurement
  PerformanceStats getStats(String name) {
    final timings = _timings[name] ?? [];
    if (timings.isEmpty) {
      return PerformanceStats.empty(name);
    }

    final sorted = List<Duration>.from(timings)..sort();
    final total = timings.fold(Duration.zero, (sum, d) => sum + d);

    return PerformanceStats(
      name: name,
      count: timings.length,
      total: total,
      average: Duration(milliseconds: total.inMilliseconds ~/ timings.length),
      min: sorted.first,
      max: sorted.last,
      p95: sorted[(sorted.length * 0.95).round()],
    );
  }

  /// Get all stats
  Map<String, PerformanceStats> getAllStats() {
    final result = <String, PerformanceStats>{};
    for (final name in _timings.keys) {
      result[name] = getStats(name);
    }
    return result;
  }

  /// Clear all measurements
  void clear() {
    _timings.clear();
    _counts.clear();
  }
}

/// Performance statistics
class PerformanceStats {
  const PerformanceStats({
    required this.name,
    required this.count,
    required this.total,
    required this.average,
    required this.min,
    required this.max,
    required this.p95,
  });

  factory PerformanceStats.empty(String name) {
    return PerformanceStats(
      name: name,
      count: 0,
      total: Duration.zero,
      average: Duration.zero,
      min: Duration.zero,
      max: Duration.zero,
      p95: Duration.zero,
    );
  }

  final String name;
  final int count;
  final Duration total;
  final Duration average;
  final Duration min;
  final Duration max;
  final Duration p95;
}
