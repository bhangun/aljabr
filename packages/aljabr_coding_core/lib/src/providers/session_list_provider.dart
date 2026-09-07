import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';
import '../data/backend_providers.dart';
import '../models/chat_entry.dart';
import '../models/project.dart';
import '../models/session.dart';
import '../models/session_statusx.dart';
import 'active_session_provider.dart';
import 'project_list_provider.dart';

typedef SessionForkHistoryCloner = void Function(
  Ref ref,
  String sourceSessionId,
  String targetSessionId, [
  String? messageId,
]);

SessionForkHistoryCloner? sessionForkHistoryCloner;

final sessionListProvider =
    StateNotifierProvider<SessionListNotifier, List<Session>>((ref) {
  final notifier = SessionListNotifier(ref);
  ref.listen<List<Project>>(projectListProvider, (previous, next) {
    if (previous != next && next.isNotEmpty) {
      notifier.refresh(next.map((p) => p.id).toList());
    }
  });
  return notifier;
});

// Resilient, offline-first session management with Hive persistence
class SessionListNotifier extends StateNotifier<List<Session>> {
  final Ref _ref;
  static const String _kHiveBox = 'aljabr_sessions';
  static const String _kSessionsKey = 'sessions_list';

  SessionListNotifier(this._ref) : super(const []) {
    _loadFromHive();
  }

  void _loadFromHive() {
    try {
      final box = Hive.box(_kHiveBox);
      final raw = box.get(_kSessionsKey);
      if (raw != null) {
        final List<dynamic> list = raw is String ? jsonDecode(raw) : raw;
        final loaded = list.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return Session(
            id: m['id'] as String? ?? 'sess-1',
            projectId: m['projectId'] as String? ?? 'local-workspace',
            title: m['title'] as String? ?? 'New Chat',
            isSelected: m['isSelected'] as bool? ?? false,
            createdAt: m['createdAt'] != null
                ? DateTime.tryParse(m['createdAt'] as String) ?? DateTime.now()
                : DateTime.now(),
            updatedAt: m['updatedAt'] != null
                ? DateTime.tryParse(m['updatedAt'] as String) ?? DateTime.now()
                : DateTime.now(),
            status: SessionStatus.values.firstWhere(
              (s) => s.name == (m['status'] as String? ?? ''),
              orElse: () => SessionStatus.queued,
            ),
            fileChanges: m['fileChanges'] as int? ?? 0,
          );
        }).toList();

        if (loaded.isNotEmpty) {
          state = loaded;
          final firstId = loaded.first.id;
          Future.microtask(() {
            final activeId = _ref.read(activeSessionIdProvider);
            if (activeId.isEmpty || activeId == kGeneralSessionId) {
              _ref.read(activeSessionIdProvider.notifier).select(firstId);
            }
          });
        }
      }
    } catch (e) {
      logDebug('Failed to load sessions from Hive: $e');
    }
  }

  void _saveToHive() {
    try {
      final box = Hive.box(_kHiveBox);
      final list = state
          .map((s) => {
                'id': s.id,
                'projectId': s.projectId,
                'title': s.title,
                'isSelected': s.isSelected,
                'createdAt': s.createdAt.toIso8601String(),
                'updatedAt': s.updatedAt.toIso8601String(),
                'status': s.status.name,
                'fileChanges': s.fileChanges,
              })
          .toList();
      box.put(_kSessionsKey, jsonEncode(list));
    } catch (e) {
      logDebug('Failed to save sessions to Hive: $e');
    }
  }

  void addSession(Session session) {
    state = [...state.where((s) => s.id != session.id), session];
    _saveToHive();
    Future.microtask(() {
      final activeId = _ref.read(activeSessionIdProvider);
      if (activeId.isEmpty || activeId == kGeneralSessionId) {
        _ref.read(activeSessionIdProvider.notifier).select(session.id);
      }
    });
  }

  void updateSession(String id, Session newSession) {
    state = [
      for (final s in state)
        if (s.id == id) newSession else s
    ];
    _saveToHive();
  }

  Future<void> renameSession(String id, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;

    state = [
      for (final s in state)
        if (s.id == id)
          s.copyWith(title: trimmed, updatedAt: DateTime.now())
        else
          s
    ];
    _saveToHive();

    // (gRPC backend does not currently support updating session titles,
    // so we rely on the local Hive state. We will merge titles in refresh())
  }

  void autoRenameIfDefault(String id, String firstPrompt) {
    final idx = state.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final currentTitle = state[idx].title.trim();
    final isDefault = currentTitle == 'New Chat' ||
        currentTitle == 'Untitled' ||
        currentTitle.startsWith('Session ') ||
        currentTitle.startsWith('sess-');

    if (!isDefault) return;

    // Extract first sentence or up to 32 characters
    var clean = firstPrompt.trim().split('\n').first;
    if (clean.length > 32) {
      clean = '${clean.substring(0, 29).trim()}…';
    }
    if (clean.isNotEmpty) {
      // Capitalize first letter
      clean = clean[0].toUpperCase() + clean.substring(1);
      renameSession(id, clean);
    }
  }

  Future<void> refresh(List<String> projectIds) async {
    List<Session> allSessions = [];

    // 1. Try reading from backend
    try {
      final service = _ref.read(backendServiceProvider);
      for (final pid in projectIds) {
        try {
          final sessions = await service.listSessions(pid);
          allSessions.addAll(sessions);
        } catch (_) {}
      }
    } catch (e) {
      logDebug('Failed to query sessions from backend (using local): $e');
    }

    // 2. If we have existing local/Hive sessions, retain them
    if (allSessions.isEmpty && state.isNotEmpty) {
      allSessions = List.from(state);
    }

    // 3. Fallback: Auto-create default session for active project if completely empty
    if (allSessions.isEmpty && projectIds.isNotEmpty) {
      final defaultSession = Session(
        id: 'sess-default',
        projectId: projectIds.first,
        title: 'New Chat',
        isSelected: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      allSessions.add(defaultSession);
    }

    if (mounted && allSessions.isNotEmpty) {
      final currentActive = _ref.read(activeSessionIdProvider);
      final hasActive = allSessions.any((s) => s.id == currentActive);
      final selectedId = hasActive ? currentActive : allSessions.first.id;

      state = allSessions.map((s) {
        // Restore local title if available
        final local = state.where((ls) => ls.id == s.id).firstOrNull;
        final titleToUse = (local != null &&
                local.title != 'New Chat' &&
                local.title != 'Untitled')
            ? local.title
            : s.title;
        return s.copyWith(title: titleToUse, isSelected: s.id == selectedId);
      }).toList();
      _saveToHive();
      Future.microtask(() {
        _ref.read(activeSessionIdProvider.notifier).select(selectedId);
      });
    }
  }

  void select(String id) {
    state = [for (final s in state) s.copyWith(isSelected: s.id == id)];
    _saveToHive();
    Future.microtask(() {
      _ref.read(activeSessionIdProvider.notifier).select(id);
    });
  }

  Future<Session> createSession(String projectId, String name) async {
    final newSession = Session(
      id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId.isNotEmpty ? projectId : 'local-workspace',
      title: name.isNotEmpty ? name : 'New Chat',
      isSelected: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save locally and in Hive first so UI responds immediately
    addSession(newSession);
    select(newSession.id);

    // Sync to backend asynchronously if available
    try {
      final service = _ref.read(backendServiceProvider);
      final backendSession = await service.createSession(projectId, name);
      updateSession(newSession.id, backendSession);
      select(backendSession.id);
      return backendSession;
    } catch (e) {
      logDebug(
          'Backend sync on createSession failed (using local session): $e');
    }

    return newSession;
  }

  Future<void> deleteSession(String id) async {
    state = state.where((s) => s.id != id).toList();
    _saveToHive();
    final currentActive = _ref.read(activeSessionIdProvider);
    if (currentActive == id) {
      if (state.isNotEmpty) {
        select(state.first.id);
      } else {
        Future.microtask(() {
          _ref.read(activeSessionIdProvider.notifier).select(kGeneralSessionId);
        });
      }
    }

    try {
      final service = _ref.read(backendServiceProvider);
      await service.deleteSession(id);
    } catch (e) {
      logDebug('Backend deleteSession error (deleted locally): $e');
    }
  }

  Future<Session> forkSession(String id, [String? messageId]) async {
    final existing =
        state.firstWhere((s) => s.id == id, orElse: () => state.first);
    final forkedId = 'sess-${DateTime.now().millisecondsSinceEpoch}';
    final forked = Session(
      id: forkedId,
      projectId: existing.projectId,
      title: '${existing.title} (Fork)',
      isSelected: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Copy parent chat history to forked session via hook if registered
    sessionForkHistoryCloner?.call(_ref, id, forkedId, messageId);

    addSession(forked);
    select(forked.id);

    try {
      final service = _ref.read(backendServiceProvider);
      final backendForked = await service.forkSession(id, messageId);
      updateSession(forked.id, backendForked.copyWith(title: forked.title));

      // Move local chat history to the backend ID
      if (backendForked.id != forkedId) {
        sessionForkHistoryCloner?.call(_ref, forkedId, backendForked.id);
      }

      select(backendForked.id);
      return backendForked;
    } catch (e) {
      logDebug('Backend forkSession error (forked locally): $e');
    }

    return forked;
  }
}
