import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import 'session_list_provider.dart';

/// Sessions grouped by project id.
final sessionsByProjectProvider =
    Provider.family<List<Session>, String>((ref, projectId) {
  final sessions = ref.watch(sessionListProvider);
  return sessions.where((s) => s.projectId == projectId).toList();
});

/// Pinned sessions across all projects.
final pinnedSessionsProvider = Provider<List<Session>>((ref) {
  return ref.watch(sessionListProvider).where((s) => s.isPinned).toList();
});
