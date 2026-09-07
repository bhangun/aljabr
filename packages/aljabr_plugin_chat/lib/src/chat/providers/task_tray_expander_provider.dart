import 'package:flutter_riverpod/legacy.dart';

class TaskTrayExpandedNotifier extends StateNotifier<bool> {
  TaskTrayExpandedNotifier() : super(true);
  void toggle() => state = !state;
}

final taskTrayExpandedProvider =
    StateNotifierProvider<TaskTrayExpandedNotifier, bool>(
  (ref) => TaskTrayExpandedNotifier(),
);
