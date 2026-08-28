import 'package:flutter_riverpod/legacy.dart';

/// Which folder paths are expanded in the tree.
class ExpandedFoldersNotifier extends StateNotifier<Set<String>> {
  ExpandedFoldersNotifier() : super({});

  void toggle(String path) {
    final next = {...state};
    if (!next.add(path)) next.remove(path);
    state = next;
  }

  void expand(String path) {
    state = {...state, path};
  }

  void collapseAll() {
    state = {};
  }
}

final expandedFoldersProvider =
    StateNotifierProvider<ExpandedFoldersNotifier, Set<String>>(
  (ref) => ExpandedFoldersNotifier(),
);
