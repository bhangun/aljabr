import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chat_entry.dart';
import '../models/plan_step.dart';
import 'project_providers.dart';

final transcriptProvider = FutureProvider.family<List<ChatEntry>, String>(
  (ref, sessionId) async {
    final service = ref.watch(projectServiceProvider);
    return await service.getTranscript(sessionId);
  },
);

final transcriptNotifierProvider = StateNotifierProvider.family<
    TranscriptNotifier, AsyncValue<List<ChatEntry>>, String>((ref, sessionId) {
  return TranscriptNotifier(ref, sessionId);
});

class TranscriptNotifier extends StateNotifier<AsyncValue<List<ChatEntry>>> {
  final Ref _ref;
  final String sessionId;

  TranscriptNotifier(this._ref, this.sessionId)
      : super(const AsyncValue.loading()) {
    _loadTranscript();
  }

  Future<void> _loadTranscript() async {
    try {
      final service = _ref.read(projectServiceProvider);
      final entries = await service.getTranscript(sessionId);
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> appendEntry(ChatEntry entry) async {
    try {
      final service = _ref.read(projectServiceProvider);
      await service.appendToTranscript(sessionId, entry);

      // Update local state
      final current = state.value ?? <ChatEntry>[];
      state = AsyncValue.data([...current, entry]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateEntry(String entryId, ChatEntry entry) async {
    try {
      final service = _ref.read(projectServiceProvider);
      await service.updateTranscriptEntry(sessionId, entryId, entry);

      final current = state.value ?? <ChatEntry>[];
      final index = current.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        final updated = [...current];
        updated[index] = entry;
        state = AsyncValue.data(updated);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePlanStepStatus(
    String planEntryId,
    String stepId,
    PlanStepStatus status,
  ) async {
    try {
      final service = _ref.read(projectServiceProvider);
      await service.updatePlanStepStatus(
          sessionId, planEntryId, stepId, status);
      await _loadTranscript();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadTranscript();
  }
}
