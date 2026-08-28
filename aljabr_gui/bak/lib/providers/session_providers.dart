import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../data/grpc_client.dart';
import '../src/generated/wayang.pb.dart' as grpc;
import 'project_providers.dart';

/// All sessions across all projects, fetched live via gRPC.
class SessionListNotifier extends StateNotifier<List<Session>> {
  SessionListNotifier() : super(const []);

  Future<void> refresh(List<String> projectIds) async {
    try {
      List<Session> allSessions = [];
      for (final pid in projectIds) {
        final req = grpc.ListSessionsRequest(projectId: pid);
        final res = await grpcClient.projectClient.listSessions(req);
        
        allSessions.addAll(res.sessions.map((s) {
          // Map backend string status to local enum
          SessionStatus parsedStatus;
          switch (s.status.toUpperCase()) {
            case 'RUNNING': parsedStatus = SessionStatus.running; break;
            case 'DONE': parsedStatus = SessionStatus.completed; break;
            case 'ERROR': parsedStatus = SessionStatus.failed; break;
            default: parsedStatus = SessionStatus.queued;
          }

          return Session(
            id: s.id,
            projectId: s.projectId,
            title: s.name,
            timeAgo: 'just now',
            status: parsedStatus,
          );
        }));
      }
      if (mounted) {
        // Keep selected state if possible
        final selectedId = state.where((s) => s.isSelected).firstOrNull?.id;
        state = allSessions.map((s) => s.copyWith(isSelected: s.id == selectedId)).toList();
      }
    } catch (e) {
      logInfo"Failed to load sessions via gRPC: $e");
    }
  }

  void select(String id) {
    state = [
      for (final s in state) s.copyWith(isSelected: s.id == id),
    ];
  }

  /// Appends a newly forked session to the list.
  void addSession(Session session) {
    state = [...state, session];
  }
}

final sessionListProvider =
    StateNotifierProvider<SessionListNotifier, List<Session>>((ref) {
  final notifier = SessionListNotifier();
  
  // Listen to project list changes and refresh sessions automatically!
  ref.listen(projectListProvider, (previous, next) {
    notifier.refresh(next.map((p) => p.id).toList());
  }, fireImmediately: true);
  
  return notifier;
});

/// Id of the session currently open in the chat + editor panels.
class ActiveSessionNotifier extends StateNotifier<String> {
  ActiveSessionNotifier() : super('wayang-code');
  void select(String id) => state = id;
}

final activeSessionIdProvider =
    StateNotifierProvider<ActiveSessionNotifier, String>(
  (ref) => ActiveSessionNotifier(),
);

final activeSessionProvider = Provider<Session>((ref) {
  final id = ref.watch(activeSessionIdProvider);
  final sessions = ref.watch(sessionListProvider);
  return sessions.firstWhere((s) => s.id == id, orElse: () => sessions.first);
});

/// Sessions grouped by project id — drives the collapsible project tree
/// in the sidebar ("Projects > wayang-platform > ...sessions...").
final sessionsByProjectProvider =
    Provider.family<List<Session>, String>((ref, projectId) {
  final sessions = ref.watch(sessionListProvider);
  return sessions.where((s) => s.projectId == projectId).toList();
});

/// Pinned sessions across all projects, for the top-level flat list.
final pinnedSessionsProvider = Provider<List<Session>>((ref) {
  return ref.watch(sessionListProvider).where((s) => s.isPinned).toList();
});
