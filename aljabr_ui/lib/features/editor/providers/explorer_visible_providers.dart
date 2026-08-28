import 'package:flutter_riverpod/legacy.dart';

/// Whether the explorer column is shown next to the editor tab content.
class ExplorerVisibleNotifier extends StateNotifier<bool> {
  ExplorerVisibleNotifier() : super(true);
  void toggle() => state = !state;
}

final explorerVisibleProvider =
    StateNotifierProvider<ExplorerVisibleNotifier, bool>(
  (ref) => ExplorerVisibleNotifier(),
);
