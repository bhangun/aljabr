import 'package:flutter_riverpod/legacy.dart';

/// Open file tabs in the editor.
class OpenFilesNotifier extends StateNotifier<List<String>> {
  OpenFilesNotifier() : super(const []);

  void open(String path) {
    if (!state.contains(path)) state = [...state, path];
  }

  void close(String path) {
    state = state.where((p) => p != path).toList();
  }

  void closeAll() {
    state = const [];
  }
}

final openFilesProvider =
    StateNotifierProvider<OpenFilesNotifier, List<String>>(
  (ref) => OpenFilesNotifier(),
);
