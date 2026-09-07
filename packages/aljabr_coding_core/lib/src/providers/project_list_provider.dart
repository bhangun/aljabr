import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/backend_providers.dart';
import '../utils/logger.dart';
import '../models/project.dart';
import 'active_project_provider.dart';
import 'active_session_provider.dart';

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, List<Project>>(
  (ref) => ProjectListNotifier(ref),
);

// Offline-first project notifier with local disk persistence in ~/.wayang/projects.json
class ProjectListNotifier extends StateNotifier<List<Project>> {
  final Ref _ref;
  ProjectListNotifier(this._ref) : super(const []) {
    _loadProjects();
  }

  File get _storageFile {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
    final dir = Directory('$home/.wayang');
    if (!dir.existsSync()) {
      try {
        dir.createSync(recursive: true);
      } catch (_) {}
    }
    return File('${dir.path}/projects.json');
  }

  List<Project> _readLocalProjects() {
    try {
      final file = _storageFile;
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.trim().isNotEmpty) {
          final list = jsonDecode(content) as List<dynamic>;
          return list
              .map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      logDebug('Failed to read local projects: $e');
    }
    return [];
  }

  void _saveLocalProjects(List<Project> projects) {
    try {
      final file = _storageFile;
      final jsonStr = jsonEncode(projects.map((p) => p.toJson()).toList());
      file.writeAsStringSync(jsonStr, flush: true);
    } catch (e) {
      logDebug('Failed to save local projects: $e');
    }
  }

  String _resolveDefaultPath() {
    const projectRoot = String.fromEnvironment(
      'PROJECT_ROOT',
      defaultValue: '',
    );
    if (projectRoot.isNotEmpty && Directory(projectRoot).existsSync()) {
      return projectRoot;
    }

    // Try current working directory
    final current = Directory.current.path;
    if (current.isNotEmpty &&
        current != '/' &&
        Directory(current).existsSync()) {
      return current;
    }

    return Platform.environment['HOME'] ?? '/';
  }

  Future<void> _loadProjects() async {
    // 1. Try reading from backend
    for (int attempt = 0; attempt < 2; attempt++) {
      if (!mounted) return;
      try {
        final service = _ref.read(backendServiceProvider);
        final loadedProjects = await service.listProjects();

        if (loadedProjects.isNotEmpty) {
          if (mounted) {
            state = loadedProjects;
            _saveLocalProjects(loadedProjects);
            _autoSelectFirst();
          }
          return;
        }
      } catch (e) {
        final msg = e.toString();
        final isExpected = msg.contains('code: 2') ||
            msg.contains('code: 12') ||
            msg.contains('UNIMPLEMENTED') ||
            msg.contains('Connection refused');
        if (!isExpected) {
          logDebug('Backend projects query attempt $attempt failed: $e');
        }
        if (attempt == 0) {
          await Future.delayed(const Duration(milliseconds: 250));
        }
      }
    }

    // 2. Offline Fallback: Load cached projects from disk
    final cached = _readLocalProjects();
    if (cached.isNotEmpty) {
      if (mounted) {
        state = cached;
        _autoSelectFirst();
      }
      return;
    }

    // 3. First-run fallback: Auto-create default local workspace
    final defaultPath = _resolveDefaultPath();
    final defaultProject = Project(
      id: 'local-workspace',
      name: 'Aljabr Workspace',
      description: 'Default Local Workspace',
      rootPath: defaultPath,
      branch: 'main',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final initialList = [defaultProject];
    _saveLocalProjects(initialList);
    if (mounted) {
      state = initialList;
      _autoSelectFirst();
    }
  }

  void _autoSelectFirst() {
    if (state.isNotEmpty) {
      final currentActive = _ref.read(activeProjectIdProvider);
      if (currentActive == null || currentActive.isEmpty) {
        _ref.read(activeProjectIdProvider.notifier).setId(state.first.id);
      }
    }
  }

  Future<void> refresh() async {
    try {
      final service = _ref.read(backendServiceProvider);
      final loadedProjects = await service.listProjects();
      if (loadedProjects.isNotEmpty && mounted) {
        state = loadedProjects;
        _saveLocalProjects(loadedProjects);
      }
    } catch (e) {
      logDebug('Failed to refresh projects from backend: $e');
      final cached = _readLocalProjects();
      if (cached.isNotEmpty && mounted) {
        state = cached;
      }
    }
  }

  Future<Project> createProject(
      String name, String description, String basePath) async {
    final newProj = Project(
      id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      rootPath: basePath,
      branch: 'main',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save locally first so UI responds immediately
    final updatedList = [...state.where((p) => p.id != newProj.id), newProj];
    state = updatedList;
    _saveLocalProjects(updatedList);
    _ref.read(activeProjectIdProvider.notifier).setId(newProj.id);

    // Sync to backend asynchronously if available
    try {
      final service = _ref.read(backendServiceProvider);
      final backendProj =
          await service.createProject(name, description, basePath);
      final syncedList = <Project>[
        ...state.where((p) => p.id != newProj.id),
        backendProj
      ];
      state = syncedList;
      _saveLocalProjects(syncedList);
      _ref.read(activeProjectIdProvider.notifier).setId(backendProj.id);
      return backendProj;
    } catch (e) {
      logDebug('Backend sync on createProject failed (saved offline): $e');
    }

    return newProj;
  }

  Future<void> deleteProject(String id) async {
    final updatedList = state.where((p) => p.id != id).toList();
    state = updatedList;
    _saveLocalProjects(updatedList);

    final currentActive = _ref.read(activeProjectIdProvider);
    if (currentActive == id) {
      if (updatedList.isNotEmpty) {
        _ref.read(activeProjectIdProvider.notifier).setId(updatedList.first.id);
      } else {
        _ref.read(activeProjectIdProvider.notifier).setId(null);
        _ref.read(activeSessionIdProvider.notifier).select(kGeneralSessionId);
      }
    }
  }
}
