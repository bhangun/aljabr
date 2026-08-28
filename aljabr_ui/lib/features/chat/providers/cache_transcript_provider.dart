import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/backend_providers.dart';
import '../../../utils/logger.dart';
import '../models/chat_entry.dart';

/// In-memory cache keyed by sessionId — can be replaced with
/// persistent storage (ObjectBox, SharedPreferences) in the future.
final Map<String, List<ChatEntry>> _transcriptCache = {};

class CachedTranscriptNotifier extends StateNotifier<List<ChatEntry>> {
  final Ref _ref;
  final String sessionId;

  CachedTranscriptNotifier(this._ref, this.sessionId) : super([]) {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = _transcriptCache[sessionId];
      if (cached != null && cached.isNotEmpty) {
        state = cached;
      }
    } catch (e) {
      logDebug('Failed to load from cache: $e');
    }

    // Always try to sync with server
    _syncWithServer();
  }

  Future<void> _syncWithServer() async {
    try {
      final service = _ref.read(backendServiceProvider);
      final serverData = await service.listMessages(sessionId);

      if (serverData.isNotEmpty) {
        // Merge server data with cached data
        final merged = _mergeTranscripts(state, serverData);
        state = merged;

        // Update in-memory cache
        _transcriptCache[sessionId] = merged;
      }
    } catch (e) {
      logDebug('Failed to sync with server: $e');
      // If we have cached data, we're still fine
    }
  }

  List<ChatEntry> _mergeTranscripts(List<ChatEntry> cached, List serverData) {
    final merged = Map<String, ChatEntry>.fromEntries(
        cached.map((e) => MapEntry(e.id, e)));

    for (final data in serverData) {
      final entry = ChatEntry.fromJson(data);
      if (!merged.containsKey(entry.id)) {
        merged[entry.id] = entry;
      }
    }

    return merged.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}

final cachedTranscriptProvider = StateNotifierProvider.family<
    CachedTranscriptNotifier, List<ChatEntry>, String>(
  (ref, sessionId) => CachedTranscriptNotifier(ref, sessionId),
);
