import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum BackendStatus { stopped, starting, running, error }

/// Represents the status of the backend agent runner process.
final backendStatusProvider = StateProvider<BackendStatus>((ref) {
  return BackendStatus.running;
});
