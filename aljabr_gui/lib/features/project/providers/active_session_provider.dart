import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/session.dart';
import 'session_list_provider.dart';

/// Constant used when no project is selected / backend offline — general chat
/// session that is not tied to any project or filesystem context.
const kGeneralSessionId = 'general-session';

final activeSessionIdProvider =
    StateNotifierProvider<ActiveSessionNotifier, String>(
  (ref) => ActiveSessionNotifier(),
);

final activeSessionProvider = Provider<Session?>((ref) {
  final id = ref.watch(activeSessionIdProvider);
  if (id.isEmpty || id == kGeneralSessionId) return null;
  final sessions = ref.watch(sessionListProvider);
  if (sessions.isEmpty) return null;
  return sessions.firstWhereOrNull((s) => s.id == id);
});

/// Id of the session currently open in the chat + editor panels.
/// Defaults to [kGeneralSessionId] so the chat never crashes with a null session.
class ActiveSessionNotifier extends StateNotifier<String> {
  ActiveSessionNotifier() : super(kGeneralSessionId);
  void select(String id) => state = id.isEmpty ? kGeneralSessionId : id;
}

extension _IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
