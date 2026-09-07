// Recovery manager for crash recovery using shared preferences or in-memory cache
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class RecoveryManager {
  final Map<String, List<ChatEntry>> _cache = {};

  Future<void> saveRecoveryPoint(
      String sessionId, List<ChatEntry> entries) async {
    _cache[sessionId] = List.of(entries);
  }

  Future<List<ChatEntry>?> restoreRecoveryPoint(String sessionId) async {
    return _cache[sessionId];
  }

  Future<void> clearRecoveryPoint(String sessionId) async {
    _cache.remove(sessionId);
  }
}
