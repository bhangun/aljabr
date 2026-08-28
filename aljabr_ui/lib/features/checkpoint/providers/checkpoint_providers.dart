import 'package:flutter_riverpod/legacy.dart';
import '../../chat/models/checkpoint.dart';

/// Checkpoints taken automatically at meaningful points in the session
/// (mirrors the cutoffs baked into the mock transcript in chat_providers.dart).
class CheckpointsNotifier extends StateNotifier<List<Checkpoint>> {
  CheckpointsNotifier()
      : super([
          Checkpoint(
            id: 'cp0',
            label: 'Session started',
            createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
            entryCutoff: 2,
          ),
          Checkpoint(
            id: 'cp1',
            label: 'Docker services started',
            createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
            entryCutoff: 4,
          ),
          Checkpoint(
            id: 'cp2',
            label: 'Dev server booted',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
            entryCutoff: 6,
          ),
          Checkpoint(
            id: 'cp3',
            label: 'Config fix applied',
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
            entryCutoff: 8,
          ),
        ]);
}

final checkpointsProvider =
    StateNotifierProvider<CheckpointsNotifier, List<Checkpoint>>(
  (ref) => CheckpointsNotifier(),
);
