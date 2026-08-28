import 'dart:async';

import '../models/chat_entry.dart';

class AutoSaveManager {
  static const _autoSaveInterval = Duration(seconds: 5);
  static const _maxUndoHistory = 50;

  // History stores snapshots (List<ChatEntry>) per session
  final Map<String, List<List<ChatEntry>>> _undoHistory = {};
  Timer? _autoSaveTimer;

  void startAutoSave(String sessionId, List<ChatEntry> entries) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (timer) {
      _saveSnapshot(sessionId, entries);
    });
  }

  void _saveSnapshot(String sessionId, List<ChatEntry> entries) {
    _undoHistory.putIfAbsent(sessionId, () => []);
    _undoHistory[sessionId]!.add(entries.map((e) => e.copyWith()).toList());

    // Limit history size
    if (_undoHistory[sessionId]!.length > _maxUndoHistory) {
      _undoHistory[sessionId]!.removeAt(0);
    }
  }

  List<ChatEntry>? undo(String sessionId) {
    final history = _undoHistory[sessionId];
    if (history == null || history.length < 2) return null;

    history.removeLast(); // Remove current state
    return history.last;
  }

  bool canUndo(String sessionId) {
    final history = _undoHistory[sessionId];
    return history != null && history.length > 1;
  }

  void dispose() {
    _autoSaveTimer?.cancel();
  }
}
