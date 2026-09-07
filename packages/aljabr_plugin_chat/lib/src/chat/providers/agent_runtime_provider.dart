import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'chat_transcript_provider.dart';

/// Whether the agent is actively mid-run for the current session — drives
/// the Stop/interrupt affordance above the composer.
class AgentRunningNotifier extends StateNotifier<bool> {
  final Ref _ref;
  AgentRunningNotifier(this._ref) : super(false);

  void stop() {
    state = false;
    final sessionId = _ref.read(activeSessionIdProvider);
    _ref
        .read(chatTranscriptProvider(sessionId).notifier)
        .appendStep('Stopped by user');
  }
}

final agentRunningProvider = StateNotifierProvider<AgentRunningNotifier, bool>(
  (ref) => AgentRunningNotifier(ref),
);
