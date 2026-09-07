enum SessionMode {
  auto, // Auto-execute pending entries
  manual, // Manual confirmation required for each
  hybrid, // Auto but pause on dangerous operations
  review, // Review all changes before execution
}

extension SessionModeExt on SessionMode {
  String get label {
    switch (this) {
      case SessionMode.auto:
        return 'Auto';
      case SessionMode.manual:
        return 'Manual';
      case SessionMode.hybrid:
        return 'Hybrid';
      case SessionMode.review:
        return 'Review';
    }
  }
}
