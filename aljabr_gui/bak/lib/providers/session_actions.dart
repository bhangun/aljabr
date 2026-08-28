import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/session.dart';
import 'chat_providers.dart';
import 'diff_providers.dart';
import 'session_providers.dart';

/// Forks the active session: creates a new [Session] under the same
/// project, seeded with a snapshot of the parent's transcript and pending
/// diffs, then switches focus to it. The two sessions are independent
/// from this point on — further messages/tool calls in one don't affect
/// the other, since both the transcript and diff providers are keyed
/// per-session.
void forkActiveSession(WidgetRef ref) {
  final sessions = ref.read(sessionListProvider);
  final activeId = ref.read(activeSessionIdProvider);
  final current = sessions.firstWhere((s) => s.id == activeId, orElse: () => sessions.first);

  final newId = 'fork-${DateTime.now().microsecondsSinceEpoch}';

  final parentTranscript = ref.read(chatTranscriptProvider(activeId));
  registerForkedTranscript(newId, [
    ...parentTranscript,
    ChatEntry(
      id: 'fork-note-$newId',
      type: ChatEntryType.stepEvent,
      text: 'Forked from "${current.title}" — continuing independently from this point.',
    ),
  ]);

  final parentDiffs = ref.read(fileDiffsProvider(activeId));
  registerForkedDiffs(newId, parentDiffs);

  final forked = Session(
    id: newId,
    projectId: current.projectId,
    title: '${current.title} (fork)',
    timeAgo: 'now',
    status: SessionStatus.queued,
    filesChanged: current.filesChanged,
  );

  ref.read(sessionListProvider.notifier).addSession(forked);
  ref.read(sessionListProvider.notifier).select(newId);
  ref.read(activeSessionIdProvider.notifier).select(newId);
}
