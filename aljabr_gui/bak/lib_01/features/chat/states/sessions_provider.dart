import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/utils/result.dart';
import '../../../presentation/providers/infrastructure_providers.dart';
import '../models/session.dart';
import 'projects_provider.dart';

class SessionsNotifier extends StateNotifier<List<Session>> {
  SessionsNotifier(this._ref, this._projectId) : super([]) {
    loadSessions();
  }

  final Ref _ref;
  final String? _projectId;

  Future<void> loadSessions() async {
    if (_projectId == null) return;
    final result = await _ref.read(sessionRepositoryProvider).getSessions(_projectId!);
    result.fold(
      onSuccess: (all) {
        state = all.where((s) => s.projectId == _projectId).toList();
      },
      onFailure: (_) {},
    );
  }

  Future<Session> createSession({String? title, String? systemPrompt}) async {
    final result = await _ref
        .read(sessionRepositoryProvider)
        .createSession(title: title, systemPrompt: systemPrompt, projectId: _projectId);
    return result.fold(
      onSuccess: (s) {
        state = [s, ...state];
        return s;
      },
      onFailure: (e) => throw Exception(e.message),
    );
  }

  Future<void> deleteSession(String id) async {
    await _ref.read(sessionRepositoryProvider).deleteSession(id, projectId: _projectId);
    state = state.where((s) => s.id != id).toList();
  }

  Future<void> deleteAllSessions() async {
    await _ref.read(sessionRepositoryProvider).deleteAllSessions();
    state = [];
  }

  Future<void> pinSession(String id, {required bool pinned}) async {
    final session = state.firstWhere((s) => s.id == id);
    await _ref.read(sessionRepositoryProvider).pinSession(id, pinned: pinned, projectId: _projectId, session: session);
    state =
        state.map((s) => s.id == id ? s.copyWith(isPinned: pinned) : s).toList()
          ..sort(_byPinThenDate);
  }

  Future<void> renameSession(String id, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    final session = state.firstWhere((s) => s.id == id);
    await _ref.read(sessionRepositoryProvider).renameSession(id, newTitle, session: session);
    state = state
        .map((s) => s.id == id ? s.copyWith(title: newTitle.trim()) : s)
        .toList();
  }

  Future<Session?> duplicateSession(String id) async {
    final session = state.firstWhere((s) => s.id == id);
    final result = await _ref
        .read(sessionRepositoryProvider)
        .duplicateSession(id, projectId: _projectId!, newTitle: '${session.title} (Copy)');
    return result.fold(
      onSuccess: (copy) {
        state = [copy, ...state];
        return copy;
      },
      onFailure: (_) => null,
    );
  }

  void updateSessionInList(Session updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList()
      ..sort(_byPinThenDate);
  }

  /// Exports a single session to a JSON string — caller decides what to do
  /// with it (e.g. write to a file, show in a dialog, copy to clipboard).
  Result<String> exportSession(Session session) =>
      _ref.read(sessionRepositoryProvider).exportSession(session);

  Result<String> exportAllSessions() =>
      _ref.read(sessionRepositoryProvider).exportAllSessions(state);

  /// Imports session(s) from a JSON string previously produced by export.
  /// Returns the list of newly created sessions (with fresh ids).
  Future<Result<List<Session>>> importFromJson(String jsonString) async {
    final result = await _ref
        .read(sessionRepositoryProvider)
        .importFromJson(jsonString);
    result.fold(
      onSuccess: (imported) =>
          state = [...imported, ...state]..sort(_byPinThenDate),
      onFailure: (_) {},
    );
    return result;
  }

  int _byPinThenDate(Session a, Session b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<Session>>(
  (ref) {
    final activeProject = ref.watch(activeProjectProvider);
    return SessionsNotifier(ref, activeProject?.id);
  },
);

/// Derived: total message count across all sessions — useful for a stats view.
final totalMessageCountProvider = Provider<int>((ref) {
  final sessions = ref.watch(sessionsProvider);
  return sessions.fold(0, (sum, s) => sum + s.messageCount);
});
