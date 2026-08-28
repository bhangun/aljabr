import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/entities/app_settings.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import '../../features/chat/models/session.dart';
import '../../features/workspace/workspace.dart';
import '../models/json_models.dart';

/// Low-level key-value persistence via SharedPreferences.
/// All methods return [Result] — callers never deal with raw exceptions.
class LocalStorageDatasource {
  LocalStorageDatasource(this._prefs);

  final SharedPreferences _prefs;

  // ── Sessions ──────────────────────────────────────────────────────────────

  Result<List<Session>> loadSessions() {
    try {
      final raw = _prefs.getStringList(AppConstants.kSessions) ?? [];
      final sessions = raw.map((s) {
        final j = jsonDecode(s) as Map<String, dynamic>;
        return sessionFromJson(j);
      }).toList();
      sessions.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return Success(sessions);
    } catch (e) {
      return Failure(StorageError('Failed to load sessions: $e'));
    }
  }

  Future<Result<void>> saveSession(Session session) async {
    try {
      final all = _loadRawSessions();
      final idx = all.indexWhere((s) => s['id'] == session.id);
      final json = session.toJson();
      if (idx == -1) {
        all.add(json);
      } else {
        all[idx] = json;
      }
      await _saveRawSessions(all);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save session: $e'));
    }
  }

  Future<Result<void>> deleteSession(String sessionId) async {
    try {
      final all = _loadRawSessions();
      all.removeWhere((s) => s['id'] == sessionId);
      await _saveRawSessions(all);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to delete session: $e'));
    }
  }

  Future<Result<void>> clearAllSessions() async {
    try {
      await _prefs.remove(AppConstants.kSessions);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to clear sessions: $e'));
    }
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Result<AppSettings> loadSettings() {
    try {
      final raw = _prefs.getString(AppConstants.kSettings);
      if (raw == null) return const Success(AppSettings());
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return Success(appSettingsFromJson(j));
    } catch (e) {
      return Failure(StorageError('Failed to load settings: $e'));
    }
  }

  Future<Result<void>> saveSettings(AppSettings settings) async {
    try {
      await _prefs.setString(
        AppConstants.kSettings,
        jsonEncode(settings.toJson()),
      );
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save settings: $e'));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _loadRawSessions() {
    final raw = _prefs.getStringList(AppConstants.kSessions) ?? [];
    return raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  Future<void> _saveRawSessions(List<Map<String, dynamic>> sessions) async {
    final encoded = sessions.map((s) => jsonEncode(s)).toList();
    await _prefs.setStringList(AppConstants.kSessions, encoded);
  }

  // ── Projects ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> loadRawProjects() {
    final raw = _prefs.getStringList('projects_v1') ?? [];
    return raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  Future<void> saveRawProjects(List<Map<String, dynamic>> projects) async {
    final encoded = projects.map((p) => jsonEncode(p)).toList();
    await _prefs.setStringList('projects_v1', encoded);
  }

  // ── Workspaces ───────────────────────────────────────────────────────────

  Result<List<Workspace>> loadWorkspaces() {
    try {
      final raw = _prefs.getStringList('workspaces_v1') ?? [];
      final workspaces = raw.map((s) {
        final j = jsonDecode(s) as Map<String, dynamic>;
        return Workspace(
          id: j['id'] as String,
          name: j['name'] as String,
          createdAt: DateTime.parse(j['createdAt'] as String),
          updatedAt: DateTime.parse(j['updatedAt'] as String),
          sessions: const [],
          description: j['description'] as String?,
          tags: (j['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
          isPinned: j['isPinned'] as bool? ?? false,
          icon: j['icon'] as String?,
        );
      }).toList();
      return Success(workspaces);
    } catch (e) {
      return Failure(StorageError('Failed to load workspaces: $e'));
    }
  }

  Future<Result<void>> saveWorkspace(Workspace workspace) async {
    try {
      final all = _loadRawWorkspaces();
      final idx = all.indexWhere((w) => w['id'] == workspace.id);
      final json = {
        'id': workspace.id,
        'name': workspace.name,
        'createdAt': workspace.createdAt.toIso8601String(),
        'updatedAt': workspace.updatedAt.toIso8601String(),
        'description': workspace.description,
        'tags': workspace.tags,
        'isPinned': workspace.isPinned,
        'icon': workspace.icon,
      };
      if (idx == -1) {
        all.add(json);
      } else {
        all[idx] = json;
      }
      await _saveRawWorkspaces(all);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save workspace: $e'));
    }
  }

  Future<Result<void>> deleteWorkspace(String id) async {
    try {
      final all = _loadRawWorkspaces();
      all.removeWhere((w) => w['id'] == id);
      await _saveRawWorkspaces(all);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to delete workspace: $e'));
    }
  }

  List<Map<String, dynamic>> _loadRawWorkspaces() {
    final raw = _prefs.getStringList('workspaces_v1') ?? [];
    return raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  Future<void> _saveRawWorkspaces(List<Map<String, dynamic>> workspaces) async {
    final encoded = workspaces.map((w) => jsonEncode(w)).toList();
    await _prefs.setStringList('workspaces_v1', encoded);
  }
}
