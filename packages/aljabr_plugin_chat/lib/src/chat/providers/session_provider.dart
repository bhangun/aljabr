import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'chat_transcript_provider.dart';

/// Rough token/cost estimate for a session, derived from its transcript.
/// A real integration would read actual usage from the API response;
/// this approximates from character counts (~4 chars/token) purely for
/// giving the UI something live to display.
final sessionUsageProvider =
    Provider.family<(int tokens, double costUsd), String>(
  (ref, sessionId) {
    final entries = ref.watch(chatTranscriptProvider(sessionId));
    int tokens = 0;
    for (final e in entries) {
      tokens += (e.text.length ~/ 4) + 1;
      final tc = e.toolCall;
      if (tc != null) {
        tokens +=
            (((tc.detailInput?.length ?? 0) + (tc.detailOutput?.length ?? 0)) ~/
                    4) +
                1;
        tokens += 40; // fixed per-call overhead
      }
    }
    final costUsd = tokens / 1000 * 0.015;
    return (tokens, costUsd);
  },
);

// Update session provider to include mode and queue management
class SessionControllerNotifier extends StateNotifier<Session> {
  SessionControllerNotifier(super.initialState);

  void updateStatus(SessionStatus status) {
    state = state.copyWith(status: status);
  }

  void updateMode(SessionMode mode) {
    state = state.copyWith(mode: mode);
  }

  void updatePendingCount(int count) {
    state = state.copyWith(pendingCount: count);
  }

  void updateQueueSize(int size) {
    state = state.copyWith(queueSize: size);
  }
}

// Keep existing providers and add new ones
final sessionControllerProvider =
    StateNotifierProvider.autoDispose<SessionControllerNotifier, Session>(
  (ref) {
    final session = ref.watch(activeSessionProvider);
    if (session == null) {
      return SessionControllerNotifier(Session(
        id: '',
        projectId: '',
        title: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    return SessionControllerNotifier(session);
  },
);
