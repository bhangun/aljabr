import 'dart:convert';
import '../../../utils/logger.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../chat/models/plan_step.dart';
import '../models/project.dart';
import '../models/session.dart';
import '../../chat/models/chat_entry.dart';
import '../models/session_statusx.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final _uuid = const Uuid();
  final Map<String, Project> _projects = {};
  final Map<String, Session> _sessions = {};
  final Map<String, List<ChatEntry>> _transcripts = {};
  bool _initialized = false;

  /// Initialize with saved data
  Future<void> init() async {
    if (_initialized) return;
    await _loadFromDisk();
    _initialized = true;
  }

  // ─── Project Operations ─────────────────────────────────────────────

  Future<List<Project>> listProjects() async {
    await init();
    return _projects.values.toList();
  }

  Future<Project> getProject(String id) async {
    await init();
    return _projects[id] ?? (throw Exception('Project not found: $id'));
  }

  Future<Project> createProject({
    required String name,
    String description = '',
    String? rootPath,
    String? branch,
  }) async {
    await init();

    final id = _uuid.v4();
    final project = Project(
      id: id,
      name: name,
      description: description,
      rootPath: rootPath ?? '/projects/$name',
      branch: branch ?? 'main',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _projects[id] = project;
    await _saveToDisk();
    return project;
  }

  Future<Project> updateProject(Project project) async {
    await init();
    if (!_projects.containsKey(project.id)) {
      throw Exception('Project not found: ${project.id}');
    }
    _projects[project.id] = project.copyWith(
      updatedAt: DateTime.now(),
    );
    await _saveToDisk();
    return _projects[project.id]!;
  }

  Future<void> deleteProject(String id) async {
    await init();
    _projects.remove(id);
    // Also delete all sessions
    final sessionIds =
        _sessions.keys.where((sid) => _sessions[sid]!.projectId == id).toList();
    for (final sid in sessionIds) {
      await deleteSession(sid);
    }
    await _saveToDisk();
  }

  // ─── Session Operations ─────────────────────────────────────────────

  Future<List<Session>> listSessions(String projectId) async {
    await init();
    return _sessions.values.where((s) => s.projectId == projectId).toList();
  }

  Future<Session> getSession(String id) async {
    await init();
    return _sessions[id] ?? (throw Exception('Session not found: $id'));
  }

  Future<Session> createSession({
    required String projectId,
    required String title,
    String? description,
  }) async {
    await init();

    final id = _uuid.v4();
    final session = Session(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      status: SessionStatus.created,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    _sessions[id] = session;
    _transcripts[id] = [];
    await _saveToDisk();
    return session;
  }

  Future<Session> updateSession(Session session) async {
    await init();
    if (!_sessions.containsKey(session.id)) {
      throw Exception('Session not found: ${session.id}');
    }
    _sessions[session.id] = session.copyWith(
      updatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    await _saveToDisk();
    return _sessions[session.id]!;
  }

  Future<Session> forkSession(String sessionId) async {
    await init();
    final original = await getSession(sessionId);
    final transcripts = await getTranscript(sessionId);

    final newId = _uuid.v4();
    final newSession = Session(
      id: newId,
      projectId: original.projectId,
      title: '${original.title} (Fork)',
      description: original.description,
      status: SessionStatus.created,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      forkOf: sessionId,
    );

    _sessions[newId] = newSession;
    // Clone transcript
    _transcripts[newId] = transcripts
        .map((e) => e.copyWith(
              id: _uuid.v4(),
              timestamp: DateTime.now(),
            ))
        .toList();

    await _saveToDisk();
    return newSession;
  }

  Future<void> deleteSession(String id) async {
    await init();
    _sessions.remove(id);
    _transcripts.remove(id);
    await _saveToDisk();
  }

  // ─── Transcript Operations ──────────────────────────────────────────

  Future<List<ChatEntry>> getTranscript(String sessionId) async {
    await init();
    return _transcripts[sessionId] ?? [];
  }

  Future<void> appendToTranscript(
    String sessionId,
    ChatEntry entry,
  ) async {
    await init();
    _transcripts.putIfAbsent(sessionId, () => []);
    _transcripts[sessionId]!.add(entry);

    // Update session last active
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.copyWith(
        lastActiveAt: DateTime.now(),
      );
    }
    await _saveToDisk();
  }

  Future<void> updateTranscriptEntry(
    String sessionId,
    String entryId,
    ChatEntry entry,
  ) async {
    await init();
    final entries = _transcripts[sessionId];
    if (entries == null) return;

    final index = entries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      entries[index] = entry;
      await _saveToDisk();
    }
  }

  Future<void> updatePlanStepStatus(
    String sessionId,
    String planEntryId,
    String stepId,
    PlanStepStatus status,
  ) async {
    await init();
    final entries = _transcripts[sessionId];
    if (entries == null) return;

    final planIndex = entries.indexWhere((e) => e.id == planEntryId);
    if (planIndex == -1) return;

    final planEntry = entries[planIndex];
    if (planEntry.plan == null) return;

    final updatedSteps = planEntry.plan!.steps.map((step) {
      if (step.id == stepId) {
        return step.copyWith(status: status);
      }
      return step;
    }).toList();

    entries[planIndex] = planEntry.copyWith(
      plan: planEntry.plan!.copyWith(steps: updatedSteps),
    );
    await _saveToDisk();
  }

  // ─── Persistence ──────────────────────────────────────────────────────

  Future<void> _saveToDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/project_data.json');

      final data = {
        'projects': _projects.values.map((p) => p.toJson()).toList(),
        'sessions': _sessions.values.map((s) => s.toJson()).toList(),
        'transcripts': _transcripts.map((key, value) =>
            MapEntry(key, value.map((e) => e.toJson()).toList())),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      logDebug('Failed to save project data: $e');
    }
  }

  Future<void> _loadFromDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/project_data.json');

      if (!await file.exists()) return;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Load projects
      if (data['projects'] != null) {
        final projects = (data['projects'] as List)
            .map((j) => Project.fromJson(j as Map<String, dynamic>))
            .toList();
        for (final p in projects) {
          _projects[p.id] = p;
        }
      }

      // Load sessions
      if (data['sessions'] != null) {
        final sessions = (data['sessions'] as List)
            .map((j) => Session.fromJson(j as Map<String, dynamic>))
            .toList();
        for (final s in sessions) {
          _sessions[s.id] = s;
        }
      }

      // Load transcripts
      if (data['transcripts'] != null) {
        final transcripts = data['transcripts'] as Map<String, dynamic>;
        for (final entry in transcripts.entries) {
          final entries = (entry.value as List)
              .map((j) => ChatEntry.fromJson(j as Map<String, dynamic>))
              .toList();
          _transcripts[entry.key] = entries;
        }
      }

      logInfo(
          'Loaded ${_projects.length} projects, ${_sessions.length} sessions');
    } catch (e) {
      logDebug('Failed to load project data: $e');
      // Initialize with default data
      await _initializeDefaultData();
    }
  }

  Future<void> _initializeDefaultData() async {
    // Create default project if none exist
    if (_projects.isEmpty) {
      final project = await createProject(
        name: 'Default Workspace',
        description: 'Default project for development',
        rootPath: '/workspace',
      );

      // Create default session
      await createSession(
        projectId: project.id,
        title: 'Getting Started',
        description: 'Initial conversation',
      );
    }
  }
}
