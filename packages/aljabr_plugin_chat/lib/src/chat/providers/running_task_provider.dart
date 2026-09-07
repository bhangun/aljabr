import 'package:flutter_riverpod/legacy.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// Background task tray ("2 tasks running").
class RunningTasksNotifier extends StateNotifier<List<RunningTask>> {
  RunningTasksNotifier() : super(const []);

  void remove(String id) => state = state.where((t) => t.id != id).toList();
}

final runningTasksProvider =
    StateNotifierProvider<RunningTasksNotifier, List<RunningTask>>(
  (ref) => RunningTasksNotifier(),
);
