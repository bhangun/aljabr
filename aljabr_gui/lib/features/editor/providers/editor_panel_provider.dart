import 'package:flutter_riverpod/legacy.dart';

/// Which top-level view is showing on the right: source, diff, terminal, or problems.
enum EditorPanelTab { code, diff, terminal, problems }

class EditorPanelTabNotifier extends StateNotifier<EditorPanelTab> {
  EditorPanelTabNotifier() : super(EditorPanelTab.code);
  void select(EditorPanelTab tab) => state = tab;
}

final editorPanelTabProvider =
    StateNotifierProvider<EditorPanelTabNotifier, EditorPanelTab>(
  (ref) => EditorPanelTabNotifier(),
);
