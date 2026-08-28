import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui';

import '../models/chat_entry.dart';

class TranscriptOptimizer {
  static const int _maxEntriesBeforeCompression = 1000;
  static const int _batchUpdateThreshold = 10;

  final List<ChatEntry> _pendingUpdates = [];
  Timer? _batchTimer;
  final VoidCallback _onBatchUpdate;

  TranscriptOptimizer(this._onBatchUpdate);

  void addUpdate(ChatEntry entry) {
    _pendingUpdates.add(entry);

    if (_pendingUpdates.length >= _batchUpdateThreshold) {
      _flushUpdates();
    } else {
      _scheduleBatchUpdate();
    }
  }

  void _scheduleBatchUpdate() {
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: 100), _flushUpdates);
  }

  void _flushUpdates() {
    if (_pendingUpdates.isEmpty) return;

    _pendingUpdates.clear();
    _batchTimer?.cancel();

    // Apply all updates at once
    _onBatchUpdate();
  }

  static List<ChatEntry> compressTranscript(List<ChatEntry> entries) {
    if (entries.length < _maxEntriesBeforeCompression) return entries;

    // Keep all pending and important entries
    // Compress older agent messages (keep last 100)
    final oldAgentMessages = entries
        .where((e) => e.type == ChatEntryType.agentText)
        .skip(100)
        .map((e) => e.copyWith(
              text:
                  '[Compressed] ${e.text.substring(0, Math.min(100, e.text.length))}...',
            ))
        .toList();

    final kept = entries
        .where((e) =>
            e.type != ChatEntryType.agentText ||
            e == entries.lastWhere((e) => e.type == ChatEntryType.agentText))
        .toList();

    return [...kept, ...oldAgentMessages];
  }
}
